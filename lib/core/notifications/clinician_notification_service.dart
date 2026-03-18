import 'dart:async';
import 'dart:io';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Gerencia permissões, token FCM e limpeza de registro ao trocar a sessão.
class ClinicianNotificationService {
  ClinicianNotificationService({
    AuthRepository? authRepository,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  }) : _auth = authRepository,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _messaging = messaging ?? FirebaseMessaging.instance;

  final AuthRepository? _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  Timer? _retryTimer;
  bool _started = false;
  String? _registeredUserId;
  String? _registeredToken;
  GoRouter? _router;
  int _retryCount = 0;
  static const _maxRetries = 3;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _authSub ??= _auth?.authStateChanges.listen(_onAuthChanged);
    unawaited(_syncCurrentUserToken());
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
    await _syncTokenForUser(user.uid);
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
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
        debugPrint('[Notifications] waiting for APNS token');
        _scheduleRetry(userId);
        return;
      }
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
    final delay = Duration(seconds: 2 * _retryCount);
    _retryTimer = Timer(delay, () {
      final currentUser = _auth?.currentUser;
      if (currentUser?.uid == userId) {
        unawaited(_syncTokenForUser(userId));
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    final router = _router;
    final patientId = message.data['patientId'] as String?;
    if (router == null || patientId == null || patientId.isEmpty) {
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

  Future<void> clearCurrentToken() async {
    final userId = _registeredUserId;
    final token = _registeredToken;
    _registeredUserId = null;
    _registeredToken = null;
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
    }
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _messageOpenedSub?.cancel();
    _retryTimer?.cancel();
    _authSub = null;
    _messageOpenedSub = null;
    await clearCurrentToken();
  }
}
