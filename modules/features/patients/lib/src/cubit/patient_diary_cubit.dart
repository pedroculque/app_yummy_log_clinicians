import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_domain/meal_domain.dart';
import 'package:patients_feature/src/cubit/patient_diary_state.dart';
import 'package:patients_feature/src/data/patient_meals_repository.dart';

class PatientDiaryCubit extends Cubit<PatientDiaryState> {
  PatientDiaryCubit({
    required PatientMealsRepository repository,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
  })  : _repository = repository,
        _analytics = analytics,
        _crashReporter = crashReporter,
        super(const PatientDiaryState());

  final PatientMealsRepository _repository;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;

  /// Valores estáveis para GA4 (sem PII).
  static String mealTypeAnalyticsParam(MealType type) => switch (type) {
        MealType.breakfast => 'breakfast',
        MealType.lunch => 'lunch',
        MealType.dinner => 'dinner',
        MealType.supper => 'supper',
        MealType.morningSnack => 'morning_snack',
        MealType.afternoonSnack => 'afternoon_snack',
        MealType.eveningSnack => 'evening_snack',
      };

  void logDiaryMealOpen(MealType mealType) {
    _analytics?.logDiaryMealOpen(
      mealType: mealTypeAnalyticsParam(mealType),
    );
  }
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
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[PatientDiaryCubit] watchMeals error: $error');
          _crashReporter?.call(
            error,
            stackTrace,
            feature: 'patient_diary',
            hint: 'watch_meals',
          );
          emit(state.copyWith(
            status: PatientDiaryStatus.error,
            error: error.toString(),
          ));
        },
      );
      debugPrint('[PatientDiaryCubit] watchMeals subscription active');
    } on Object catch (e, st) {
      debugPrint('[PatientDiaryCubit] load failed: $e');
      _crashReporter?.call(
        e,
        st,
        feature: 'patient_diary',
        hint: 'load',
      );
      emit(state.copyWith(
        status: PatientDiaryStatus.error,
        error: e.toString(),
      ));
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
    } on Object catch (e, st) {
      debugPrint('[PatientDiaryCubit] refresh failed: $e');
      _crashReporter?.call(
        e,
        st,
        feature: 'patient_diary',
        hint: 'refresh',
      );
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
