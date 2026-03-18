import 'package:bloc/bloc.dart';
import 'package:diary_feature/src/data/meal_entry_repository.dart';
import 'package:meal_domain/meal_domain.dart';

/// Estado do detalhe de uma entrada (carregar por id).
class EntryDetailState {
  const EntryDetailState({
    this.entry,
    this.loading = true,
    this.error,
  });

  final MealEntry? entry;
  final bool loading;
  final String? error;

  bool get notFound => !loading && entry == null && error == null;
}

/// Cubit que carrega uma entrada do diário por id (detalhe / edição).
class EntryDetailCubit extends Cubit<EntryDetailState> {
  EntryDetailCubit(this._repository, this.entryId)
      : super(const EntryDetailState());

  final MealEntryRepository _repository;
  final String entryId;

  Future<void> load() async {
    emit(const EntryDetailState());
    try {
      final entry = await _repository.getById(entryId);
      emit(EntryDetailState(entry: entry, loading: false));
    } on Object catch (e) {
      emit(EntryDetailState(loading: false, error: e.toString()));
    }
  }
}
