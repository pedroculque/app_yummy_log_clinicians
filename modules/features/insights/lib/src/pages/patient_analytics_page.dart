import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/src/cubit/patient_analytics_cubit.dart';
import 'package:insights_feature/src/domain/patient_analytics_data.dart';
import 'package:meal_domain/meal_domain.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PatientAnalyticsPage extends StatefulWidget {
  const PatientAnalyticsPage({
    required this.patientId,
    required this.patientName,
    required this.cubit,
    super.key,
  });

  final String patientId;
  final String patientName;
  final PatientAnalyticsCubit cubit;

  @override
  State<PatientAnalyticsPage> createState() => _PatientAnalyticsPageState();
}

class _PatientAnalyticsPageState extends State<PatientAnalyticsPage> {
  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) setState(() {});
    };
    widget.cubit.addListener(_listener!);
    unawaited(widget.cubit.load());
  }

  @override
  void dispose() {
    if (_listener != null) {
      widget.cubit.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor:
          isDark ? colorScheme.surface : appColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor:
            isDark ? colorScheme.surface : appColors.backgroundDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? colorScheme.onSurface : appColors.neutralBlack,
          ),
        ),
        title: Text(
          widget.patientName,
          style: AppTextStyles.h4.copyWith(
            color: isDark ? colorScheme.onSurface : appColors.neutralBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openDiary(context),
            icon: Icon(
              Icons.menu_book_outlined,
              size: 18,
              color: appColors.primary,
            ),
            label: Text(
              l10n.insightsViewDiary,
              style: AppTextStyles.body3.copyWith(
                color: appColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(appColors, isDark, colorScheme, l10n),
    );
  }

  PatientAnalyticsCubit get _cubit => widget.cubit;

  Widget _buildBody(
    AppColors appColors,
    bool isDark,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final state = _cubit.state;

    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: appColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.somethingWentWrong,
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? colorScheme.onSurface
                      : appColors.neutralBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: AppTextStyles.body2.copyWith(
                  color: appColors.grayDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _cubit.load(),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _cubit.load(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PeriodSelector(
            periodDays: state.periodDays,
            onPeriodChanged: (p) => _cubit.changePeriod(p),
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
          if (data.totalMeals == 0)
            _EmptyAnalytics(appColors: appColors, l10n: l10n)
          else ...[
            _SummaryCard(
              totalMeals: data.totalMeals,
              mealsPerDay: data.mealsPerDayAverage,
              periodDays: data.periodDays,
              appColors: appColors,
              l10n: l10n,
            ),
            const SizedBox(height: 20),
            if (data.hasTrendData) ...[
              _TrendComparisonSection(
                trend: data.trendComparison!,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
            ],
            if (data.hasFeelingData) ...[
              _FeelingDistributionSection(
                distribution: data.feelingDistribution,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
            ],
            if (data.hasAmountData) ...[
              _AmountDistributionSection(
                distribution: data.amountDistribution,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
            ],
            if (data.hasSkippedMealsData) ...[
              _SkippedMealsSection(
                skippedByType: data.skippedMealsByType,
                mealTypeDistribution: data.mealTypeDistribution,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
            ],
            if (data.hasSkippedFeelingCorrelation) ...[
              _SkippedFeelingCorrelationSection(
                distribution: data.skippedMealsFeelingCorrelation,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 20),
            ],
            if (data.hasFrequencyData) ...[
              _FrequencyHeatMapSection(
                dailyCounts: data.dailyMealCounts,
                periodDays: data.periodDays,
                appColors: appColors,
                l10n: l10n,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _openDiary(BuildContext context) {
    unawaited(
      context.push(
        '/patients/${widget.patientId}/diary'
        '?name=${Uri.encodeComponent(widget.patientName)}',
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periodDays,
    required this.onPeriodChanged,
    required this.appColors,
    required this.l10n,
  });

  final int periodDays;
  final ValueChanged<int> onPeriodChanged;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            days: 7,
            label: l10n.insightsPeriod7Days,
            isSelected: periodDays == 7,
            onTap: () => onPeriodChanged(7),
            appColors: appColors,
          ),
          _PeriodChip(
            days: 30,
            label: l10n.insightsPeriod30Days,
            isSelected: periodDays == 30,
            onTap: () => onPeriodChanged(30),
            appColors: appColors,
          ),
          _PeriodChip(
            days: 90,
            label: l10n.insightsPeriod90Days,
            isSelected: periodDays == 90,
            onTap: () => onPeriodChanged(90),
            appColors: appColors,
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.days,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.appColors,
  });

  final int days;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.body3.copyWith(
            color: isSelected ? Colors.white : appColors.gray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalMeals,
    required this.mealsPerDay,
    required this.periodDays,
    required this.appColors,
    required this.l10n,
  });

  final int totalMeals;
  final double mealsPerDay;
  final int periodDays;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalMeals',
                  style: AppTextStyles.h2.copyWith(color: appColors.primary),
                ),
                Text(
                  l10n.insightsMealsPeriod,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mealsPerDay.toStringAsFixed(1),
                style: AppTextStyles.h2.copyWith(color: appColors.secondary),
              ),
              Text(
                l10n.insightsAnalyticsMealsPerDay,
                style: AppTextStyles.body3.copyWith(
                  color: appColors.grayDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendComparisonSection extends StatelessWidget {
  const _TrendComparisonSection({
    required this.trend,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final TrendComparison trend;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final delta = trend.totalDelta;
    final deltaLabel = delta > 0
        ? l10n.insightsAnalyticsTrendDeltaUp(delta)
        : delta < 0
            ? l10n.insightsAnalyticsTrendDeltaDown(delta)
            : '0';

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsTrendTitle,
      subtitle: l10n.insightsAnalyticsTrendSubtitle,
      icon: Icons.trending_up_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${trend.previousTotal}',
                  style: AppTextStyles.h2.copyWith(
                    color: appColors.gray.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  l10n.insightsAnalyticsTrendPrevious,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
                Text(
                  trend.previousAvgPerDay.toStringAsFixed(1),
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: appColors.primary,
            size: 24,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${trend.currentTotal}',
                  style: AppTextStyles.h2.copyWith(
                    color: appColors.primary,
                  ),
                ),
                Text(
                  l10n.insightsAnalyticsTrendCurrent,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
                Text(
                  trend.currentAvgPerDay.toStringAsFixed(1),
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: trend.isImproving
                  ? appColors.success.withValues(alpha: 0.15)
                  : trend.isWorsening
                      ? appColors.error.withValues(alpha: 0.15)
                      : appColors.gray.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              deltaLabel,
              style: AppTextStyles.body1.copyWith(
                color: trend.isImproving
                    ? appColors.success
                    : trend.isWorsening
                        ? appColors.error
                        : appColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkippedMealsSection extends StatelessWidget {
  const _SkippedMealsSection({
    required this.skippedByType,
    required this.mealTypeDistribution,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final Map<MealType, int> skippedByType;
  final Map<MealType, int> mealTypeDistribution;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final entries = MealType.values
        .map((t) => MapEntry(t, skippedByType[t] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const SizedBox.shrink();

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsSkippedTitle,
      subtitle: l10n.insightsAnalyticsSkippedSubtitle,
      icon: Icons.skip_next_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Column(
        children: entries.map((e) {
          final total = mealTypeDistribution[e.key] ?? 0;
          final pct = total > 0
              ? ((e.value / total) * 100).toStringAsFixed(0)
              : '0';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DistributionBar(
              label: mealTypeLabel(e.key, l10n),
              value: e.value,
              percent: pct,
              color: appColors.error.withValues(alpha: 0.8),
              appColors: appColors,
              total: entries.fold(0, (a, x) => a + x.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SkippedFeelingCorrelationSection extends StatelessWidget {
  const _SkippedFeelingCorrelationSection({
    required this.distribution,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final Map<FeelingLabel, int> distribution;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final entries = FeelingLabel.values
        .map((f) => MapEntry(f, distribution[f] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsSkippedFeelingTitle,
      subtitle: l10n.insightsAnalyticsSkippedFeelingSubtitle,
      icon: Icons.psychology_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Column(
        children: entries.map((e) {
          final pct = (e.value / total * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DistributionBar(
              label: feelingLabel(e.key, l10n),
              value: e.value,
              percent: pct,
              color: _feelingColor(e.key),
              appColors: appColors,
              total: total,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _feelingColor(FeelingLabel f) {
    switch (f) {
      case FeelingLabel.sad:
        return Colors.indigo;
      case FeelingLabel.angry:
        return Colors.red;
      case FeelingLabel.happy:
        return Colors.green;
      case FeelingLabel.proud:
        return Colors.amber.shade700;
      case FeelingLabel.nothing:
        return appColors.gray;
    }
  }
}

class _FeelingDistributionSection extends StatelessWidget {
  const _FeelingDistributionSection({
    required this.distribution,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final Map<FeelingLabel, int> distribution;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final entries = FeelingLabel.values
        .map((f) => MapEntry(f, distribution[f] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsFeelingsTitle,
      subtitle: l10n.insightsAnalyticsFeelingsSubtitle,
      icon: Icons.sentiment_satisfied_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Column(
        children: entries.map((e) {
          final pct = (e.value / total * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DistributionBar(
              label: feelingLabel(e.key, l10n),
              value: e.value,
              percent: pct,
              color: _feelingColor(e.key),
              appColors: appColors,
              total: total,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _feelingColor(FeelingLabel f) {
    switch (f) {
      case FeelingLabel.sad:
        return Colors.indigo;
      case FeelingLabel.angry:
        return Colors.red;
      case FeelingLabel.happy:
        return Colors.green;
      case FeelingLabel.proud:
        return Colors.amber.shade700;
      case FeelingLabel.nothing:
        return appColors.gray;
    }
  }
}

class _AmountDistributionSection extends StatelessWidget {
  const _AmountDistributionSection({
    required this.distribution,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final Map<AmountEaten, int> distribution;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final order = [
      AmountEaten.nothing,
      AmountEaten.aLittle,
      AmountEaten.half,
      AmountEaten.most,
      AmountEaten.all,
    ];
    final entries = order
        .map((a) => MapEntry(a, distribution[a] ?? 0))
        .where((e) => e.value > 0)
        .toList();

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsAmountTitle,
      subtitle: l10n.insightsAnalyticsAmountSubtitle,
      icon: Icons.restaurant_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Column(
        children: entries.map((e) {
          final pct = (e.value / total * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DistributionBar(
              label: amountEatenLabel(e.key, l10n),
              value: e.value,
              percent: pct,
              color: _amountColor(e.key),
              appColors: appColors,
              total: total,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _amountColor(AmountEaten a) {
    switch (a) {
      case AmountEaten.nothing:
        return appColors.error;
      case AmountEaten.aLittle:
        return Colors.orange;
      case AmountEaten.half:
        return Colors.amber.shade700;
      case AmountEaten.most:
        return appColors.secondary;
      case AmountEaten.all:
        return appColors.success;
    }
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.appColors,
    required this.total,
  });

  final String label;
  final int value;
  final String percent;
  final Color color;
  final AppColors appColors;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.body3.copyWith(
                color: appColors.neutralBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value ($percent%)',
              style: AppTextStyles.body3.copyWith(
                color: appColors.grayDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _FrequencyHeatMapSection extends StatelessWidget {
  const _FrequencyHeatMapSection({
    required this.dailyCounts,
    required this.periodDays,
    required this.appColors,
    required this.l10n,
    required this.isDark,
    required this.colorScheme,
  });

  final Map<DateTime, int> dailyCounts;
  final int periodDays;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: periodDays));
    final maxCount = dailyCounts.values.fold(0, (a, b) => a > b ? a : b);
    const cellSize = 14.0;
    const columns = 7;

    return _AnalyticsSection(
      title: l10n.insightsAnalyticsFrequencyTitle,
      subtitle: l10n.insightsAnalyticsFrequencySubtitle,
      icon: Icons.calendar_month_outlined,
      appColors: appColors,
      isDark: isDark,
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.insightsAnalyticsHeatMapMin,
                style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
              ),
              Text(
                l10n.insightsAnalyticsHeatMapMax,
                style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: columns * (cellSize + 4),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(periodDays, (i) {
                final date = start.add(Duration(days: i));
                final dateOnly =
                    DateTime(date.year, date.month, date.day);
                final count = dailyCounts[dateOnly] ?? 0;
                final intensity = maxCount > 0 ? count / maxCount : 0.0;
                return _HeatMapCell(
                  size: cellSize,
                  intensity: intensity,
                  count: count,
                  appColors: appColors,
                  isDark: isDark,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatMapCell extends StatelessWidget {
  const _HeatMapCell({
    required this.size,
    required this.intensity,
    required this.count,
    required this.appColors,
    required this.isDark,
  });

  final double size;
  final double intensity;
  final int count;
  final AppColors appColors;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = count == 0
        ? (isDark
            ? appColors.gray.withValues(alpha: 0.2)
            : appColors.gray.withValues(alpha: 0.12))
        : appColors.primary.withValues(
            alpha: 0.2 + 0.6 * intensity.clamp(0.0, 1.0),
          );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    required this.appColors,
    required this.isDark,
    required this.colorScheme,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final AppColors appColors;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : appColors.backgroundDefault,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? appColors.primary.withValues(alpha: 0.22)
              : appColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: appColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? colorScheme.onSurface
                      : appColors.neutralBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body3.copyWith(
              color: appColors.grayDark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics({required this.appColors, required this.l10n});

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: appColors.gray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.insightsAnalyticsEmpty,
            style: AppTextStyles.body1.copyWith(
              color: appColors.grayDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
