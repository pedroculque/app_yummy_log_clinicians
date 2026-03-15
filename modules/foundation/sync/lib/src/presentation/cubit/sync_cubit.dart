import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_foundation/src/presentation/cubit/sync_state.dart';
import 'package:sync_foundation/src/sync_result.dart';
import 'package:sync_foundation/src/sync_service.dart';
import 'package:sync_foundation/src/sync_status.dart';

/// Cubit para gerenciar o estado de sincronização na UI.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit({required SyncService syncService})
      : _syncService = syncService,
        super(const SyncInitial()) {
    _init();
  }

  final SyncService _syncService;
  StreamSubscription<SyncServiceStatus>? _statusSub;
  StreamSubscription<int>? _pendingCountSub;
  DateTime? _lastSyncAt;

  void _init() {
    _statusSub =
        _syncService.statusStream.listen(_onStatusChanged);
    _pendingCountSub =
        _syncService.pendingCountStream.listen(_onPendingCountChanged);
    _updateState(_syncService.status);
  }

  void _onStatusChanged(SyncServiceStatus status) {
    _updateState(status);
  }

  void _onPendingCountChanged(int count) {
    if (state is SyncCompleted || state is SyncPending) {
      if (count > 0) {
        emit(SyncPending(
          pendingCount: count,
          lastSyncAt: _lastSyncAt,
        ));
      } else {
        emit(SyncCompleted(
          result: const SyncResult(success: true),
          lastSyncAt: _lastSyncAt ?? DateTime.now(),
        ));
      }
    }
  }

  void _updateState(SyncServiceStatus status) {
    switch (status) {
      case SyncServiceStatus.disabled:
        emit(const SyncDisabled());
      case SyncServiceStatus.syncing:
        emit(const SyncInProgress());
      case SyncServiceStatus.idle:
        _lastSyncAt = DateTime.now();
        emit(SyncCompleted(
          result: const SyncResult(success: true),
          lastSyncAt: _lastSyncAt!,
        ));
      case SyncServiceStatus.error:
        emit(const SyncError(message: 'Erro ao sincronizar'));
    }
  }

  /// Inicia sincronização manual.
  Future<void> sync() async {
    if (state is SyncDisabled) return;
    emit(const SyncInProgress(message: 'Sincronizando...'));

    final result = await _syncService.sync();

    if (result.success) {
      _lastSyncAt = DateTime.now();
      emit(SyncCompleted(
        result: result,
        lastSyncAt: _lastSyncAt!,
      ));
    } else {
      emit(SyncError(
        message: result.errors.firstOrNull ?? 'Erro desconhecido',
      ));
    }
  }

  /// Força sincronização.
  Future<void> forceSync() async {
    emit(const SyncInProgress(message: 'Forçando sincronização...'));
    final result = await _syncService.forceSync();

    if (result.success) {
      _lastSyncAt = DateTime.now();
      emit(SyncCompleted(
        result: result,
        lastSyncAt: _lastSyncAt!,
      ));
    } else {
      emit(SyncError(
        message: result.errors.firstOrNull ?? 'Erro desconhecido',
      ));
    }
  }

  void pause() => _syncService.pause();
  void resume() => _syncService.resume();
  Future<void> retry() => sync();

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _pendingCountSub?.cancel();
    return super.close();
  }
}
