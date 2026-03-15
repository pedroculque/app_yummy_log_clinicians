import 'dart:async';

import 'package:diary_feature/src/domain/meal_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:persistence_foundation/persistence_foundation.dart';

/// Callback para notificar o SyncService de operações.
/// Permite desacoplar o repositório do sync_foundation.
typedef SyncPushCallback = Future<void> Function(MealEntry entry);
typedef SyncDeleteCallback = Future<void> Function(String mealId);

/// Repositório de entradas do diário (usa persistência local + sync).
class MealEntryRepository {
  MealEntryRepository(this._dataSource);

  final MealEntryLocalDataSource _dataSource;

  /// Callbacks de sync (injetados pelo app após configurar SyncService).
  SyncPushCallback? onSyncPush;
  SyncDeleteCallback? onSyncDelete;

  Future<List<MealEntry>> getAll() async {
    final list = await _dataSource.getAll();
    debugPrint('[MealEntryRepo] getAll: ${list.length} raw entries from DB');
    final entries = list
        .map((m) => MealEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    final notDeleted = entries.where((e) => e.deletedAt == null).toList();
    final deleted = entries.where((e) => e.deletedAt != null).toList();
    debugPrint('[MealEntryRepo] ${notDeleted.length} active, '
        '${deleted.length} soft-deleted');
    if (deleted.isNotEmpty) {
      for (final d in deleted) {
        debugPrint(
          '[MealEntryRepo]   DELETED: id=${d.id}, deletedAt=${d.deletedAt}',
        );
      }
    }
    return notDeleted;
  }

  /// Retorna uma entrada pelo [id], ou null se não existir.
  Future<MealEntry?> getById(String id) async {
    final list = await _dataSource.getAll();
    for (final m in list) {
      final entry = MealEntry.fromJson(Map<String, dynamic>.from(m));
      if (entry.id == id && entry.deletedAt == null) return entry;
    }
    return null;
  }

  Future<void> save(MealEntry entry) async {
    final now = DateTime.now();
    final withTimestamps = entry.copyWith(
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );
    await _dataSource.save(withTimestamps.id, withTimestamps.toJson());

    unawaited(onSyncPush?.call(withTimestamps));
  }

  Future<void> delete(String id) async {
    final existing = await getById(id);
    if (existing != null) {
      final now = DateTime.now();
      final softDeleted = existing.copyWith(
        deletedAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );
      await _dataSource.save(id, softDeleted.toJson());
      unawaited(onSyncDelete?.call(id));
    } else {
      await _dataSource.delete(id);
    }
  }

  /// Associa entradas locais (sem userId) ao [userId] após o primeiro login.
  Future<void> migrateLocalEntriesToUser(String userId) async {
    debugPrint('[MealEntryRepo] migrateLocalEntriesToUser called for $userId');
    final all = await _dataSource.getAll();
    debugPrint('[MealEntryRepo] Found ${all.length} total entries to check');
    var migratedCount = 0;
    for (final m in all) {
      final entry = MealEntry.fromJson(Map<String, dynamic>.from(m));
      if (entry.userId == null || entry.userId!.isEmpty) {
        debugPrint(
          '[MealEntryRepo] Migrating entry ${entry.id} '
          '(was userId=${entry.userId})',
        );
        final migrated = entry.copyWith(
          userId: userId,
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        );
        await _dataSource.save(migrated.id, migrated.toJson());
        migratedCount++;
      }
    }
    debugPrint(
      '[MealEntryRepo] Migration complete: $migratedCount entries migrated',
    );
  }
}
