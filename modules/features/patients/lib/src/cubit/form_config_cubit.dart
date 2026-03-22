import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/src/cubit/form_config_state.dart';
import 'package:patients_feature/src/data/behavior_form_config.dart';
import 'package:patients_feature/src/data/form_config_repository.dart';

class FormConfigCubit extends Cubit<FormConfigState> {
  FormConfigCubit({
    required FormConfigRepository repository,
    required AuthRepository authRepository,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
  })  : _repository = repository,
        _authRepository = authRepository,
        _analytics = analytics,
        _crashReporter = crashReporter,
        super(const FormConfigState());

  final FormConfigRepository _repository;
  final AuthRepository _authRepository;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;
  StreamSubscription<BehaviorFormConfig>? _subscription;
  Timer? _persistDebounce;

  /// Carrega a config do paciente e passa a observar alterações.
  Future<void> load({
    required String patientId,
    String patientName = '',
  }) async {
    emit(state.copyWith(
      status: FormConfigStatus.loading,
      patientId: patientId,
      patientName: patientName,
    ));

    await _subscription?.cancel();
    _subscription = _repository.watchFormConfig(patientId).listen(
      (config) {
        emit(state.copyWith(
          status: FormConfigStatus.loaded,
          config: config,
          clearError: true,
          clearSaveFailure: true,
        ));
      },
      onError: (Object e, StackTrace st) {
        _crashReporter?.call(
          e,
          st,
          feature: 'form_config',
          hint: 'watch',
        );
        emit(state.copyWith(
          status: FormConfigStatus.error,
          error: e.toString(),
        ));
      },
    );
  }

  void setSectionEnabled({required bool value}) {
    emit(state.copyWith(
      config: state.config.copyWith(sectionEnabled: value),
    ));
    _schedulePersist();
  }

  void setBehaviorEnabled(String behaviorId, {required bool value}) {
    final newBehaviors = Map<String, bool>.from(state.config.behaviors);
    newBehaviors[behaviorId] = value;
    emit(state.copyWith(
      config: state.config.copyWith(behaviors: newBehaviors),
    ));
    _schedulePersist();
  }

  static const _persistDebounceDuration = Duration(milliseconds: 550);

  void _schedulePersist() {
    if (state.status == FormConfigStatus.loading ||
        state.status == FormConfigStatus.initial) {
      return;
    }
    _persistDebounce?.cancel();
    _persistDebounce = Timer(_persistDebounceDuration, () {
      unawaited(save());
    });
  }

  /// Persiste a config no Firestore com o usuário atual no changeLog.
  Future<void> save() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: FormConfigStatus.error,
        error: 'not_logged_in',
        clearSaveFailure: true,
      ));
      return;
    }
    final patientId = state.patientId;
    if (patientId == null) return;

    emit(state.copyWith(
      status: FormConfigStatus.saving,
      clearSaveFailure: true,
    ));
    try {
      await _repository.saveFormConfig(
        patientId,
        state.config,
        clinicianUid: user.uid,
        clinicianDisplayName: user.displayName,
      );
      _analytics?.logFormConfigSave();
      emit(state.copyWith(status: FormConfigStatus.loaded));
    } on Object catch (e, st) {
      debugPrint('[FormConfigCubit] save failed: $e');
      debugPrint('[FormConfigCubit] stack: $st');
      _crashReporter?.call(
        e,
        st,
        feature: 'form_config',
        hint: 'save',
      );
      emit(state.copyWith(
        status: FormConfigStatus.loaded,
        saveFailure: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    _persistDebounce?.cancel();
    await _subscription?.cancel();
    await super.close();
  }
}
