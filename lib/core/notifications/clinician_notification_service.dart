import 'dart:async';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:auth_foundation/auth_foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Gerencia permissões, token FCM e limpeza de registro ao trocar a sessão.
///
/// [start] deve ser chamado só depois do utilizador estar na home com tabs
/// (shell principal); não há registo de token na tela de login.
class ClinicianNotificationService {
  ClinicianNotificationService({
    AuthRepository? authRepository,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    CrashReporter? crashReporter,
  }) : _auth = authRepository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance,
       _crashReporter = crashReporter;

  final AuthRepository? _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final CrashReporter? _crashReporter;

  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  Timer? _retryTimer;
  bool _started = false;
  String? _registeredUserId;
  String? _registeredToken;
  GoRouter? _router;
  int _retryCount = 0;
  static const _maxRetries = 8;
  _NotificationLifecycleObserver? _lifecycleObserver;

  Future<void> start() async {
    if (!_started) {
      _started = true;
      _authSub ??= _auth?.authStateChanges.listen(_onAuthChanged);
      _lifecycleObserver ??= _NotificationLifecycleObserver(_onAppBecameActive);
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    }
    // Sync ao entrar no shell (2º login: _started true, tenta token de novo).
    unawaited(_syncCurrentUserToken());
    unawaited(_clearLauncherBadge());
  }

  Future<void> attachRouter(GoRouter router) async {
    _router = router;
    _messageOpenedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessage,
    );
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<void> _onAuthChanged(AuthUser? user) async {
    if (user == null) {
      await clearCurrentToken();
      return;
    }
    _retryCount = 0;
    await _syncTokenForUser(user.uid);
  }

  void _onAppBecameActive() {
    _retryCount = 0;
    unawaited(_clearLauncherBadge());
    unawaited(_syncCurrentUserToken());
  }

  Future<void> _syncCurrentUserToken() async {
    final user = _auth?.currentUser;
    if (user == null) {
      await clearCurrentToken();
      return;
    }
    await _syncTokenForUser(user.uid);
  }

  Future<void> _syncTokenForUser(String userId) async {
    if (_registeredUserId != null && _registeredUserId != userId) {
      await clearCurrentToken();
      _retryCount = 0;
    }

    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[Notifications] permission denied');
      return;
    }

    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      debugPrint('[Notifications] APNS token (para teste Apple): $apnsToken');
      if (apnsToken == null || apnsToken.isEmpty) {
        if (_isSimulator) {
          debugPrint(
            '[Notifications] APNS not available on iOS Simulator - '
            'push notifications require a physical device',
          );
          return;
        }
        if (_retryCount >= _maxRetries) {
          debugPrint(
            '[Notifications] APNS token not available after $_maxRetries '
            'attempts - will retry on next app launch or auth change',
          );
          return;
        }
        debugPrint(
          '[Notifications] APNS token not ready yet '
          '(attempt ${_retryCount + 1}/$_maxRetries)',
        );
        _scheduleRetry(userId);
        return;
      }
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[Notifications] FCM token unavailable');
        _scheduleRetry(userId);
        return;
      }

      _retryCount = 0;
      debugPrint('[Notifications] FCM token registered successfully');
      debugPrint(
        '[Notifications] platform=${Platform.operatingSystem} token=$token',
      );
      await _persistToken(userId: userId, token: token);
      _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((newToken) {
        unawaited(_persistToken(userId: userId, token: newToken));
      });
    } on FirebaseException catch (e, st) {
      if (e.code == 'apns-token-not-set') {
        debugPrint('[Notifications] waiting for APNS token');
        _scheduleRetry(userId);
        return;
      }
      _crashReporter?.call(
        e,
        st,
        feature: 'notifications',
        hint: 'fcm_token',
        extras: {'code': e.code},
      );
      rethrow;
    }
  }

  bool get _isSimulator {
    if (!Platform.isIOS) return false;
    final env = Platform.environment;
    return env.containsKey('SIMULATOR_DEVICE_NAME') ||
        env['HOME']?.contains('CoreSimulator') == true;
  }

  void _scheduleRetry(String userId) {
    if (_retryCount >= _maxRetries) return;

    _retryTimer?.cancel();
    _retryCount++;
    final delay = Duration(seconds: 1 + 2 * _retryCount);
    _retryTimer = Timer(delay, () {
      final currentUser = _auth?.currentUser;
      if (currentUser?.uid == userId) {
        unawaited(_syncTokenForUser(userId));
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    unawaited(_clearLauncherBadge());
    final router = _router;
    if (router == null) {
      return;
    }
    final eventType =
        message.data['eventType'] as String? ?? 'new_meal_entry';

    if (eventType == 'patient_unlinked') {
      router.go('/patients');
      return;
    }

    final patientId = message.data['patientId'] as String?;
    if (patientId == null || patientId.isEmpty) {
      return;
    }
    final patientName = message.data['patientName'] as String? ?? patientId;
    final query = <String, String>{};
    if (patientName.isNotEmpty) {
      query['name'] = patientName;
    }
    final queryString = query.isEmpty
        ? ''
        : '?${Uri(queryParameters: query).query}';
    router.go('/patients/$patientId/diary$queryString');
  }

  Future<void> _persistToken({
    required String userId,
    required String token,
  }) async {
    _registeredUserId = userId;
    _registeredToken = token;

    await _firestore
        .collection('clinicians')
        .doc(userId)
        .collection('notification_tokens')
        .doc(token)
        .set({
          'token': token,
          'platform': Platform.operatingSystem,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// iOS/Android: o SO não zera o badge ao abrir o app; o payload FCM define
  /// `badge` e precisamos repor a zero quando o utilizador entra na app.
  Future<void> _clearLauncherBadge() async {
    try {
      if (await AppBadgePlus.isSupported()) {
        await AppBadgePlus.updateBadge(0);
      }
    } on Object catch (e, st) {
      debugPrint('[Notifications] clear launcher badge: $e');
      _crashReporter?.call(
        e,
        st,
        feature: 'notifications',
        hint: 'clear_badge',
      );
    }
  }

  Future<void> clearCurrentToken() async {
    final userId = _registeredUserId;
    final token = _registeredToken;
    _registeredUserId = null;
    _registeredToken = null;
    _retryCount = 0;
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    if (userId == null || token == null) {
      return;
    }

    try {
      await _firestore
          .collection('clinicians')
          .doc(userId)
          .collection('notification_tokens')
          .doc(token)
          .delete();
    } on Object catch (e, st) {
      debugPrint('[Notifications] failed to delete token: $e\n$st');
      _crashReporter?.call(
        e,
        st,
        feature: 'notifications',
        hint: 'clear_token',
      );
    }
  }

  Future<void> dispose() async {
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }
    await _authSub?.cancel();
    await _messageOpenedSub?.cancel();
    _retryTimer?.cancel();
    _authSub = null;
    _messageOpenedSub = null;
    _started = false;
    await clearCurrentToken();
  }
}

class _NotificationLifecycleObserver extends WidgetsBindingObserver {
  _NotificationLifecycleObserver(this._onResumed);
  final VoidCallback _onResumed;
  bool _wasPaused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _onResumed();
    }
  }
}
