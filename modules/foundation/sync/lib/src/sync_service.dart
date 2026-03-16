import 'dart:async';
import 'dart:io';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diary_feature/diary_feature.dart';
import 'package:flutter/foundation.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sync_foundation/src/connection_sync_remote.dart';
import 'package:sync_foundation/src/meal_sync_remote.dart';
import 'package:sync_foundation/src/photo_upload_service.dart';
import 'package:sync_foundation/src/sync_config.dart';
import 'package:sync_foundation/src/sync_operation.dart';
import 'package:sync_foundation/src/sync_queue.dart';
import 'package:sync_foundation/src/sync_result.dart';
import 'package:sync_foundation/src/sync_status.dart';
import 'package:sync_foundation/src/user_document_writer.dart';

/// Callback para processar dados baixados do Firestore.
typedef PullDataCallback = Future<void> Function(
  String entityType,
  List<Map<String, dynamic>> data,
);

/// Callback para enfileirar todos os dados locais no primeiro login.
typedef InitialSyncCallback = Future<int> Function();

/// Orquestra push/pull entre Sembast (local) e Firestore (remoto).
///
/// Usa [SyncQueue] persistente para retry, [SyncConfig] para
/// configuração, e escuta conectividade para auto-sync.
class SyncService {
  SyncService({
    required AuthRepository authRepository,
    required MealEntryLocalDataSource mealLocalDataSource,
    required ConnectionLocalDataSource connectionLocalDataSource,
    required MealSyncRemote mealRemote,
    required ConnectionSyncRemote connectionRemote,
    required PhotoUploadService photoUploadService,
    required SyncQueue syncQueue,
    required UserDocumentWriter userDocumentWriter,
    SyncConfig config = const SyncConfig(),
    Connectivity? connectivity,
  })  : _auth = authRepository,
        _mealLocal = mealLocalDataSource,
        _connLocal = connectionLocalDataSource,
        _mealRemote = mealRemote,
        _connRemote = connectionRemote,
        _photoUpload = photoUploadService,
        _syncQueue = syncQueue,
        _userDocumentWriter = userDocumentWriter,
        _config = config,
        _connectivity = connectivity ?? Connectivity();

  final AuthRepository _auth;
  final UserDocumentWriter _userDocumentWriter;
  final MealEntryLocalDataSource _mealLocal;
  final ConnectionLocalDataSource _connLocal;
  final MealSyncRemote _mealRemote;
  final ConnectionSyncRemote _connRemote;
  final PhotoUploadService _photoUpload;
  final SyncQueue _syncQueue;
  final Connectivity _connectivity;
  SyncConfig _config;

  StreamSubscription<AuthUser?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _mealWatchSub;
  StreamSubscription<List<Map<String, dynamic>>>? _connWatchSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _syncTimer;
  Timer? _connectivityDebounceTimer;
  Timer? _deferredPushTimer;
  static const Duration _deferredPushDelay = Duration(seconds: 2);

  String? _currentUserId;
  bool _isPaused = false;

  SyncServiceStatus _status = SyncServiceStatus.idle;
  final _statusController =
      StreamController<SyncServiceStatus>.broadcast();

  /// Callback invocado quando dados remotos são mergeados.
  VoidCallback? onMealsUpdated;
  VoidCallback? onConnectionsUpdated;

  /// Callback para processar dados baixados do Firestore.
  PullDataCallback? onPullData;

  /// Callback para initial sync (primeiro login).
  InitialSyncCallback? onInitialSync;

  SyncServiceStatus get status => _status;
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;
  SyncConfig get config => _config;
  bool get isEnabled => _auth.currentUser != null;
  Stream<int> get pendingCountStream => _syncQueue.pendingCountStream;

  /// Delay antes de sync ao detectar conectividade (evita crash em
  /// transição foreground — Flutter engine issue).
  static const _connectivitySyncDelay = Duration(milliseconds: 800);

  /// Inicia o serviço.
  void start() {
    _authSub = _auth.authStateChanges.listen(_onAuthChanged);

    if (_config.syncOnConnectivity) {
      _connectivitySub = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
      );
    }

    if (_config.autoSyncEnabled) {
      _startSyncTimer();
    }

    final user = _auth.currentUser;
    if (user != null) {
      _activate(user.uid);
    }
  }

  void _onAuthChanged(AuthUser? user) {
    if (user != null && user.uid != _currentUserId) {
      _activate(user.uid);
      if (_config.autoSyncEnabled) {
        unawaited(sync());
      }
    } else if (user == null) {
      _deactivate();
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );
    if (!hasConnection || !isEnabled || _isPaused) {
      _connectivityDebounceTimer?.cancel();
      return;
    }
    _connectivityDebounceTimer?.cancel();
    _connectivityDebounceTimer = Timer(_connectivitySyncDelay, () {
      _connectivityDebounceTimer = null;
      if (isEnabled && !_isPaused) unawaited(sync());
    });
  }

  void _activate(String userId) {
    debugPrint('[SyncService] _activate called for userId: $userId');
    _deactivate();
    _currentUserId = userId;
    final user = _auth.currentUser;
    debugPrint(
      '[SyncService] Current user: '
      'email=${user?.email}, displayName=${user?.displayName}, '
      'photoUrl=${user?.photoUrl != null}',
    );
    unawaited(
      _userDocumentWriter.ensureExists(
        userId,
        email: user?.email,
        displayName: user?.displayName,
        photoUrl: user?.photoUrl,
      ),
    );
    if (_config.watchersEnabled) {
      _startWatchers(userId);
    } else {
      debugPrint('[SyncService] watchers disabled (watchersEnabled=false)');
    }
  }

  void _deactivate() {
    unawaited(_mealWatchSub?.cancel());
    unawaited(_connWatchSub?.cancel());
    _deferredPushTimer?.cancel();
    _mealWatchSub = null;
    _connWatchSub = null;
    _deferredPushTimer = null;
    _currentUserId = null;
  }

  void _startWatchers(String userId) {
    debugPrint('[SyncService] _startWatchers for userId: $userId');
    _mealWatchSub = _mealRemote
        .watchChanges(userId, DateTime.fromMillisecondsSinceEpoch(0))
        .listen(
      (remoteMeals) async {
        debugPrint(
          '[SyncService] watchChanges: ${remoteMeals.length} meals received',
        );
        for (final meal in remoteMeals) {
          debugPrint(
            '[SyncService]   - meal id=${meal['id']}, '
            'type=${meal['mealType']}, deletedAt=${meal['deletedAt']}, '
            'photoUrl=${meal['photoUrl'] != null}',
          );
        }
        try {
          final updated = await _mealLocal.mergeFromRemote(remoteMeals);
          debugPrint(
            '[SyncService] mergeFromRemote updated '
            '${updated.length} entries: $updated',
          );
          if (updated.isNotEmpty) {
            onMealsUpdated?.call();
            unawaited(_downloadMissingPhotos(remoteMeals));
          }
        } on Object catch (e, st) {
          debugPrint('SyncService meal pull: $e\n$st');
        }
      },
      onError: (Object e, StackTrace st) {
        debugPrint('SyncService meal watch ERROR: $e\n$st');
      },
    );

    _connWatchSub = _connRemote.watchChanges(userId).listen(
      (remoteConns) async {
        try {
          final updated = await _connLocal.mergeFromRemote(remoteConns);
          if (updated.isNotEmpty) onConnectionsUpdated?.call();
        } on Object catch (e, st) {
          debugPrint('SyncService conn pull: $e\n$st');
        }
      },
      onError: (Object e, StackTrace st) {
        debugPrint('SyncService conn watch: $e\n$st');
      },
    );
  }

  Future<void> _downloadMissingPhotos(List<Map<String, dynamic>> meals) async {
    for (final meal in meals) {
      final id = meal['id'] as String?;
      final photoUrl = meal['photoUrl'] as String?;
      if (id == null || photoUrl == null || photoUrl.isEmpty) continue;

      final localData = await _mealLocal.getAll();
      final localMeal = localData.firstWhere(
        (m) => m['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      final existingPhotoPath = localMeal['photoPath'] as String?;
      if (existingPhotoPath != null && existingPhotoPath.isNotEmpty) {
        final absolutePath = await resolvePhotoPath(existingPhotoPath);
        if (File(absolutePath).existsSync()) continue;
      }

      final downloadedPath = await _photoUpload.downloadPhoto(
        mealId: id,
        photoUrl: photoUrl,
      );

      if (downloadedPath != null) {
        final updated = Map<String, dynamic>.from(localMeal)
          ..['photoPath'] = downloadedPath;
        await _mealLocal.save(id, updated);
        onMealsUpdated?.call();
      }
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(seconds: _config.syncIntervalSeconds),
      (_) {
        if (!_isPaused && isEnabled) unawaited(sync());
      },
    );
  }

  // ── Sync completo (push + pull via queue) ──

  /// Executa sync completo: push pendentes + pull remoto.
  Future<SyncResult> sync() async {
    if (!isEnabled) {
      return const SyncResult(
        success: false,
        errors: ['Usuário não logado'],
      );
    }
    if (_status == SyncServiceStatus.syncing) {
      return const SyncResult(
        success: false,
        errors: ['Sync já em andamento'],
      );
    }

    _setStatus(SyncServiceStatus.syncing);
    try {
      final pushResult = await push();
      final pullResult = await _pullAll();
      final errors = [...pushResult.errors, ...pullResult.errors];

      _setStatus(
        errors.isEmpty
            ? SyncServiceStatus.idle
            : SyncServiceStatus.error,
      );

      return SyncResult(
        success: errors.isEmpty,
        uploadedCount: pushResult.uploadedCount,
        downloadedCount: pullResult.downloadedCount,
        errors: errors,
      );
    } on Object catch (e) {
      _setStatus(SyncServiceStatus.error);
      return SyncResult(success: false, errors: [e.toString()]);
    }
  }

  /// Força sync imediato (despausa se pausado).
  Future<SyncResult> forceSync() async {
    _isPaused = false;
    return sync();
  }

  /// Pausa sync automático.
  void pause() {
    _isPaused = true;
    _syncTimer?.cancel();
  }

  /// Resume sync automático.
  void resume() {
    _isPaused = false;
    if (_config.autoSyncEnabled) _startSyncTimer();
  }

  /// Atualiza configurações.
  void updateConfig(SyncConfig newConfig) {
    _config = newConfig;
    _syncTimer?.cancel();
    if (_config.autoSyncEnabled && !_isPaused) _startSyncTimer();
  }

  // ── Push via SyncQueue ──

  /// Processa todas as operações pendentes na fila.
  Future<SyncResult> push() async {
    final userId = _currentUserId;
    if (userId == null) {
      return const SyncResult(
        success: false,
        errors: ['Sem userId'],
      );
    }

    final operations = await _syncQueue.getPendingOperations();
    if (operations.isEmpty) {
      return const SyncResult(success: true);
    }

    var uploadedCount = 0;
    final errors = <String>[];

    for (final op in operations) {
      try {
        await _executeOperation(userId, op);
        await _syncQueue.dequeue(op.id);
        uploadedCount++;
      } on Object catch (e) {
        final updated = op.withError(e.toString());
        if (updated.attempts >= _config.maxRetries) {
          await _syncQueue.dequeue(op.id);
          errors.add('${op.entityType}/${op.entityId}: $e');
        } else {
          await _syncQueue.update(updated);
        }
      }
    }

    return SyncResult(
      success: errors.isEmpty,
      uploadedCount: uploadedCount,
      errors: errors,
    );
  }

  Future<void> _executeOperation(
    String userId,
    SyncOperation op,
  ) async {
    switch (op.entityType) {
      case 'meal':
        await _executeMealOperation(userId, op);
      case 'connection':
        await _executeConnectionOperation(userId, op);
      default:
        throw ArgumentError('Tipo desconhecido: ${op.entityType}');
    }
  }

  Future<void> _executeMealOperation(
    String userId,
    SyncOperation op,
  ) async {
    switch (op.type) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        final data = Map<String, dynamic>.from(op.data);
        final photoPath = data['photoPath'] as String?;
        final photoUrl = data['photoUrl'] as String?;

        debugPrint('[SyncService] _executeMealOperation: id=${op.entityId}, '
            'photoPath=$photoPath, photoUrl=$photoUrl');

        // Upsert primeiro no Firestore (sem foto) para o clínico ver a entrada
        // mesmo se o upload da foto falhar (ex.: storage unauthorized).
        data
          ..remove('syncStatus')
          ..remove('photoPath');
        await _mealRemote.upsert(userId, data);

        var finalPhotoUrl = photoUrl;
        if (photoPath != null && photoUrl == null) {
          try {
            final absolutePath = await resolvePhotoPath(photoPath);
            debugPrint('[SyncService] Uploading photo: $absolutePath');
            final url = await _photoUpload.uploadPhoto(
              userId: userId,
              mealId: op.entityId,
              localPath: absolutePath,
            );
            debugPrint('[SyncService] Upload result: $url');
            if (url != null) {
              finalPhotoUrl = url;
              await _mealRemote.upsert(userId, {...data, 'photoUrl': url});
            }
          } on Object catch (e, st) {
            debugPrint(
              '[SyncService] Photo upload failed (meal still synced): $e\n$st',
            );
          }
        }

        final synced = Map<String, dynamic>.from(op.data)
          ..['syncStatus'] = 'synced'
          ..['photoUrl'] = finalPhotoUrl;
        await _mealLocal.save(op.entityId, synced);

      case SyncOperationType.delete:
        await _mealRemote.softDelete(userId, op.entityId);
    }
  }

  Future<void> _executeConnectionOperation(
    String userId,
    SyncOperation op,
  ) async {
    switch (op.type) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        final data = Map<String, dynamic>.from(op.data)
          ..remove('syncStatus');
        await _connRemote.upsert(userId, data);

        final synced = Map<String, dynamic>.from(op.data)
          ..['syncStatus'] = 'synced';
        await _connLocal.save(op.entityId, synced);

      case SyncOperationType.delete:
        await _connRemote.remove(userId, op.entityId);
    }
  }

  // ── Pull ──

  Future<SyncResult> _pullAll() async {
    // Pull é feito pelos watchers (Firestore snapshots).
    // Este método existe para compatibilidade com o fluxo sync().
    return const SyncResult(success: true);
  }

  // ── Enqueue helpers (chamados pelos repositórios) ──

  /// Enfileira uma refeição para push.
  Future<void> enqueueMeal(MealEntry entry) async {
    if (_currentUserId == null) return;
    final op = SyncOperation(
      id: '${entry.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: entry.deletedAt != null
          ? SyncOperationType.delete
          : SyncOperationType.update,
      entityType: 'meal',
      entityId: entry.id,
      data: entry.toJson(),
      createdAt: DateTime.now(),
    );
    await _syncQueue.enqueue(op);
    _scheduleDeferredPush();
  }

  /// Enfileira um soft delete de refeição.
  Future<void> enqueueMealDelete(String mealId) async {
    if (_currentUserId == null) return;
    final op = SyncOperation(
      id: '${mealId}_del_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.delete,
      entityType: 'meal',
      entityId: mealId,
      data: const {},
      createdAt: DateTime.now(),
    );
    await _syncQueue.enqueue(op);
    _scheduleDeferredPush();
  }

  /// Agenda um push em breve após enfileirar (para não depender só do timer).
  void _scheduleDeferredPush() {
    _deferredPushTimer?.cancel();
    _deferredPushTimer = Timer(_deferredPushDelay, () {
      _deferredPushTimer = null;
      if (isEnabled && !_isPaused && _status != SyncServiceStatus.syncing) {
        unawaited(push());
      }
    });
  }

  /// Enfileira uma conexão para push.
  Future<void> enqueueConnection(Map<String, dynamic> json) async {
    if (_currentUserId == null) return;
    final id = json['id'] as String;
    final op = SyncOperation(
      id: '${id}_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.update,
      entityType: 'connection',
      entityId: id,
      data: json,
      createdAt: DateTime.now(),
    );
    await _syncQueue.enqueue(op);
  }

  /// Enfileira remoção de conexão.
  Future<void> enqueueConnectionDelete(String connectionId) async {
    if (_currentUserId == null) return;
    final op = SyncOperation(
      id: '${connectionId}_del_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.delete,
      entityType: 'connection',
      entityId: connectionId,
      data: const {},
      createdAt: DateTime.now(),
    );
    await _syncQueue.enqueue(op);
  }

  // ── Full push (primeiro login) ──

  /// Envia todas as entradas locais pendentes para o Firestore.
  Future<void> fullPush() async {
    debugPrint('[SyncService] fullPush called, userId=$_currentUserId');
    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('[SyncService] fullPush ABORTED: no userId');
      return;
    }

    _setStatus(SyncServiceStatus.syncing);
    try {
      final unsyncedMeals = await _mealLocal.getUnsyncedEntries();
      debugPrint(
        '[SyncService] fullPush: ${unsyncedMeals.length} unsynced meals',
      );
      for (final meal in unsyncedMeals) {
        final entry = MealEntry.fromJson(meal);
        debugPrint('[SyncService] fullPush enqueueing meal ${entry.id}');
        await enqueueMeal(entry);
      }

      final unsyncedConns = await _connLocal.getUnsyncedConnections();
      debugPrint(
        '[SyncService] fullPush: ${unsyncedConns.length} unsynced connections',
      );
      for (final conn in unsyncedConns) {
        final firestoreJson = Map<String, dynamic>.from(conn)
          ..remove('syncStatus');
        await enqueueConnection(firestoreJson);
      }

      debugPrint('[SyncService] fullPush: calling push()');
      await push();
      debugPrint('[SyncService] fullPush: push() completed');
      _setStatus(SyncServiceStatus.idle);
    } on Object catch (e, st) {
      debugPrint('SyncService.fullPush ERROR: $e\n$st');
      _setStatus(SyncServiceStatus.error);
    }
  }

  // ── Lifecycle ──

  void _setStatus(SyncServiceStatus s) {
    if (_status != s) {
      _status = s;
      _statusController.add(s);
    }
  }

  /// Limpa todos os dados de sync (logout).
  Future<void> reset() async {
    await _syncQueue.clear();
    _setStatus(SyncServiceStatus.idle);
  }

  void dispose() {
    unawaited(_authSub?.cancel());
    _deferredPushTimer?.cancel();
    _deactivate();
    _syncTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
    unawaited(_connectivitySub?.cancel());
    unawaited(_statusController.close());
  }
}
