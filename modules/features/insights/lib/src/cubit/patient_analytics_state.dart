import 'package:insights_feature/src/domain/patient_analytics_data.dart';

class PatientAnalyticsState {
  const PatientAnalyticsState({
    this.isLoading = false,
    this.periodDays = 30,
    this.data,
    this.error,
  });

  const PatientAnalyticsState.initial()
      : isLoading = true,
        periodDays = 30,
        data = null,
        error = null;

  final bool isLoading;
  final int periodDays;
  final PatientAnalyticsData? data;
  final String? error;

  PatientAnalyticsState copyWith({
    bool? isLoading,
    int? periodDays,
    PatientAnalyticsData? data,
    String? error,
  }) {
    return PatientAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      periodDays: periodDays ?? this.periodDays,
      data: data ?? this.data,
      error: error,
    );
  }
}
