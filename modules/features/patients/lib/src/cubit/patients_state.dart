import 'package:equatable/equatable.dart';
import 'package:patients_feature/src/data/patient.dart';

enum PatientsStatus { initial, loading, loaded, error }

class PatientsState extends Equatable {
  const PatientsState({
    this.status = PatientsStatus.initial,
    this.patients = const [],
    this.inviteCode,
    this.error,
    this.isRefreshing = false,
  });

  final PatientsStatus status;
  final List<Patient> patients;
  final String? inviteCode;
  final String? error;
  /// True quando está atualizando em background (sync pelo ícone),
  /// sem tela cheia de loading.
  final bool isRefreshing;

  bool get isEmpty => patients.isEmpty;
  bool get hasPatients => patients.isNotEmpty;

  PatientsState copyWith({
    PatientsStatus? status,
    List<Patient>? patients,
    String? inviteCode,
    String? error,
    bool? isRefreshing,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      inviteCode: inviteCode ?? this.inviteCode,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        inviteCode,
        error,
        isRefreshing,
      ];
}
