import 'package:equatable/equatable.dart';
import 'package:insights_feature/src/domain/insights_summary.dart';

enum InsightsStatus { initial, loading, loaded, error }

enum InsightsPeriod {
  days7(7),
  days30(30),
  days90(90);

  const InsightsPeriod(this.days);
  final int days;
}

class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsStatus.initial,
    this.summary = const InsightsSummary.empty(),
    this.errorMessage,
    this.period = InsightsPeriod.days7,
    this.lastUpdated,
  });

  final InsightsStatus status;
  final InsightsSummary summary;
  final String? errorMessage;
  final InsightsPeriod period;
  final DateTime? lastUpdated;

  bool get isLoading => status == InsightsStatus.loading;
  bool get isLoaded => status == InsightsStatus.loaded;
  bool get hasError => status == InsightsStatus.error;
  bool get isEmpty => summary.isEmpty;

  InsightsState copyWith({
    InsightsStatus? status,
    InsightsSummary? summary,
    String? errorMessage,
    InsightsPeriod? period,
    DateTime? lastUpdated,
  }) {
    return InsightsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
      period: period ?? this.period,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        summary,
        errorMessage,
        period,
        lastUpdated,
      ];
}
