import 'dart:async';

import 'package:sembast/sembast.dart';
import 'package:sync_foundation/src/sync_operation.dart';
import 'package:sync_foundation/src/sync_queue.dart';

/// Implementação da fila de sync usando Sembast.
class SembastSyncQueue implements SyncQueue {
  SembastSyncQueue(this._db);

  final Database _db;
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('sync_queue');
  final _pendingCountController = StreamController<int>.broadcast();

  @override
  Future<void> enqueue(SyncOperation operation) async {
    await _store.record(operation.id).put(_db, operation.toMap());
    await _notifyPendingCount();
  }

  @override
  Future<void> dequeue(String operationId) async {
    await _store.record(operationId).delete(_db);
    await _notifyPendingCount();
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async {
    final records = await _store.find(_db);
    return records
        .map((r) => SyncOperation.fromMap(r.value))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<SyncOperation>> getPendingByEntityType(
    String entityType,
  ) async {
    final finder = Finder(
      filter: Filter.equals('entityType', entityType),
      sortOrders: [SortOrder('createdAt')],
    );
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => SyncOperation.fromMap(r.value)).toList();
  }

  @override
  Future<int> getPendingCount() async {
    return _store.count(_db);
  }

  @override
  Future<void> update(SyncOperation operation) async {
    await _store.record(operation.id).put(_db, operation.toMap());
  }

  @override
  Future<void> clear() async {
    await _store.delete(_db);
    await _notifyPendingCount();
  }

  @override
  Future<void> clearByEntityId(String entityId) async {
    final finder = Finder(filter: Filter.equals('entityId', entityId));
    await _store.delete(_db, finder: finder);
    await _notifyPendingCount();
  }

  @override
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  Future<void> _notifyPendingCount() async {
    final count = await getPendingCount();
    _pendingCountController.add(count);
  }

  void dispose() {
    unawaited(_pendingCountController.close());
  }
}
