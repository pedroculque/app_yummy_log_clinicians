import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:persistence_foundation/src/meal_entry_local_data_source.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as io;

const String _storeName = 'meal_entries';

/// Implementação do [MealEntryLocalDataSource] usando Sembast.
class SembastMealEntryLocalDataSource implements MealEntryLocalDataSource {
  SembastMealEntryLocalDataSource._(this._db);
  final Database _db;

  /// Expõe o banco para reutilização por outros data sources.
  Database get database => _db;

  static final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store(_storeName);

  /// Abre o banco e retorna uma instância do data source.
  static Future<SembastMealEntryLocalDataSource> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'yummy_log_diary.db');
    final db = await io.databaseFactoryIo.openDatabase(dbPath);
    return SembastMealEntryLocalDataSource._(db);
  }

  @override
  Future<void> save(String id, Map<String, dynamic> entry) async {
    final withId = Map<String, dynamic>.from(entry)..['id'] = id;
    await _store.record(id).put(_db, withId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final finder = Finder(sortOrders: [SortOrder('dateTime', false)]);
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => Map<String, dynamic>.from(r.value)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _store.record(id).delete(_db);
  }

  @override
  Future<List<Map<String, dynamic>>> getUnsyncedEntries() async {
    final finder = Finder(
      filter: Filter.notEquals('syncStatus', 'synced'),
    );
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => Map<String, dynamic>.from(r.value)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getEntriesModifiedSince(
    DateTime since,
  ) async {
    final finder = Finder(
      filter: Filter.greaterThan('updatedAt', since.toIso8601String()),
      sortOrders: [SortOrder('updatedAt')],
    );
    final records = await _store.find(_db, finder: finder);
    return records.map((r) => Map<String, dynamic>.from(r.value)).toList();
  }

  @override
  Future<List<String>> mergeFromRemote(
    List<Map<String, dynamic>> remote,
  ) async {
    debugPrint(
      '[SembastMealEntry] mergeFromRemote: ${remote.length} entries',
    );
    final updated = <String>[];
    for (final remoteEntry in remote) {
      final id = remoteEntry['id'] as String?;
      if (id == null) {
        debugPrint('[SembastMealEntry] SKIP: entry has no id');
        continue;
      }

      final localRecord = await _store.record(id).get(_db);
      final remoteUpdatedAt = remoteEntry['updatedAt'] as String?;
      debugPrint(
        '[SembastMealEntry] Processing id=$id, '
        'localExists=${localRecord != null}',
      );

      if (localRecord == null) {
        debugPrint('[SembastMealEntry] NEW entry from remote: $id');
        final merged = Map<String, dynamic>.from(remoteEntry)
          ..['syncStatus'] = 'synced';
        await _store.record(id).put(_db, merged);
        updated.add(id);
      } else {
        final localUpdatedAt = localRecord['updatedAt'] as String?;
        final localDeletedAt = localRecord['deletedAt'] as String?;
        final remoteDeletedAt = remoteEntry['deletedAt'] as String?;
        final remoteTs = remoteUpdatedAt != null
            ? DateTime.tryParse(remoteUpdatedAt)
            : null;
        final localTs =
            localUpdatedAt != null ? DateTime.tryParse(localUpdatedAt) : null;

        final remoteWins = remoteTs != null &&
            (localTs == null || remoteTs.isAfter(localTs));
        
        // Se local está deletado mas remoto não, restaurar do remoto
        final shouldRestore = localDeletedAt != null && remoteDeletedAt == null;

        debugPrint(
          '[SembastMealEntry] id=$id: localTs=$localTs, remoteTs=$remoteTs, '
          'localDeleted=${localDeletedAt != null}, '
          'remoteDeleted=${remoteDeletedAt != null}, '
          'remoteWins=$remoteWins, shouldRestore=$shouldRestore',
        );

        if (remoteWins || shouldRestore) {
          final merged = Map<String, dynamic>.from(remoteEntry)
            ..['syncStatus'] = 'synced'
            ..['photoPath'] = localRecord['photoPath'];
          await _store.record(id).put(_db, merged);
          updated.add(id);
          debugPrint(
            '[SembastMealEntry] UPDATED: $id '
            '(remoteWins=$remoteWins, restored=$shouldRestore)',
          );
        } else if (localRecord['syncStatus'] != 'synced') {
          debugPrint('[SembastMealEntry] SKIP: local is newer for $id');
        }
      }
    }
    debugPrint(
      '[SembastMealEntry] mergeFromRemote finished, '
      'updated=${updated.length}',
    );
    return updated;
  }
}
