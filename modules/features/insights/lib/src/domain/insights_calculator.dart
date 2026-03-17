import 'package:diary_feature/diary_feature.dart';
import 'package:insights_feature/src/domain/insights_summary.dart';
import 'package:insights_feature/src/domain/patient_insight.dart';
import 'package:insights_feature/src/domain/risk_alert.dart';
import 'package:patients_feature/patients_feature.dart';

class InsightsCalculator {
  static InsightsSummary calculate({
    required List<Patient> patients,
    required Map<String, List<MealEntry>> mealsByPatient,
    int periodDays = 7,
  }) {
    if (patients.isEmpty) {
      return const InsightsSummary.empty();
    }

    final now = DateTime.now();
    final periodStart = now.subtract(Duration(days: periodDays));

    final patientInsights = <PatientInsight>[];
    final allAlerts = <RiskAlert>[];
    var totalMealsPeriod = 0;
    var activePatients = 0;

    for (final patient in patients) {
      final meals = mealsByPatient[patient.id] ?? [];
      final mealsInPeriod =
          meals.where((m) => m.dateTime.isAfter(periodStart)).toList();
      final mealsLast30Days =
          meals.where((m) => m.dateTime.isAfter(now.subtract(const Duration(days: 30)))).toList();

      totalMealsPeriod += mealsInPeriod.length;

      if (mealsInPeriod.isNotEmpty) {
        activePatients++;
      }

      final alerts = _extractAlerts(patient, mealsInPeriod);
      allAlerts.addAll(alerts);

      final feelingDist = _calculateFeelingDistribution(mealsInPeriod);
      final amountDist = _calculateAmountDistribution(mealsInPeriod);

      final lastMealDate = meals.isNotEmpty ? meals.first.dateTime : null;
      final daysWithoutMeal = lastMealDate != null
          ? now.difference(lastMealDate).inDays
          : patient.linkedAt != null
              ? now.difference(patient.linkedAt!).inDays
              : 999;

      final attentionScore = _calculateAttentionScore(
        mealsInPeriod: mealsInPeriod,
        alerts: alerts,
        daysWithoutMeal: daysWithoutMeal,
        periodDays: periodDays,
      );

      patientInsights.add(
        PatientInsight(
          patient: patient,
          attentionScore: attentionScore,
          mealsLast7Days: mealsInPeriod.length,
          mealsLast30Days: mealsLast30Days.length,
          alertsLast7Days: alerts.length,
          feelingDistribution: feelingDist,
          amountDistribution: amountDist,
          recentAlerts: alerts,
          lastMealDate: lastMealDate,
          daysWithoutMeal: daysWithoutMeal,
        ),
      );
    }

    allAlerts.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return InsightsSummary(
      totalPatients: patients.length,
      activePatients: activePatients,
      totalMealsThisWeek: totalMealsPeriod,
      totalAlerts: allAlerts.length,
      recentAlerts: allAlerts.take(20).toList(),
      patientInsights: patientInsights,
    );
  }

  static List<RiskAlert> _extractAlerts(
    Patient patient,
    List<MealEntry> meals,
  ) {
    final alerts = <RiskAlert>[];

    for (final meal in meals) {
      if (meal.forcedVomit == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.forcedVomit,
            dateTime: meal.dateTime,
            priority: RiskPriority.high,
            mealId: meal.id,
          ),
        );
      }

      if (meal.usedLaxatives == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.usedLaxatives,
            dateTime: meal.dateTime,
            priority: RiskPriority.high,
            mealId: meal.id,
          ),
        );
      }

      if (meal.diuretics == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.diuretics,
            dateTime: meal.dateTime,
            priority: RiskPriority.high,
            mealId: meal.id,
          ),
        );
      }

      if (meal.regurgitated == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.regurgitated,
            dateTime: meal.dateTime,
            priority: RiskPriority.medium,
            mealId: meal.id,
          ),
        );
      }

      if (meal.hiddenFood == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.hiddenFood,
            dateTime: meal.dateTime,
            priority: RiskPriority.medium,
            mealId: meal.id,
          ),
        );
      }

      if (meal.ateInSecret == true) {
        alerts.add(
          RiskAlert(
            patientId: patient.id,
            patientName: patient.name,
            type: RiskType.ateInSecret,
            dateTime: meal.dateTime,
            priority: RiskPriority.low,
            mealId: meal.id,
          ),
        );
      }
    }

    return alerts;
  }

  static Map<FeelingLabel, int> _calculateFeelingDistribution(
    List<MealEntry> meals,
  ) {
    final distribution = <FeelingLabel, int>{};
    for (final feeling in FeelingLabel.values) {
      distribution[feeling] = 0;
    }

    for (final meal in meals) {
      if (meal.feelingLabel != null) {
        distribution[meal.feelingLabel!] =
            (distribution[meal.feelingLabel!] ?? 0) + 1;
      }
    }

    return distribution;
  }

  static Map<AmountEaten, int> _calculateAmountDistribution(
    List<MealEntry> meals,
  ) {
    final distribution = <AmountEaten, int>{};
    for (final amount in AmountEaten.values) {
      distribution[amount] = 0;
    }

    for (final meal in meals) {
      if (meal.amountEaten != null) {
        distribution[meal.amountEaten!] =
            (distribution[meal.amountEaten!] ?? 0) + 1;
      }
    }

    return distribution;
  }

  static int _calculateAttentionScore({
    required List<MealEntry> mealsInPeriod,
    required List<RiskAlert> alerts,
    required int daysWithoutMeal,
    required int periodDays,
  }) {
    var score = 0;

    for (final alert in alerts) {
      switch (alert.priority) {
        case RiskPriority.high:
          score += 10;
        case RiskPriority.medium:
          score += 5;
        case RiskPriority.low:
          score += 3;
      }
    }

    for (final meal in mealsInPeriod) {
      if (meal.feelingLabel == FeelingLabel.sad) score += 2;
      if (meal.feelingLabel == FeelingLabel.angry) score += 2;

      if (meal.amountEaten == AmountEaten.nothing) score += 3;
      if (meal.amountEaten == AmountEaten.aLittle) score += 1;
    }

    if (mealsInPeriod.length < periodDays) score += 5;

    if (daysWithoutMeal > 3) score += 10;
    if (daysWithoutMeal > 7) score += 10;

    return score;
  }
}
