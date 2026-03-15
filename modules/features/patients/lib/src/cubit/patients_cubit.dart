import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:patients_feature/src/cubit/patients_state.dart';
import 'package:patients_feature/src/data/patients_repository.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit({
    required PatientsRepository repository,
    required AuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const PatientsState());

  final PatientsRepository _repository;
  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _patientsSubscription;

  Future<void> load() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: PatientsStatus.error,
          error: 'Not logged in',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PatientsStatus.loading));

    try {
      final inviteCode = await _repository.getInviteCode(user.uid);

      await _patientsSubscription?.cancel();
      _patientsSubscription = _repository.watchPatients(user.uid).listen(
        (patients) {
          emit(
            state.copyWith(
              status: PatientsStatus.loaded,
              patients: patients,
              inviteCode: inviteCode,
            ),
          );
        },
        onError: (Object error) {
          emit(
            state.copyWith(
              status: PatientsStatus.error,
              error: error.toString(),
            ),
          );
        },
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: PatientsStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> generateInviteCode() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      final code = await _repository.generateInviteCode(
        user.uid,
        user.displayName,
      );
      emit(state.copyWith(inviteCode: code));
    } on Object catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _patientsSubscription?.cancel();
    return super.close();
  }
}
