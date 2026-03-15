import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:diary_feature/src/data/meal_entry_repository.dart';
import 'package:diary_feature/src/domain/meal_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Estado da lista do diário.
class DiaryState {
  const DiaryState({this.entries = const [], this.loading = false});
  final List<MealEntry> entries;
  final bool loading;
}

/// Cubit que carrega e mantém a lista de entradas do diário.
/// Inicia o carregamento no construtor (singleton é criado na primeira vez
/// que a tab Diário é aberta).
class DiaryCubit extends Cubit<DiaryState> {
  DiaryCubit(this._repository) : super(const DiaryState(loading: true)) {
    unawaited(load());
  }

  final MealEntryRepository _repository;
  bool _migrated = false;

  Future<void> load() async {
    debugPrint('[DiaryCubit] load() called');
    emit(state.copyWith(loading: true));
    try {
      final entries = await _repository.getAll();
      debugPrint('[DiaryCubit] loaded ${entries.length} entries from local DB');
      for (final e in entries) {
        debugPrint('[DiaryCubit]   id=${e.id}, type=${e.mealType.name}, '
            'userId=${e.userId}, deletedAt=${e.deletedAt}');
      }
      if (!_migrated) {
        _migrated = true;
        unawaited(_migrateAbsolutePaths(entries));
      }
      emit(state.copyWith(entries: entries, loading: false));
    } on Object catch (err, st) {
      debugPrint('[DiaryCubit] load() ERROR: $err\n$st');
      emit(state.copyWith(loading: false));
    }
  }

  /// Converte photoPath absolutos legados para relativos (meal_photos/file.ext).
  Future<void> _migrateAbsolutePaths(List<MealEntry> entries) async {
    for (final e in entries) {
      if (e.photoPath != null && p.isAbsolute(e.photoPath!)) {
        final relative = p.join('meal_photos', p.basename(e.photoPath!));
        await _repository.save(e.copyWith(photoPath: relative));
      }
    }
  }

  /// Persiste uma entrada (cria ou atualiza) e recarrega a lista.
  Future<void> save(MealEntry entry) async {
    await _repository.save(entry);
    await load();
  }

  /// Remove uma entrada e recarrega a lista.
  Future<void> deleteEntry(String id) async {
    await _repository.delete(id);
    await load();
  }
}

extension _Copy on DiaryState {
  DiaryState copyWith({List<MealEntry>? entries, bool? loading}) {
    return DiaryState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
    );
  }
}
