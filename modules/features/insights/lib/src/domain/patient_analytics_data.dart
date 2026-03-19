import 'package:meal_domain/meal_domain.dart';

/// Dados agregados para análises por paciente (Fase 3.2).
class PatientAnalyticsData {
  const PatientAnalyticsData({
    required this.feelingDistribution,
    required this.amountDistribution,
    required this.dailyMealCounts,
    required this.mealsPerDayAverage,
    required this.periodDays,
    required this.totalMeals,
  });

  final Map<FeelingLabel, int> feelingDistribution;
  final Map<AmountEaten, int> amountDistribution;
  final Map<DateTime, int> dailyMealCounts;
  final double mealsPerDayAverage;
  final int periodDays;
  final int totalMeals;

  bool get hasFeelingData =>
      feelingDistribution.values.any((v) => v > 0);

  bool get hasAmountData =>
      amountDistribution.values.any((v) => v > 0);

  bool get hasFrequencyData => dailyMealCounts.isNotEmpty;
}
