import 'package:diary_feature/diary_feature.dart';
import 'package:equatable/equatable.dart';

enum PatientDiaryStatus { initial, loading, loaded, error }

class PatientDiaryState extends Equatable {
  const PatientDiaryState({
    this.status = PatientDiaryStatus.initial,
    this.entries = const [],
    this.error,
    this.patientId,
    this.patientName,
  });

  final PatientDiaryStatus status;
  final List<MealEntry> entries;
  final String? error;
  final String? patientId;
  final String? patientName;

  PatientDiaryState copyWith({
    PatientDiaryStatus? status,
    List<MealEntry>? entries,
    String? error,
    String? patientId,
    String? patientName,
  }) {
    return PatientDiaryState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      error: error ?? this.error,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
    );
  }

  bool get isEmpty => entries.isEmpty;

  @override
  List<Object?> get props => [status, entries, error, patientId, patientName];
}
