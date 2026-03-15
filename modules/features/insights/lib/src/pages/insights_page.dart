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
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  /// Recarrega métricas quando o usuário fizer login ou trocar de conta.
  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    final current = context.read<AuthRepository>().currentUser;
    _lastLoadedUserId = current?.uid;
    unawaited(context.read<InsightsCubit>().load());
  }

  void _onAuthUserChanged(AuthUser? user) {
    if (user == null) {
      _lastLoadedUserId = null;
      return;
    }
    if (user.uid == _lastLoadedUserId) return;
    _lastLoadedUserId = user.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<InsightsCubit>().load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    final user = context.read<AuthRepository>().currentUser;
    _onAuthUserChanged(user);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<InsightsCubit, InsightsState>(
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

            return RefreshIndicator(
              onRefresh: () => context.read<InsightsCubit>().refresh(),
              child: _InsightsContent(
                summary: state.summary,
                period: state.period,
                lastUpdated: state.lastUpdated,
                appColors: appColors,
                l10n: l10n,
              ),
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
  });

  final InsightsSummary summary;
  final InsightsPeriod period;
  final DateTime? lastUpdated;
  final AppColors appColors;
  final AppLocalizations l10n;

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
        ),
        const SizedBox(height: 16),
        _SummaryCards(summary: summary, appColors: appColors, l10n: l10n),
        const SizedBox(height: 24),
        if (summary.hasAlerts) ...[
          _AlertsSection(
            alerts: summary.recentAlerts,
            appColors: appColors,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
        ],
        _AttentionSection(
          patients: summary.patientsNeedingAttention,
          appColors: appColors,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.period,
    required this.lastUpdated,
    required this.appColors,
    required this.l10n,
  });

  final InsightsPeriod period;
  final DateTime? lastUpdated;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.insightsDashboard,
              style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
            ),
            _PeriodSelector(
              currentPeriod: period,
              appColors: appColors,
              l10n: l10n,
            ),
          ],
        ),
        if (lastUpdated != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.insightsUpdatedAt(timeFormat.format(lastUpdated!)),
            style: AppTextStyles.body3.copyWith(
              color: appColors.gray,
            ),
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
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color),
          ),
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
        ...alerts.take(5).map(
              (alert) => _AlertCard(
                alert: alert,
                appColors: appColors,
                l10n: l10n,
              ),
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
            Icon(
              Icons.chevron_right,
              color: appColors.gray,
              size: 20,
            ),
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
      case RiskType.regurgitated:
        return l10n.insightsAlertRegurgitated;
      case RiskType.hiddenFood:
        return l10n.insightsAlertHiddenFood;
      case RiskType.ateInSecret:
        return l10n.insightsAlertAteInSecret;
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.priority,
    required this.l10n,
  });

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.priority_high, color: appColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.insightsNeedsAttention,
              style: AppTextStyles.h3.copyWith(color: appColors.neutralBlack),
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
            ),
          ),
      ],
    );
  }
}

class _NoAttentionCard extends StatelessWidget {
  const _NoAttentionCard({
    required this.appColors,
    required this.l10n,
  });

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
  });

  final PatientInsight insight;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');

    return GestureDetector(
      onTap: () => _navigateToDiary(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.neutralWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColors.gray.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: appColors.neutralBlack.withValues(alpha: 0.05),
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
                      color: appColors.neutralBlack,
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
                          label: l10n
                              .insightsAlertsCount(insight.alertsLast7Days),
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
                        color: appColors.gray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(insight.attentionScore, appColors)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.insightsAttentionScore(insight.attentionScore),
                    style: AppTextStyles.body3.copyWith(
                      color: _getScoreColor(insight.attentionScore, appColors),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right,
                  color: appColors.gray,
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
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(photoUrl!),
      );
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
            style: AppTextStyles.body3.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.appColors,
    required this.l10n,
  });

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
              style: AppTextStyles.h2.copyWith(
                color: appColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.insightsEmptySubtitle,
              style: AppTextStyles.body1.copyWith(
                color: appColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

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
              style: AppTextStyles.h2.copyWith(
                color: appColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: appColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
