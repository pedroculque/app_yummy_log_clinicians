import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/src/cubit/insights_cubit.dart';
import 'package:insights_feature/src/cubit/insights_state.dart';
import 'package:insights_feature/src/domain/insights_summary.dart';
import 'package:insights_feature/src/domain/patient_insight.dart';
import 'package:insights_feature/src/domain/risk_alert.dart';
import 'package:intl/intl.dart';
import 'package:patients_feature/patients_feature.dart'
    show trackActionAndRequestAppRatingIfEligible;
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, this.scoreHelpMode = false});

  final bool scoreHelpMode;

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  /// Recarrega métricas quando o usuário fizer login ou trocar de conta.
  String? _lastLoadedUserId;

  /// Evita repetir o pedido de avaliação ao mudar período / pull-to-refresh.
  bool _hasRequestedAppRatingForInsightsData = false;

  @override
  void initState() {
    super.initState();
    if (widget.scoreHelpMode) return;
    final current = context.read<AuthRepository>().currentUser;
    _lastLoadedUserId = current?.uid;
    unawaited(context.read<InsightsCubit>().load());
  }

  void _onAuthUserChanged(AuthUser? user) {
    if (user == null) {
      _lastLoadedUserId = null;
      _hasRequestedAppRatingForInsightsData = false;
      return;
    }
    if (user.uid == _lastLoadedUserId) return;
    _hasRequestedAppRatingForInsightsData = false;
    _lastLoadedUserId = user.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<InsightsCubit>().load());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scoreHelpMode) {
      return _ScoreHelpPage(onBack: () => context.pop());
    }

    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final user = context.read<AuthRepository>().currentUser;
    _onAuthUserChanged(user);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<InsightsCubit, InsightsState>(
          listenWhen: (previous, current) {
            if (_hasRequestedAppRatingForInsightsData) return false;
            if (!current.isLoaded || current.isEmpty) return false;
            return previous.isLoading ||
                previous.status == InsightsStatus.initial ||
                previous.isEmpty;
          },
          listener: (context, state) {
            _hasRequestedAppRatingForInsightsData = true;
            unawaited(
              trackActionAndRequestAppRatingIfEligible(
                context,
                origin: 'insights_dashboard_loaded',
              ),
            );
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError) {
              return _ErrorView(
                message: state.errorMessage ?? l10n.somethingWentWrong,
                onRetry: () => context.read<InsightsCubit>().refresh(),
              );
            }

            if (state.isEmpty) {
              return _EmptyView(appColors: appColors, l10n: l10n);
            }

            return BlocBuilder<SubscriptionEntitlementCubit,
                SubscriptionEntitlementState>(
              buildWhen: (previous, current) =>
                  previous.isPro != current.isPro ||
                  previous.loading != current.loading,
              builder: (context, subState) {
                final isPro = !subState.loading && subState.isPro;
                return RefreshIndicator(
                  onRefresh: () => context.read<InsightsCubit>().refresh(),
                  child: _InsightsContent(
                    summary: state.summary,
                    period: state.period,
                    lastUpdated: state.lastUpdated,
                    appColors: appColors,
                    l10n: l10n,
                    isPro: isPro,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({
    required this.summary,
    required this.period,
    required this.lastUpdated,
    required this.appColors,
    required this.l10n,
    required this.isPro,
  });

  final InsightsSummary summary;
  final InsightsPeriod period;
  final DateTime? lastUpdated;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderSection(
          period: period,
          lastUpdated: lastUpdated,
          appColors: appColors,
          l10n: l10n,
          isPro: isPro,
        ),
        if (!isPro) ...[
          const SizedBox(height: 12),
          _InsightsFreeTeaserBanner(appColors: appColors, l10n: l10n),
        ],
        if (isPro) ...[
          const SizedBox(height: 16),
          _OperationalSummarySection(
            summary: summary,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          _ClinicalPrioritySection(
            summary: summary,
            appColors: appColors,
            l10n: l10n,
          ),
        ],
        const SizedBox(height: 16),
        _SummaryCards(summary: summary, appColors: appColors, l10n: l10n),
        const SizedBox(height: 24),
        if (isPro && summary.hasAlerts) ...[
          _AlertsSection(
            alerts: summary.recentAlerts,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
        ],
        if (isPro) ...[
          _AttentionSection(
            patients: summary.patientsNeedingAttention,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
          _PatientAnalyticsSection(
            patients: summary.patientInsights,
            appColors: appColors,
            l10n: l10n,
          ),
        ],
        if (!isPro) ...[
          _InsightsProLockedFeatureCard(
            icon: Icons.priority_high_rounded,
            title: l10n.insightsProLockedAttentionTitle,
            body: l10n.insightsProLockedAttentionBody,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          _InsightsProLockedFeatureCard(
            icon: Icons.analytics_outlined,
            title: l10n.insightsProLockedAnalyticsTitle,
            body: l10n.insightsProLockedAnalyticsBody,
            appColors: appColors,
            l10n: l10n,
          ),
        ],
      ],
    );
  }
}

class _InsightsFreeTeaserBanner extends StatelessWidget {
  const _InsightsFreeTeaserBanner({
    required this.appColors,
    required this.l10n,
  });

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: appColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: appColors.secondary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.insightsFreeTeaserTitle,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.insightsFreeTeaserBody,
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => context.push('/plans'),
            style: FilledButton.styleFrom(
              foregroundColor: appColors.primary,
            ),
            child: Text(l10n.upgradeToPro),
          ),
        ],
      ),
    );
  }
}

class _InsightsProLockedFeatureCard extends StatelessWidget {
  const _InsightsProLockedFeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.appColors,
    required this.l10n,
  });

  final IconData icon;
  final String title;
  final String body;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.gray.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColors.gray, size: 22),
              const SizedBox(width: 8),
              Icon(Icons.lock_outline, color: appColors.gray, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push('/plans'),
            child: Text(l10n.upgradeToPro),
          ),
        ],
      ),
    );
  }
}

class _ClinicalPrioritySection extends StatelessWidget {
  const _ClinicalPrioritySection({
    required this.summary,
    required this.appColors,
    required this.l10n,
  });

  final InsightsSummary summary;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasHighPriorityAlerts = summary.highPriorityAlerts.isNotEmpty;
    final attentionCount = summary.patientsNeedingAttention.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tune_rounded, color: appColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.insightsClinicalPriorityTitle,
                      style: AppTextStyles.h3.copyWith(
                        color: appColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.insightsClinicalPrioritySubtitle,
                      style: AppTextStyles.body3.copyWith(
                        color: appColors.grayDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PriorityStatChip(
                icon: Icons.priority_high_rounded,
                label: l10n.insightsPatientsNeedAttention(attentionCount),
                color: appColors.primary,
              ),
              _PriorityStatChip(
                icon: Icons.warning_amber_rounded,
                label: l10n.insightsHighPriorityAlertsCount(
                  summary.highPriorityAlerts.length,
                ),
                color: appColors.error,
              ),
              _PriorityStatChip(
                icon: Icons.percent_rounded,
                label: l10n.insightsActiveRate(
                  summary.activePercentage.toStringAsFixed(0),
                ),
                color: appColors.secondary,
              ),
              if (hasHighPriorityAlerts)
                _PriorityStatChip(
                  icon: Icons.flash_on_rounded,
                  label: l10n.insightsClinicalActionNeeded,
                  color: Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasHighPriorityAlerts
                ? l10n.insightsClinicalPriorityWithAlerts
                : l10n.insightsClinicalPriorityNoAlerts,
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
        ],
      ),
    );
  }
}

class _OperationalSummarySection extends StatelessWidget {
  const _OperationalSummarySection({
    required this.summary,
    required this.appColors,
    required this.l10n,
  });

  final InsightsSummary summary;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appColors.gray.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard_outlined,
                color: appColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.insightsDashboardOperationalTitle,
                style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.insightsDashboardOperationalSubtitle,
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PriorityStatChip(
                icon: Icons.schedule,
                label: l10n.insightsPatientPriorityToday(
                  summary.patientsReviewToday,
                ),
                color: appColors.error,
              ),
              _PriorityStatChip(
                icon: Icons.schedule_send,
                label: l10n.insightsPatientPrioritySoon(
                  summary.patientsReviewSoon,
                ),
                color: Colors.orange,
              ),
              _PriorityStatChip(
                icon: Icons.check_circle_outline,
                label: l10n.insightsPatientPriorityStable(
                  summary.stablePatients,
                ),
                color: appColors.success,
              ),
              _PriorityStatChip(
                icon: Icons.trending_down_rounded,
                label: l10n.insightsPatientPriorityWorsening(
                  summary.worseningPatients,
                ),
                color: appColors.error,
              ),
              _PriorityStatChip(
                icon: Icons.trending_up_rounded,
                label: l10n.insightsPatientPriorityImproving(
                  summary.improvingPatients,
                ),
                color: appColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.insightsActionSummary(
              summary.patientsReviewToday,
              summary.patientsReviewSoon,
              summary.stablePatients,
            ),
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
        ],
      ),
    );
  }
}

class _PriorityStatChip extends StatelessWidget {
  const _PriorityStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientAnalyticsSection extends StatelessWidget {
  const _PatientAnalyticsSection({
    required this.patients,
    required this.appColors,
    required this.l10n,
  });

  final List<PatientInsight> patients;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final sortedPatients = [...patients]
      ..sort((a, b) => b.attentionScore.compareTo(a.attentionScore));
    final topPatients = sortedPatients.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: appColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.insightsPatientAnalyticsTitle,
              style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.insightsPatientAnalyticsSubtitle,
          style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
        ),
        const SizedBox(height: 12),
        if (topPatients.isEmpty)
          _NoAnalyticsCard(appColors: appColors, l10n: l10n)
        else
          ...topPatients.map(
            (patient) => _PatientAnalyticsCard(
              insight: patient,
              appColors: appColors,
              l10n: l10n,
            ),
          ),
      ],
    );
  }
}

class _PatientAnalyticsCard extends StatelessWidget {
  const _PatientAnalyticsCard({
    required this.insight,
    required this.appColors,
    required this.l10n,
  });

  final PatientInsight insight;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final trend = _getTrendLabel();
    final trendColor = _getTrendColor();
    final trendDelta = insight.mealsTrendDelta;
    final action = insight.clinicalAction;
    final negative = insight.negativeFeelingsPercentage.toStringAsFixed(0);
    final restriction = insight.restrictionPercentage.toStringAsFixed(0);
    final hasHighPriority = insight.hasHighPriorityAlerts;

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appColors.backgroundDefault,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appColors.gray.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    insight.patient.name,
                    style: AppTextStyles.body1.copyWith(
                      color: appColors.neutralBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionBadge(
                  label: _getActionLabel(action),
                  color: _getActionColor(action),
                ),
                _TrendBadge(label: trend, color: trendColor),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionBadge(
                  label: _getActionLabel(action),
                  color: _getActionColor(action),
                ),
                _ActionBadge(
                  label: l10n.insightsTrendMealsLabel,
                  color: insight.isWorsening
                      ? appColors.error
                      : appColors.secondary,
                ),
                _ActionBadge(
                  label: insight.isWorsening
                      ? l10n.insightsTrendWorse
                      : insight.isImproving
                      ? l10n.insightsTrendBetter
                      : l10n.insightsTrendSame,
                  color: trendColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.insightsTrendComparison(
                insight.mealsLast7Days,
                insight.mealsPrevious7Days,
                _getTrendDeltaLabel(trendDelta),
              ),
              style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label: l10n.insightsScoreValue(insight.attentionScore),
                  icon: Icons.local_fire_department_outlined,
                  color: appColors.primary,
                ),
                _MetricChip(
                  label: l10n.insightsMealsTrend(
                    insight.mealsLast7Days,
                    insight.mealsPrevious7Days,
                  ),
                  icon: Icons.restaurant_outlined,
                  color: appColors.secondary,
                ),
                _MetricChip(
                  label: l10n.insightsNegativeFeelings(negative),
                  icon: Icons.sentiment_dissatisfied_outlined,
                  color: Colors.orange,
                ),
                _MetricChip(
                  label: l10n.insightsRestrictionRate(restriction),
                  icon: Icons.do_not_disturb_on_outlined,
                  color: appColors.error,
                ),
                if (hasHighPriority)
                  _MetricChip(
                    label: l10n.insightsHighPriorityAlerts,
                    icon: Icons.warning_amber_rounded,
                    color: appColors.error,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _getNarrative(),
              style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
            ),
          ],
        ),
      ),
    );
  }

  String _getTrendLabel() {
    final current = insight.mealsLast7Days;
    final previous = insight.mealsPrevious7Days;
    if (current == 0 && previous == 0) return l10n.insightsTrendNoData;
    if (previous == 0) return l10n.insightsTrendStable;
    final ratio = current / previous;
    if (ratio >= 1.1) return l10n.insightsTrendStable;
    if (ratio >= 0.8) return l10n.insightsTrendModerate;
    return l10n.insightsTrendLow;
  }

  Color _getTrendColor() {
    final current = insight.mealsLast7Days;
    final previous = insight.mealsPrevious7Days;
    if (current == 0 && previous == 0) return appColors.gray;
    if (previous == 0) return appColors.success;
    final ratio = current / previous;
    if (ratio >= 1.1) return appColors.success;
    if (ratio >= 0.8) return Colors.orange;
    return appColors.error;
  }

  String _getTrendDeltaLabel(int delta) {
    if (delta > 0) return l10n.insightsTrendUp;
    if (delta < 0) return l10n.insightsTrendDown;
    return l10n.insightsTrendFlat;
  }

  String _getNarrative() {
    if (insight.isInactive) {
      return l10n.insightsPatientNarrativeInactive(insight.daysWithoutMeal);
    }
    if (insight.hasHighPriorityAlerts) {
      return l10n.insightsPatientNarrativeHighAlert;
    }
    if (insight.isWorsening) {
      return l10n.insightsTrendActionWorse;
    }
    if (insight.isImproving) {
      return l10n.insightsTrendActionBetter;
    }
    return l10n.insightsPatientNarrativeBalanced;
  }

  void _openDetail(BuildContext context) {
    context.read<InsightsCubit>().logInsightsPatientDrill(target: 'detail');
    unawaited(context.push('/insights/patient-detail', extra: insight));
  }

  String _getActionLabel(ClinicalAction action) {
    switch (action) {
      case ClinicalAction.reviewToday:
        return l10n.insightsActionReviewToday;
      case ClinicalAction.reviewSoon:
        return l10n.insightsActionReviewSoon;
      case ClinicalAction.stable:
        return l10n.insightsActionStable;
    }
  }

  Color _getActionColor(ClinicalAction action) {
    switch (action) {
      case ClinicalAction.reviewToday:
        return appColors.error;
      case ClinicalAction.reviewSoon:
        return Colors.orange;
      case ClinicalAction.stable:
        return appColors.success;
    }
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: AppTextStyles.body3.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 48;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.body3.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.body3.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NoAnalyticsCard extends StatelessWidget {
  const _NoAnalyticsCard({required this.appColors, required this.l10n});

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.gray.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        l10n.insightsPatientAnalyticsEmpty,
        style: AppTextStyles.body2.copyWith(color: appColors.grayDark),
      ),
    );
  }
}

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({required this.insight, super.key});

  final PatientInsight? insight;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final safeInsight = insight;

    if (safeInsight == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.insightsPatientDetailNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? colorScheme.surface
          : appColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: isDark
            ? colorScheme.surface
            : appColors.backgroundDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.insightsPatientDetailTitle),
        actions: [
          TextButton.icon(
            onPressed: () => _openAnalytics(context, safeInsight),
            icon: const Icon(Icons.bar_chart_outlined, size: 18),
            label: Text(l10n.insightsViewAnalytics),
          ),
          TextButton.icon(
            onPressed: () => _openDiary(context, safeInsight),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: Text(l10n.insightsViewDiary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            safeInsight.patient.name,
            style: AppTextStyles.h2.copyWith(
              color: isDark ? colorScheme.onSurface : appColors.neutralBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.insightsPatientDetailSubtitle,
            style: AppTextStyles.body2.copyWith(
              color: isDark ? colorScheme.onSurfaceVariant : appColors.grayDark,
            ),
          ),
          const SizedBox(height: 16),
          _DetailHeroCard(
            insight: safeInsight,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
          _DetailSection(
            title: l10n.insightsClinicalWhyHere,
            accentColor: safeInsight.hasHighPriorityAlerts
                ? appColors.error
                : safeInsight.isWorsening
                ? Colors.orange
                : appColors.secondary,
            leadingIcon: safeInsight.hasHighPriorityAlerts
                ? Icons.warning_amber_rounded
                : safeInsight.isWorsening
                ? Icons.trending_down_rounded
                : Icons.info_outline_rounded,
            children: [
              Text(
                safeInsight.hasHighPriorityAlerts
                    ? l10n.insightsClinicalWhyHereHighRisk
                    : safeInsight.isWorsening
                    ? l10n.insightsClinicalWhyHereWorsening
                    : l10n.insightsClinicalWhyHereBalanced,
                style: AppTextStyles.body2.copyWith(
                  color: isDark
                      ? colorScheme.onSurfaceVariant
                      : appColors.grayDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            title: l10n.insightsPatientDetailSignalsTitle,
            accentColor: safeInsight.hasHighPriorityAlerts
                ? appColors.error
                : appColors.primary,
            children: [
              _DetailMetricRow(
                label: l10n.insightsActionLabel,
                value: _getClinicalActionLabel(safeInsight, l10n),
              ),
              _DetailMetricRow(
                label: l10n.insightsScoreLabel,
                value: l10n.insightsScoreValue(safeInsight.attentionScore),
              ),
              _DetailMetricRow(
                label: l10n.insightsTrendLabel,
                value: l10n.insightsTrendComparison(
                  safeInsight.mealsLast7Days,
                  safeInsight.mealsPrevious7Days,
                  safeInsight.mealsLast7Days >= safeInsight.mealsPrevious7Days
                      ? l10n.insightsTrendUp
                      : l10n.insightsTrendDown,
                ),
              ),
              _DetailMetricRow(
                label: l10n.insightsTrendAlertsLabel,
                value: l10n.insightsAlertsCount(safeInsight.alertsLast7Days),
              ),
              _DetailMetricRow(
                label: l10n.insightsTrendMealsLabel,
                value: l10n.insightsMealsTrend(
                  safeInsight.mealsLast7Days,
                  safeInsight.mealsPrevious7Days,
                ),
              ),
              _DetailMetricRow(
                label: l10n.insightsPatientDetailInactive,
                value: l10n.insightsInactive(safeInsight.daysWithoutMeal),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            title: l10n.insightsPatientAnalyticsTitle,
            accentColor: safeInsight.hasHighPriorityAlerts
                ? appColors.error
                : appColors.secondary,
            leadingIcon: Icons.bar_chart_rounded,
            children: [
              _MiniTrendChart(
                label: l10n.insightsTrendMealsLabel,
                currentValue: safeInsight.mealsLast7Days.toDouble(),
                previousValue: safeInsight.mealsPrevious7Days.toDouble(),
                currentColor: appColors.primary,
                previousColor: appColors.gray.withValues(alpha: 0.55),
                previousLabel: l10n.insightsPeriodPreviousWeek,
                currentLabel: l10n.insightsPeriodThisWeek,
                caption: l10n.insightsMealsTrend(
                  safeInsight.mealsLast7Days,
                  safeInsight.mealsPrevious7Days,
                ),
              ),
              const SizedBox(height: 14),
              _MiniTrendChart(
                label: l10n.insightsTrendAlertsLabel,
                currentValue: safeInsight.alertsLast7Days.toDouble(),
                previousValue: safeInsight.alertsPrevious7Days.toDouble(),
                currentColor: appColors.error,
                previousColor: appColors.gray.withValues(alpha: 0.55),
                previousLabel: l10n.insightsPeriodPreviousWeek,
                currentLabel: l10n.insightsPeriodThisWeek,
                caption: l10n.insightsAlertsTrendComparison(
                  safeInsight.alertsLast7Days,
                  safeInsight.alertsPrevious7Days,
                  safeInsight.alertsTrendDelta > 0
                      ? l10n.insightsTrendUp
                      : safeInsight.alertsTrendDelta < 0
                      ? l10n.insightsTrendDown
                      : l10n.insightsTrendFlat,
                ),
              ),
              const SizedBox(height: 14),
              _MiniDistributionChart(
                label: l10n.insightsTrendMealsLabel,
                values: [
                  safeInsight.mealsLast7Days.toDouble(),
                  safeInsight.mealsPrevious7Days.toDouble(),
                  safeInsight.mealsLast30Days.toDouble(),
                ],
                colors: [
                  appColors.primary,
                  appColors.secondary,
                  appColors.gray,
                ],
                labels: [
                  l10n.insightsPeriod7Days,
                  l10n.insightsPeriodPreviousWeek,
                  l10n.insightsPeriod30Days,
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            title: l10n.insightsPatientDetailNarrativeTitle,
            accentColor: safeInsight.hasHighPriorityAlerts
                ? appColors.error
                : appColors.secondary,
            leadingIcon: safeInsight.hasHighPriorityAlerts
                ? Icons.warning_amber_rounded
                : Icons.psychology_outlined,
            children: [
              Text(
                safeInsight.isInactive
                    ? l10n.insightsPatientNarrativeInactive(
                        safeInsight.daysWithoutMeal,
                      )
                    : safeInsight.hasHighPriorityAlerts
                    ? l10n.insightsPatientNarrativeHighAlert
                    : l10n.insightsPatientNarrativeBalanced,
                style: AppTextStyles.body2.copyWith(
                  color: isDark
                      ? colorScheme.onSurfaceVariant
                      : appColors.grayDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailSection(
            title: l10n.insightsPatientDetailRecentAlerts,
            children: safeInsight.recentAlerts.isEmpty
                ? [
                    Text(
                      l10n.insightsPatientDetailNoAlerts,
                      style: AppTextStyles.body2.copyWith(
                        color: isDark
                            ? colorScheme.onSurfaceVariant
                            : appColors.grayDark,
                      ),
                    ),
                  ]
                : safeInsight.recentAlerts
                      .take(8)
                      .map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TimelineAlertRow(
                            alert: alert,
                            appColors: appColors,
                            colorScheme: colorScheme,
                            isDark: isDark,
                            label: _getRiskAlertLabel(alert.type, l10n),
                          ),
                        ),
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }

  String _getClinicalActionLabel(
    PatientInsight insight,
    AppLocalizations l10n,
  ) {
    switch (insight.clinicalAction) {
      case ClinicalAction.reviewToday:
        return l10n.insightsActionReviewToday;
      case ClinicalAction.reviewSoon:
        return l10n.insightsActionReviewSoon;
      case ClinicalAction.stable:
        return l10n.insightsActionStable;
    }
  }

  void _openAnalytics(BuildContext context, PatientInsight insight) {
    context.read<InsightsCubit>().logInsightsPatientDrill(target: 'analytics');
    unawaited(
      context.push(
        '/patients/${insight.patient.id}/analytics'
        '?name=${Uri.encodeComponent(insight.patient.name)}',
      ),
    );
  }

  void _openDiary(BuildContext context, PatientInsight insight) {
    unawaited(
      context.push(
        '/patients/${insight.patient.id}/diary'
        '?name=${Uri.encodeComponent(insight.patient.name)}',
      ),
    );
  }
}

class _DetailHeroCard extends StatelessWidget {
  const _DetailHeroCard({
    required this.insight,
    required this.appColors,
    required this.l10n,
  });

  final PatientInsight insight;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final accent = insight.hasHighPriorityAlerts
        ? appColors.error
        : appColors.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? accent.withValues(alpha: 0.22)
              : accent.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _DetailChip(label: l10n.insightsScoreValue(insight.attentionScore)),
          _DetailChip(
            label: l10n.insightsMealsTrend(
              insight.mealsLast7Days,
              insight.mealsPrevious7Days,
            ),
          ),
          _DetailChip(
            label: l10n.insightsNegativeFeelings(
              insight.negativeFeelingsPercentage.toStringAsFixed(0),
            ),
          ),
          _DetailChip(
            label: l10n.insightsRestrictionRate(
              insight.restrictionPercentage.toStringAsFixed(0),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
    this.leadingIcon,
    this.accentColor,
  });

  final String title;
  final List<Widget> children;
  final IconData? leadingIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final effectiveAccent = accentColor ?? appColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : appColors.backgroundDefault,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? effectiveAccent.withValues(alpha: 0.22)
              : effectiveAccent.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: effectiveAccent),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? colorScheme.onSurface
                        : appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (accentColor != null) ...[
            Container(
              height: 3,
              width: 44,
              decoration: BoxDecoration(
                color: effectiveAccent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _DetailMetricRow extends StatelessWidget {
  const _DetailMetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body3.copyWith(
              color: appColors.neutralBlack,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : appColors.backgroundDefault,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withValues(alpha: 0.45)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body3.copyWith(
          color: isDark ? colorScheme.onSurface : appColors.neutralBlack,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MiniTrendChart extends StatelessWidget {
  const _MiniTrendChart({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.currentColor,
    required this.previousColor,
    required this.caption,
    this.previousLabel = 'Semana anterior',
    this.currentLabel = 'Esta semana',
  });

  final String label;
  final double currentValue;
  final double previousValue;
  final Color currentColor;
  final Color previousColor;
  final String caption;
  final String previousLabel;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final maxValue = [
      currentValue,
      previousValue,
    ].fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body3.copyWith(
            color: appColors.grayDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _MiniBar(
                value: previousValue / safeMax,
                color: previousColor,
                title: previousLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniBar(
                value: currentValue / safeMax,
                color: currentColor,
                title: currentLabel,
                emphasized: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: AppTextStyles.body3.copyWith(color: appColors.grayDark),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.color,
    required this.title,
    this.emphasized = false,
  });

  final double value;
  final Color color;
  final String title;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    const height = 72.0;
    const minBarHeight = 12.0;
    final barHeight = (height * value).clamp(minBarHeight, height);
    final appColors = AppColors.fromContext(context);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: emphasized ? 28 : 22,
              height: barHeight,
              decoration: BoxDecoration(
                color: color.withValues(alpha: emphasized ? 0.8 : 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTextStyles.body3.copyWith(
            color: appColors.grayDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniDistributionChart extends StatelessWidget {
  const _MiniDistributionChart({
    required this.label,
    required this.values,
    required this.colors,
    required this.labels,
  });

  final String label;
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final maxValue = values.fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body3.copyWith(
            color: appColors.grayDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(values.length, (index) {
            final value = values[index] / safeMax;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == values.length - 1 ? 0 : 8,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 72,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 24,
                          height: (72 * value).clamp(12.0, 72.0),
                          decoration: BoxDecoration(
                            color: colors[index].withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[index],
                      style: AppTextStyles.body3.copyWith(
                        color: appColors.grayDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TimelineAlertRow extends StatelessWidget {
  const _TimelineAlertRow({
    required this.alert,
    required this.appColors,
    required this.colorScheme,
    required this.isDark,
    required this.label,
  });

  final RiskAlert alert;
  final AppColors appColors;
  final ColorScheme colorScheme;
  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _getTimelineColor(alert.priority);
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Container(
              width: 2,
              height: 34,
              color: color.withValues(alpha: 0.35),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : appColors.backgroundDefault,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: isDark
                        ? colorScheme.onSurface
                        : appColors.neutralBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(alert.dateTime),
                  style: AppTextStyles.body3.copyWith(
                    color: isDark
                        ? colorScheme.onSurfaceVariant
                        : appColors.grayDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getTimelineColor(RiskPriority priority) {
    switch (priority) {
      case RiskPriority.high:
        return appColors.error;
      case RiskPriority.medium:
        return Colors.orange;
      case RiskPriority.low:
        return Colors.amber;
    }
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.period,
    required this.lastUpdated,
    required this.appColors,
    required this.l10n,
    required this.isPro,
  });

  final InsightsPeriod period;
  final DateTime? lastUpdated;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.insightsDashboard,
                style: AppTextStyles.h2.copyWith(
                  color: appColors.neutralBlack,
                ),
              ),
            ),
            if (isPro)
              _PeriodSelector(
                currentPeriod: period,
                appColors: appColors,
                l10n: l10n,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appColors.gray.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.insightsFreeTeaserPeriodBadge,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (!isPro) ...[
          const SizedBox(height: 6),
          Text(
            l10n.insightsFreeTeaserPeriodHint,
            style: AppTextStyles.body3.copyWith(color: appColors.gray),
          ),
        ],
        if (lastUpdated != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.insightsUpdatedAt(timeFormat.format(lastUpdated!)),
            style: AppTextStyles.body3.copyWith(color: appColors.gray),
          ),
        ],
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.currentPeriod,
    required this.appColors,
    required this.l10n,
  });

  final InsightsPeriod currentPeriod;
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
        children: InsightsPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return GestureDetector(
            onTap: () => context.read<InsightsCubit>().changePeriod(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? appColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getPeriodLabel(period),
                style: AppTextStyles.body3.copyWith(
                  color: isSelected ? Colors.white : appColors.gray,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getPeriodLabel(InsightsPeriod period) {
    switch (period) {
      case InsightsPeriod.days7:
        return l10n.insightsPeriod7Days;
      case InsightsPeriod.days30:
        return l10n.insightsPeriod30Days;
      case InsightsPeriod.days90:
        return l10n.insightsPeriod90Days;
    }
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.summary,
    required this.appColors,
    required this.l10n,
  });

  final InsightsSummary summary;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: '${summary.activePatients}/${summary.totalPatients}',
            label: l10n.insightsActivePatients,
            subtitle: l10n.insightsActivePatientsSubtitle,
            color: appColors.primary,
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            value: '${summary.totalMealsThisWeek}',
            label: l10n.insightsMealsPeriod,
            subtitle: l10n.insightsMealsThisWeekSubtitle,
            color: appColors.secondary,
            icon: Icons.restaurant_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            value: '${summary.totalAlerts}',
            label: l10n.insightsAlerts,
            subtitle: l10n.insightsAlertsSubtitle,
            color: summary.totalAlerts > 0 ? appColors.error : appColors.gray,
            icon: Icons.warning_amber_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(
              color: appColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({
    required this.alerts,
    required this.appColors,
    required this.l10n,
  });

  final List<RiskAlert> alerts;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: appColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.insightsRecentAlerts,
              style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts
            .take(5)
            .map(
              (alert) =>
                  _AlertCard(alert: alert, appColors: appColors, l10n: l10n),
            ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.appColors,
    required this.l10n,
  });

  final RiskAlert alert;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(alert.priority, appColors);
    final dateFormat = DateFormat('dd/MM HH:mm');

    return GestureDetector(
      onTap: () => _navigateToDiary(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.patientName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: appColors.neutralBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getAlertLabel(alert.type, l10n),
                    style: AppTextStyles.body3.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateFormat.format(alert.dateTime),
                  style: AppTextStyles.body3.copyWith(color: appColors.gray),
                ),
                const SizedBox(height: 2),
                _PriorityBadge(priority: alert.priority, l10n: l10n),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: appColors.gray, size: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToDiary(BuildContext context) {
    unawaited(
      context.push(
        '/patients/${alert.patientId}/diary'
        '?name=${Uri.encodeComponent(alert.patientName)}',
      ),
    );
  }

  Color _getPriorityColor(RiskPriority priority, AppColors appColors) {
    switch (priority) {
      case RiskPriority.high:
        return appColors.error;
      case RiskPriority.medium:
        return Colors.orange;
      case RiskPriority.low:
        return Colors.amber;
    }
  }

  String _getAlertLabel(RiskType type, AppLocalizations l10n) {
    switch (type) {
      case RiskType.forcedVomit:
        return l10n.insightsAlertForcedVomit;
      case RiskType.usedLaxatives:
        return l10n.insightsAlertUsedLaxatives;
      case RiskType.diuretics:
        return l10n.insightsAlertDiuretics;
      case RiskType.regurgitated:
        return l10n.insightsAlertRegurgitated;
      case RiskType.hiddenFood:
        return l10n.insightsAlertHiddenFood;
      case RiskType.ateInSecret:
        return l10n.insightsAlertAteInSecret;
    }
  }
}

String _getRiskAlertLabel(RiskType type, AppLocalizations l10n) {
  switch (type) {
    case RiskType.forcedVomit:
      return l10n.insightsAlertForcedVomit;
    case RiskType.usedLaxatives:
      return l10n.insightsAlertUsedLaxatives;
    case RiskType.diuretics:
      return l10n.insightsAlertDiuretics;
    case RiskType.regurgitated:
      return l10n.insightsAlertRegurgitated;
    case RiskType.hiddenFood:
      return l10n.insightsAlertHiddenFood;
    case RiskType.ateInSecret:
      return l10n.insightsAlertAteInSecret;
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority, required this.l10n});

  final RiskPriority priority;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final color = _getColor(appColors);
    final label = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.body3.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor(AppColors appColors) {
    switch (priority) {
      case RiskPriority.high:
        return appColors.error;
      case RiskPriority.medium:
        return Colors.orange;
      case RiskPriority.low:
        return Colors.amber.shade700;
    }
  }

  String _getLabel() {
    switch (priority) {
      case RiskPriority.high:
        return l10n.insightsHighPriority;
      case RiskPriority.medium:
        return l10n.insightsMediumPriority;
      case RiskPriority.low:
        return l10n.insightsLowPriority;
    }
  }
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({
    required this.patients,
    required this.appColors,
    required this.l10n,
  });

  final List<PatientInsight> patients;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.priority_high, color: appColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.insightsNeedsAttention,
              style: AppTextStyles.h3.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (patients.isEmpty)
          _NoAttentionCard(appColors: appColors, l10n: l10n)
        else
          ...patients.map(
            (patient) => _PatientAttentionCard(
              insight: patient,
              appColors: appColors,
              l10n: l10n,
              colorScheme: colorScheme,
            ),
          ),
      ],
    );
  }
}

class _NoAttentionCard extends StatelessWidget {
  const _NoAttentionCard({required this.appColors, required this.l10n});

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: appColors.success, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.insightsNoAttentionNeeded,
              style: AppTextStyles.body1.copyWith(color: appColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientAttentionCard extends StatelessWidget {
  const _PatientAttentionCard({
    required this.insight,
    required this.appColors,
    required this.l10n,
    required this.colorScheme,
  });

  final PatientInsight insight;
  final AppColors appColors;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    final isDark = colorScheme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _navigateToDiary(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.3 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _PatientAvatar(
              name: insight.patient.name,
              photoUrl: insight.patient.photoUrl,
              appColors: appColors,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.patient.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _InfoChip(
                        icon: Icons.restaurant_outlined,
                        label: l10n.insightsMealsCount(insight.mealsLast7Days),
                        color: appColors.secondary,
                      ),
                      if (insight.alertsLast7Days > 0)
                        _InfoChip(
                          icon: Icons.warning_amber_outlined,
                          label: l10n.insightsAlertsCount(
                            insight.alertsLast7Days,
                          ),
                          color: appColors.error,
                        ),
                      if (insight.isInactive)
                        _InfoChip(
                          icon: Icons.schedule,
                          label: l10n.insightsInactive(insight.daysWithoutMeal),
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  if (insight.lastMealDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.insightsLastMeal(
                        dateFormat.format(insight.lastMealDate!),
                      ),
                      style: AppTextStyles.body3.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showScoreHelp(context, appColors),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(
                          insight.attentionScore,
                          appColors,
                        ).withValues(alpha: isDark ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getScoreColor(
                            insight.attentionScore,
                            appColors,
                          ).withValues(alpha: isDark ? 0.3 : 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.insightsScoreLabel,
                                style: AppTextStyles.body3.copyWith(
                                  color: _getScoreColor(
                                    insight.attentionScore,
                                    appColors,
                                  ).withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${insight.attentionScore}',
                                style: AppTextStyles.body2.copyWith(
                                  color: _getScoreColor(
                                    insight.attentionScore,
                                    appColors,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _getScoreColor(
                                insight.attentionScore,
                                appColors,
                              ).withValues(alpha: isDark ? 0.18 : 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: _getScoreColor(
                                insight.attentionScore,
                                appColors,
                              ),
                              size: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDiary(BuildContext context) {
    unawaited(
      context.push(
        '/patients/${insight.patient.id}/diary'
        '?name=${Uri.encodeComponent(insight.patient.name)}',
      ),
    );
  }

  Color _getScoreColor(int score, AppColors appColors) {
    if (score >= 20) return appColors.error;
    if (score >= 10) return Colors.orange;
    if (score > 0) return Colors.amber.shade700;
    return appColors.success;
  }
}

void _showScoreHelp(BuildContext context, AppColors appColors) {
  final l10n = context.l10n;

  unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ScoreHelpSheet(
        title: l10n.insightsScoreHelpTitle,
        body: l10n.insightsScoreHelpBody,
        bullets: [
          l10n.insightsScoreHelpBullets1,
          l10n.insightsScoreHelpBullets2,
          l10n.insightsScoreHelpBullets3,
        ],
        disclaimer: l10n.insightsScoreHelpDisclaimer,
        ctaLabel: l10n.insightsScoreHelpButton,
        accentColor: appColors.primary,
        onLearnMore: () async {
          Navigator.of(sheetContext).pop();
          await context.push('/insights/score-help');
        },
      ),
    ),
  );
}

class _ScoreHelpSheet extends StatelessWidget {
  const _ScoreHelpSheet({
    required this.title,
    required this.body,
    required this.bullets,
    required this.disclaimer,
    required this.ctaLabel,
    required this.accentColor,
    required this.onLearnMore,
  });

  final String title;
  final String body;
  final List<String> bullets;
  final String disclaimer;
  final String ctaLabel;
  final Color accentColor;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appColors.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.insights_rounded, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        color: appColors.neutralBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: appColors.gray),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: AppTextStyles.body2.copyWith(color: appColors.grayDark),
              ),
              const SizedBox(height: 12),
              ...bullets.map(
                (bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: accentColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          bullet,
                          style: AppTextStyles.body2.copyWith(
                            color: appColors.neutralBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appColors.gray.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  disclaimer,
                  style: AppTextStyles.body3.copyWith(
                    color: appColors.grayDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              UiAutoWidthButton(text: ctaLabel, onPressed: onLearnMore),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreHelpPage extends StatelessWidget {
  const _ScoreHelpPage({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: appColors.backgroundDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: onBack,
          icon: Icon(Icons.arrow_back_ios_new, color: appColors.neutralBlack),
        ),
        title: Text(
          l10n.insightsScoreHelpPageTitle,
          style: AppTextStyles.h4.copyWith(
            color: appColors.neutralBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, color: appColors.primary),
                const SizedBox(height: 12),
                Text(
                  l10n.insightsScoreHelpPageTitle,
                  style: AppTextStyles.h3.copyWith(
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.insightsScoreHelpPageBody,
                  style: AppTextStyles.body2.copyWith(
                    color: appColors.grayDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _HelpSection(
            title: l10n.insightsScoreHelpTitle,
            items: [
              l10n.insightsScoreHelpBullets1,
              l10n.insightsScoreHelpBullets2,
              l10n.insightsScoreHelpBullets3,
            ],
            appColors: appColors,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.insightsScoreHelpDisclaimer,
            style: AppTextStyles.body3.copyWith(color: appColors.gray),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.items,
    required this.appColors,
  });

  final String title;
  final List<String> items;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: appColors.neutralBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: appColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.body2.copyWith(
                      color: appColors.grayDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({
    required this.name,
    required this.photoUrl,
    required this.appColors,
  });

  final String name;
  final String? photoUrl;
  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join()
        : '?';

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: NetworkImage(photoUrl!));
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: appColors.primary.withValues(alpha: 0.1),
      child: Text(
        initials.toUpperCase(),
        style: AppTextStyles.body1.copyWith(
          color: appColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body3.copyWith(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.appColors, required this.l10n});

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: appColors.gray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.insightsEmptyTitle,
              style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.insightsEmptySubtitle,
              style: AppTextStyles.body1.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: appColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(color: appColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}
