import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/src/cubit/patients_state.dart';
import 'package:patients_feature/src/data/patients_repository.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit({
    required PatientsRepository repository,
    required AuthRepository authRepository,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
  })  : _repository = repository,
        _authRepository = authRepository,
        _analytics = analytics,
        _crashReporter = crashReporter,
        super(const PatientsState());

  final PatientsRepository _repository;
  final AuthRepository _authRepository;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;

  static String _patientCountBucket(int count) {
    if (count == 0) return '0';
    if (count <= 2) return '1_2';
    return '3plus';
  }

  void logPaywallInviteLimitSheet() {
    _analytics?.logPaywallView(source: 'invite_limit_sheet');
  }

  void logInviteFlowOpen() {
    _analytics?.logInviteFlowOpen(
      patientCountBucket: _patientCountBucket(state.patients.length),
    );
  }

  void logInviteShare({required String channel}) {
    _analytics?.logInviteShare(channel: channel);
  }
  StreamSubscription<dynamic>? _patientsSubscription;

  Future<void> load() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: PatientsStatus.error,
          error: 'not_logged_in',
        ),
      );
      return;
    }

    final wasAlreadyLoaded = state.status == PatientsStatus.loaded;
    if (wasAlreadyLoaded) {
      emit(state.copyWith(isRefreshing: true));
    } else {
      emit(state.copyWith(status: PatientsStatus.loading));
    }

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
              isRefreshing: false,
            ),
          );
        },
        onError: (Object error) {
          final message = error.toString();
          debugPrint(
            '[PatientsCubit] watchPatients stream error (pode ser Firestore '
            'snapshots em clinicians/uid/patients ou get em users/patientId): $message',
          );
          // Se já temos lista e o erro é permission-denied (ex.: revalidação ao
          // trocar de aba), mantemos os dados e não bloqueamos a UI.
          final isPermissionDenied = message.contains('permission-denied');
          final hasLoadedPatients =
              state.status == PatientsStatus.loaded &&
              state.patients.isNotEmpty;
          if (isPermissionDenied && hasLoadedPatients) {
            emit(state.copyWith(isRefreshing: false));
            return;
          }
          emit(
            state.copyWith(
              status: PatientsStatus.error,
              error: message,
              isRefreshing: false,
            ),
          );
        },
      );
    } on Object catch (e, st) {
      _crashReporter?.call(
        e,
        st,
        feature: 'patients',
        hint: 'load_list',
      );
      emit(
        state.copyWith(
          status: PatientsStatus.error,
          error: e.toString(),
          isRefreshing: false,
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
    } on Object catch (e, st) {
      _crashReporter?.call(
        e,
        st,
        feature: 'patients',
        hint: 'invite_code',
      );
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> removePatient(String patientId) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    try {
      await _repository.removePatient(user.uid, patientId);
      _analytics?.logPatientRemoveConfirm();
    } on Object catch (e, st) {
      _crashReporter?.call(
        e,
        st,
        feature: 'patients',
        hint: 'remove_patient',
      );
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _patientsSubscription?.cancel();
    return super.close();
  }
}
