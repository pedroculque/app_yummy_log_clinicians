import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:insights_feature/src/cubit/patient_analytics_state.dart';
import 'package:insights_feature/src/domain/insights_calculator.dart';
import 'package:insights_feature/src/domain/patient_analytics_data.dart';
import 'package:meal_domain/meal_domain.dart';
import 'package:patients_feature/patients_feature.dart';

class PatientAnalyticsCubit {
  PatientAnalyticsCubit({
    required String patientId,
    required PatientMealsRepository mealsRepository,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
  })  : _patientId = patientId,
        _mealsRepository = mealsRepository,
        _analytics = analytics,
        _crashReporter = crashReporter;

  final String _patientId;
  final PatientMealsRepository _mealsRepository;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;

  PatientAnalyticsState _state = const PatientAnalyticsState.initial();
  PatientAnalyticsState get state => _state;

  static const List<int> _periodOptions = [7, 30, 90];

  int get periodDays => _state.periodDays;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  final List<VoidCallback> _listeners = [];

  void _emit() {
    for (final l in _listeners) {
      l();
    }
  }

  Future<void> load({int? periodDays}) async {
    final period = periodDays ?? _state.periodDays;
    if (!_periodOptions.contains(period)) return;

    _state = _state.copyWith(isLoading: true);
    _emit();

    try {
      final meals = await _mealsRepository.getMeals(_patientId);
      final now = DateTime.now();
      final periodStart = now.subtract(Duration(days: period));
      final previousPeriodStart = now.subtract(Duration(days: period * 2));

      final mealsInPeriod = meals
          .where((m) =>
              m.deletedAt == null &&
              m.dateTime.isAfter(periodStart) &&
              m.dateTime.isBefore(now.add(const Duration(days: 1))))
          .toList();

      final mealsPreviousPeriod = meals
          .where((m) =>
              m.deletedAt == null &&
              m.dateTime.isAfter(previousPeriodStart) &&
              m.dateTime.isBefore(periodStart))
          .toList();

      final feelingDist =
          InsightsCalculator.calculateFeelingDistribution(mealsInPeriod);
      final amountDist =
          InsightsCalculator.calculateAmountDistribution(mealsInPeriod);
      final dailyCounts = _computeDailyMealCounts(mealsInPeriod);
      final avg = mealsInPeriod.isEmpty
          ? 0.0
          : mealsInPeriod.length / period;
      final prevAvg = mealsPreviousPeriod.isEmpty
          ? 0.0
          : mealsPreviousPeriod.length / period;

      final mealTypeDist =
          InsightsCalculator.calculateMealTypeDistribution(mealsInPeriod);
      final skippedByType =
          InsightsCalculator.calculateSkippedMealsByType(mealsInPeriod);
      final skippedFeelingCorr =
          InsightsCalculator.calculateSkippedMealsFeelingCorrelation(
            mealsInPeriod,
          );

      final trend = TrendComparison(
        currentTotal: mealsInPeriod.length,
        previousTotal: mealsPreviousPeriod.length,
        currentAvgPerDay: double.parse(avg.toStringAsFixed(1)),
        previousAvgPerDay: double.parse(prevAvg.toStringAsFixed(1)),
        periodDays: period,
      );

      _state = PatientAnalyticsState(
        periodDays: period,
        data: PatientAnalyticsData(
          feelingDistribution: feelingDist,
          amountDistribution: amountDist,
          dailyMealCounts: dailyCounts,
          mealsPerDayAverage: double.parse(avg.toStringAsFixed(1)),
          periodDays: period,
          totalMeals: mealsInPeriod.length,
          mealTypeDistribution: mealTypeDist,
          skippedMealsByType: skippedByType,
          skippedMealsFeelingCorrelation: skippedFeelingCorr,
          trendComparison: trend,
        ),
      );
    } on Object catch (e, st) {
      debugPrint('[PatientAnalyticsCubit] load error: $e\n$st');
      _crashReporter?.call(
        e,
        st,
        feature: 'patient_analytics',
        hint: 'load',
      );
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    _emit();
  }

  Future<void> changePeriod(int periodDays) async {
    if (!_periodOptions.contains(periodDays)) return;
    await load(periodDays: periodDays);
    _analytics?.logInsightsPeriodSet(days: periodDays);
  }

  Map<DateTime, int> _computeDailyMealCounts(List<MealEntry> meals) {
    final map = <DateTime, int>{};
    for (final m in meals) {
      final date = DateTime(m.dateTime.year, m.dateTime.month, m.dateTime.day);
      map[date] = (map[date] ?? 0) + 1;
    }
    return map;
  }
}
