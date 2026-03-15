import 'package:persistence_foundation/src/connection_local_data_source.dart';
import 'package:sembast/sembast.dart';

const String _storeName = 'connections';

/// Implementação do [ConnectionLocalDataSource] usando Sembast.
/// Reutiliza o mesmo [Database] aberto para meal_entries.
class SembastConnectionLocalDataSource implements ConnectionLocalDataSource {
  SembastConnectionLocalDataSource(this._db);
  final Database _db;

  static final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store(_storeName);

  @override
  Future<void> save(String id, Map<String, dynamic> connection) async {
    final withId = Map<String, dynamic>.from(connection)..['id'] = id;
    await _store.record(id).put(_db, withId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final finder = Finder(sortOrders: [SortOrder('linkedAt', false)]);
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => Map<String, dynamic>.from(r.value)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _store.record(id).delete(_db);
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedConnections() async {
    final finder = Finder(
      filter: Filter.notEquals('syncStatus', 'synced'),
    );
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => Map<String, dynamic>.from(r.value)).toList();
  }

  @override
  Future<List<String>> mergeFromRemote(
    List<Map<String, dynamic>> remote,
  ) async {
    final updated = <String>[];
    for (final remoteEntry in remote) {
      final id = remoteEntry['id'] as String?;
      if (id == null) continue;

      final localRecord = await _store.record(id).get(_db);
      final remoteUpdatedAt = remoteEntry['updatedAt'] as String?;

      if (localRecord == null) {
        final merged = Map<String, dynamic>.from(remoteEntry)
          ..['syncStatus'] = 'synced';
        await _store.record(id).put(_db, merged);
        updated.add(id);
      } else {
        final localUpdatedAt = localRecord['updatedAt'] as String?;
        final remoteTs = remoteUpdatedAt != null
            ? DateTime.tryParse(remoteUpdatedAt)
            : null;
        final localTs =
            localUpdatedAt != null ? DateTime.tryParse(localUpdatedAt) : null;

        final remoteWins = remoteTs != null &&
            (localTs == null || remoteTs.isAfter(localTs));
        if (remoteWins) {
          final merged = Map<String, dynamic>.from(remoteEntry)
            ..['syncStatus'] = 'synced';
          await _store.record(id).put(_db, merged);
          updated.add(id);
        }
      }
    }
    return updated;
  }
}
