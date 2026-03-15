import 'package:sync_foundation/src/sync_operation.dart';

/// Interface para a fila de operações de sync.
abstract class SyncQueue {
  Future<void> enqueue(SyncOperation operation);
  Future<void> dequeue(String operationId);
  Future<List<SyncOperation>> getPendingOperations();
  Future<List<SyncOperation>> getPendingByEntityType(String entityType);
  Future<int> getPendingCount();
  Future<void> update(SyncOperation operation);
  Future<void> clear();
  Future<void> clearByEntityId(String entityId);
  Stream<int> get pendingCountStream;
}
