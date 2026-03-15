import 'package:equatable/equatable.dart';
import 'package:sync_foundation/src/sync_result.dart';

/// Estado do SyncCubit.
sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial.
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Sync desabilitado (usuário não logado).
class SyncDisabled extends SyncState {
  const SyncDisabled();
}

/// Sync em andamento.
class SyncInProgress extends SyncState {
  const SyncInProgress({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Sync concluído com sucesso.
class SyncCompleted extends SyncState {
  const SyncCompleted({
    required this.result,
    required this.lastSyncAt,
  });

  final SyncResult result;
  final DateTime lastSyncAt;

  @override
  List<Object?> get props => [result, lastSyncAt];
}

/// Há operações pendentes.
class SyncPending extends SyncState {
  const SyncPending({
    required this.pendingCount,
    this.lastSyncAt,
  });

  final int pendingCount;
  final DateTime? lastSyncAt;

  @override
  List<Object?> get props => [pendingCount, lastSyncAt];
}

/// Erro no sync.
class SyncError extends SyncState {
  const SyncError({
    required this.message,
    this.pendingCount = 0,
  });

  final String message;
  final int pendingCount;

  @override
  List<Object?> get props => [message, pendingCount];
}
