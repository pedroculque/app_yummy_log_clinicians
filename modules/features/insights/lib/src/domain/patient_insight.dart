import 'package:diary_feature/diary_feature.dart';
import 'package:equatable/equatable.dart';
import 'package:insights_feature/src/domain/risk_alert.dart';
import 'package:patients_feature/patients_feature.dart';

class PatientInsight extends Equatable {
  const PatientInsight({
    required this.patient,
    required this.attentionScore,
    required this.mealsLast7Days,
    required this.mealsPrevious7Days,
    required this.mealsLast30Days,
    required this.alertsLast7Days,
    required this.alertsPrevious7Days,
    required this.feelingDistribution,
    required this.amountDistribution,
    required this.recentAlerts,
    required this.lastMealDate,
    required this.daysWithoutMeal,
  });

  final Patient patient;
  final int attentionScore;
  final int mealsLast7Days;
  final int mealsPrevious7Days;
  final int mealsLast30Days;
  final int alertsLast7Days;
  final int alertsPrevious7Days;
  final Map<FeelingLabel, int> feelingDistribution;
  final Map<AmountEaten, int> amountDistribution;
  final List<RiskAlert> recentAlerts;
  final DateTime? lastMealDate;
  final int daysWithoutMeal;

  bool get hasHighPriorityAlerts =>
      recentAlerts.any((a) => a.priority == RiskPriority.high);

  bool get hasMediumPriorityAlerts =>
      recentAlerts.any((a) => a.priority == RiskPriority.medium);

  bool get isInactive => daysWithoutMeal > 3;

  double get negativeFeelingsPercentage {
    final total = feelingDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return 0;
    final negative = (feelingDistribution[FeelingLabel.sad] ?? 0) +
        (feelingDistribution[FeelingLabel.angry] ?? 0);
    return negative / total * 100;
  }

  double get restrictionPercentage {
    final total = amountDistribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return 0;
    final restricted = (amountDistribution[AmountEaten.nothing] ?? 0) +
        (amountDistribution[AmountEaten.aLittle] ?? 0);
    return restricted / total * 100;
  }

  @override
  List<Object?> get props => [
        patient,
        attentionScore,
        mealsLast7Days,
        mealsPrevious7Days,
        mealsLast30Days,
        alertsLast7Days,
        alertsPrevious7Days,
        feelingDistribution,
        amountDistribution,
        recentAlerts,
        lastMealDate,
        daysWithoutMeal,
      ];
}
