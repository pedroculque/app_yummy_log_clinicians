import 'package:meal_domain/meal_domain.dart';

/// Comparativo temporal: período atual vs anterior (Fase 3.3).
class TrendComparison {
  const TrendComparison({
    required this.currentTotal,
    required this.previousTotal,
    required this.currentAvgPerDay,
    required this.previousAvgPerDay,
    required this.periodDays,
  });

  final int currentTotal;
  final int previousTotal;
  final double currentAvgPerDay;
  final double previousAvgPerDay;
  final int periodDays;

  int get totalDelta => currentTotal - previousTotal;
  double get avgDelta => currentAvgPerDay - previousAvgPerDay;

  bool get isImproving => totalDelta > 0;
  bool get isWorsening => totalDelta < 0;
  bool get isStable => totalDelta == 0;
}

/// Dados agregados para análises por paciente (Fase 3.2 + 3.3).
class PatientAnalyticsData {
  const PatientAnalyticsData({
    required this.feelingDistribution,
    required this.amountDistribution,
    required this.dailyMealCounts,
    required this.mealsPerDayAverage,
    required this.periodDays,
    required this.totalMeals,
    this.mealTypeDistribution = const {},
    this.skippedMealsByType = const {},
    this.skippedMealsFeelingCorrelation = const {},
    this.trendComparison,
  });

  final Map<FeelingLabel, int> feelingDistribution;
  final Map<AmountEaten, int> amountDistribution;
  final Map<DateTime, int> dailyMealCounts;
  final double mealsPerDayAverage;
  final int periodDays;
  final int totalMeals;
  final Map<MealType, int> mealTypeDistribution;
  final Map<MealType, int> skippedMealsByType;
  final Map<FeelingLabel, int> skippedMealsFeelingCorrelation;
  final TrendComparison? trendComparison;

  bool get hasFeelingData =>
      feelingDistribution.values.any((v) => v > 0);

  bool get hasAmountData =>
      amountDistribution.values.any((v) => v > 0);

  bool get hasFrequencyData => dailyMealCounts.isNotEmpty;

  bool get hasMealTypeData =>
      mealTypeDistribution.values.any((v) => v > 0);

  bool get hasSkippedMealsData =>
      skippedMealsByType.values.any((v) => v > 0);

  bool get hasSkippedFeelingCorrelation =>
      skippedMealsFeelingCorrelation.values.any((v) => v > 0);

  bool get hasTrendData => trendComparison != null;
}
