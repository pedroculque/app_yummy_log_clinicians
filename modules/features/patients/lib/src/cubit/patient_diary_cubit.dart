import 'dart:async';

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
    emit(state.copyWith(
      status: PatientDiaryStatus.loading,
      patientId: patientId,
      patientName: patientName,
    ));

    try {
      await _subscription?.cancel();
      _subscription = _repository.watchMeals(patientId).listen(
        (entries) {
          emit(state.copyWith(
            status: PatientDiaryStatus.loaded,
            entries: entries,
          ));
        },
        onError: (Object error) {
          emit(state.copyWith(
            status: PatientDiaryStatus.error,
            error: error.toString(),
          ));
        },
      );
    } on Object catch (e) {
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
