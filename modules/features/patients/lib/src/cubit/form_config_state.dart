import 'package:equatable/equatable.dart';
import 'package:patients_feature/src/data/behavior_form_config.dart';

enum FormConfigStatus { initial, loading, loaded, saving, error }

class FormConfigState extends Equatable {
  const FormConfigState({
    this.status = FormConfigStatus.initial,
    this.config = const BehaviorFormConfig(),
    this.error,
    this.patientId,
    this.patientName,
  });

  final FormConfigStatus status;
  final BehaviorFormConfig config;
  final String? error;
  final String? patientId;
  final String? patientName;

  FormConfigState copyWith({
    FormConfigStatus? status,
    BehaviorFormConfig? config,
    String? error,
    String? patientId,
    String? patientName,
  }) {
    return FormConfigState(
      status: status ?? this.status,
      config: config ?? this.config,
      error: error,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
    );
  }

  @override
  List<Object?> get props => [status, config, error, patientId, patientName];
}
