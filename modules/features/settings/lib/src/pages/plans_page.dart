import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: appColors.neutralBlack,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProBadge(appColors: appColors),
                    const SizedBox(height: 20),
                    Text(
                      l10n.plansUnlockPro,
                      style: AppTextStyles.h2.copyWith(
                        color: appColors.neutralBlack,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.plansUnlockSubtitle,
                      style: AppTextStyles.body1.copyWith(
                        color: appColors.gray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _FeaturesList(appColors: appColors, l10n: l10n),
                    const SizedBox(height: 28),
                    _PlanSelector(
                      isAnnual: _isAnnual,
                      onChanged: (value) => setState(() => _isAnnual = value),
                      appColors: appColors,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomSection(
              isAnnual: _isAnnual,
              appColors: appColors,
              l10n: l10n,
              onSubscribe: _handleSubscribe,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    unawaited(showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction_rounded,
                color: appColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(l10n.plansComingSoon),
          ],
        ),
        content: Text(l10n.plansComingSoonMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.plansGotIt),
          ),
        ],
      ),
    ));
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge({required this.appColors});

  final AppColors appColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColors.primary,
            appColors.primary.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: appColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.star_rounded,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList({required this.appColors, required this.l10n});

  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final features = [
      l10n.plansFeatureUnlimitedPatients,
      l10n.plansFeatureFullHistory,
      l10n.plansFeatureExportReports,
      l10n.plansFeaturePrioritySupport,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors.neutralSilver,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors.grayLight.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: appColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: appColors.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  feature,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.neutralBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector({
    required this.isAnnual,
    required this.onChanged,
    required this.appColors,
    required this.l10n,
  });

  final bool isAnnual;
  final ValueChanged<bool> onChanged;
  final AppColors appColors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PlanOption(
          isSelected: isAnnual,
          onTap: () => onChanged(true),
          appColors: appColors,
          title: l10n.plansAnnual,
          subtitle: l10n.plansSave37,
          price: l10n.plansPriceAnnual,
          period: l10n.plansPeriodYear,
          badge: l10n.plansMostPopular,
        ),
        const SizedBox(height: 12),
        _PlanOption(
          isSelected: !isAnnual,
          onTap: () => onChanged(false),
          appColors: appColors,
          title: l10n.plansMonthly,
          price: l10n.plansPriceMonthly,
          period: l10n.plansPeriodMonth,
        ),
      ],
    );
  }
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.isSelected,
    required this.onTap,
    required this.appColors,
    required this.title,
    required this.price,
    required this.period,
    this.subtitle,
    this.badge,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final AppColors appColors;
  final String title;
  final String? subtitle;
  final String price;
  final String period;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary.withValues(alpha: 0.05)
              : appColors.neutralSilver,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? appColors.primary
                : appColors.grayLight.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: appColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.body3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? appColors.primary : appColors.gray,
                      width: 2,
                    ),
                    color: isSelected ? appColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body1.copyWith(
                          color: appColors.neutralBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.body3.copyWith(
                            color: appColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.h3.copyWith(
                        color: appColors.neutralBlack,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      period,
                      style: AppTextStyles.body3.copyWith(
                        color: appColors.gray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.isAnnual,
    required this.appColors,
    required this.l10n,
    required this.onSubscribe,
  });

  final bool isAnnual;
  final AppColors appColors;
  final AppLocalizations l10n;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final buttonText = isAnnual
        ? l10n.plansSubscribeAnnual
        : l10n.plansSubscribeMonthly;
    final trialText = isAnnual ? l10n.plansTrialAnnual : l10n.plansTrialMonthly;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: appColors.backgroundDefault,
        boxShadow: [
          BoxShadow(
            color: appColors.neutralBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubscribe,
              style: FilledButton.styleFrom(
                backgroundColor: appColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            trialText,
            style: AppTextStyles.body3.copyWith(
              color: appColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.plansCancelAnytime,
            style: AppTextStyles.body3.copyWith(
              color: appColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
