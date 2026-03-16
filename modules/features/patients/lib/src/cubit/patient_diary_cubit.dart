import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patients_feature/src/cubit/patient_diary_state.dart';
import 'package:patients_feature/src/data/patient_meals_repository.dart';

class PatientDiaryCubit extends Cubit<PatientDiaryState> {
  PatientDiaryCubit({
    required PatientMealsRepository repository,
  })  : _repository = repository,
        super(const PatientDiaryState());

  final PatientMealsRepository _repository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> load({
    required String patientId,
    required String patientName,
  }) async {
    debugPrint(
      '[PatientDiaryCubit] load(patientId=$patientId, '
      'patientName=$patientName)',
    );
    emit(state.copyWith(
      status: PatientDiaryStatus.loading,
      patientId: patientId,
      patientName: patientName,
    ));

    try {
      await _subscription?.cancel();
      _subscription = _repository.watchMeals(patientId).listen(
        (entries) {
          debugPrint(
            '[PatientDiaryCubit] watchMeals received ${entries.length} entries',
          );
          emit(state.copyWith(
            status: PatientDiaryStatus.loaded,
            entries: entries,
          ));
        },
        onError: (Object error) {
          debugPrint('[PatientDiaryCubit] watchMeals error: $error');
          emit(state.copyWith(
            status: PatientDiaryStatus.error,
            error: error.toString(),
          ));
        },
      );
      debugPrint('[PatientDiaryCubit] watchMeals subscription active');
    } on Object catch (e) {
      debugPrint('[PatientDiaryCubit] load failed: $e');
      emit(state.copyWith(
        status: PatientDiaryStatus.error,
        error: e.toString(),
      )      );
    }
  }

  /// Atualiza a lista de refeições buscando direto do servidor (evita cache).
  Future<void> refresh() async {
    final patientId = state.patientId;
    final patientName = state.patientName;
    if (patientId == null || patientName == null) return;
    debugPrint('[PatientDiaryCubit] refresh(patientId=$patientId)');
    try {
      final entries = await _repository.getMeals(
        patientId,
        source: Source.server,
      );
      debugPrint(
        '[PatientDiaryCubit] refresh received ${entries.length} entries '
        'from server',
      );
      emit(state.copyWith(
        status: PatientDiaryStatus.loaded,
        entries: entries,
      ));
    } on Object catch (e) {
      debugPrint('[PatientDiaryCubit] refresh failed: $e');
      emit(state.copyWith(
        status: PatientDiaryStatus.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
