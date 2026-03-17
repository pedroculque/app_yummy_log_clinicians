import 'package:equatable/equatable.dart';
import 'package:insights_feature/src/domain/patient_insight.dart';
import 'package:insights_feature/src/domain/risk_alert.dart';

class InsightsSummary extends Equatable {
  const InsightsSummary({
    required this.totalPatients,
    required this.activePatients,
    required this.totalMealsThisWeek,
    required this.totalAlerts,
    required this.recentAlerts,
    required this.patientInsights,
  });

  const InsightsSummary.empty()
    : totalPatients = 0,
      activePatients = 0,
      totalMealsThisWeek = 0,
      totalAlerts = 0,
      recentAlerts = const [],
      patientInsights = const [];

  final int totalPatients;
  final int activePatients;
  final int totalMealsThisWeek;
  final int totalAlerts;
  final List<RiskAlert> recentAlerts;
  final List<PatientInsight> patientInsights;

  double get activePercentage =>
      totalPatients > 0 ? activePatients / totalPatients * 100 : 0;

  List<PatientInsight> get patientsNeedingAttention =>
      patientInsights.where((p) => p.attentionScore > 0).toList()
        ..sort((a, b) => b.attentionScore.compareTo(a.attentionScore));

  List<RiskAlert> get highPriorityAlerts =>
      recentAlerts.where((a) => a.priority == RiskPriority.high).toList();

  int get patientsReviewToday => patientInsights
      .where((p) => p.clinicalAction == ClinicalAction.reviewToday)
      .length;

  int get patientsReviewSoon => patientInsights
      .where((p) => p.clinicalAction == ClinicalAction.reviewSoon)
      .length;

  int get stablePatients => patientInsights
      .where((p) => p.clinicalAction == ClinicalAction.stable)
      .length;

  int get worseningPatients =>
      patientInsights.where((p) => p.isWorsening).length;

  int get improvingPatients =>
      patientInsights.where((p) => p.isImproving).length;

  int get inactivePatients => patientInsights.where((p) => p.isInactive).length;

  int get highRiskPatients =>
      patientInsights.where((p) => p.hasHighPriorityAlerts).length;

  bool get hasAlerts => totalAlerts > 0;

  bool get isEmpty => totalPatients == 0;

  @override
  List<Object?> get props => [
    totalPatients,
    activePatients,
    totalMealsThisWeek,
    totalAlerts,
    recentAlerts,
    patientInsights,
  ];
}
