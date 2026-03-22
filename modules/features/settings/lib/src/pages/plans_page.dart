import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_feature/src/cubit/plans_cubit.dart';
import 'package:settings_feature/src/cubit/plans_state.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  static String _paywallSourceFromContext(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final raw = uri.queryParameters['source'];
    if (raw == null || raw.isEmpty) return 'direct';
    switch (raw) {
      case 'invite_limit':
      case 'settings_subscription':
        return raw;
      default:
        return 'other';
    }
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    final l10n = context.l10n;
    final outcome = await context.read<PlansCubit>().purchase();
    if (!context.mounted) return;

    final message = switch (outcome) {
      SubscriptionPurchaseOutcome.success => l10n.purchaseSuccess,
      SubscriptionPurchaseOutcome.cancelled => l10n.purchaseCancelled,
      SubscriptionPurchaseOutcome.offeringsUnavailable =>
        l10n.purchaseOfferingsUnavailable,
      SubscriptionPurchaseOutcome.notConfigured => l10n.purchasesNotConfigured,
      SubscriptionPurchaseOutcome.failed => l10n.purchaseFailed,
    };
    final type = outcome == SubscriptionPurchaseOutcome.success
        ? UiSnackbarType.success
        : outcome == SubscriptionPurchaseOutcome.cancelled ||
                outcome == SubscriptionPurchaseOutcome.offeringsUnavailable ||
                outcome == SubscriptionPurchaseOutcome.notConfigured
            ? UiSnackbarType.normal
            : UiSnackbarType.error;
    uiSnackBar(context: context, message: message, type: type);
    if (outcome == SubscriptionPurchaseOutcome.success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return BlocBuilder<SubscriptionEntitlementCubit,
        SubscriptionEntitlementState>(
      builder: (context, subState) {
        context.read<PlansCubit>().tryLogPaywallViewIfNeeded(
              source: _paywallSourceFromContext(context),
            );
        if (subState.isPro) {
          return Scaffold(
            backgroundColor: appColors.backgroundDefault,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
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
                    const Spacer(),
                    Icon(
                      Icons.verified_rounded,
                      size: 64,
                      color: appColors.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.planPro,
                      style: AppTextStyles.h2.copyWith(
                        color: appColors.neutralBlack,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.unlimitedPatients,
                      style: AppTextStyles.body1.copyWith(
                        color: appColors.gray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.plansProActiveInsightsIncluded,
                      style: AppTextStyles.body2.copyWith(
                        color: appColors.grayDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildPaywall(context, appColors, l10n);
      },
    );
  }

  Widget _buildPaywall(
    BuildContext context,
    AppColors appColors,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<PlansCubit, PlansUiState>(
      builder: (context, plansState) {
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
                          isAnnual: plansState.isAnnual,
                          onChanged: (value) => context
                              .read<PlansCubit>()
                              .setAnnual(isAnnual: value),
                          appColors: appColors,
                          l10n: l10n,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _BottomSection(
                  isAnnual: plansState.isAnnual,
                  appColors: appColors,
                  l10n: l10n,
                  busy: plansState.purchaseBusy,
                  onSubscribe: () => unawaited(_handleSubscribe(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      l10n.plansFeatureClinicalDashboard,
      l10n.plansFeatureInsightsPerPatientDeepDive,
      l10n.plansFeatureMealPushNotifications,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(
                  child: Text(
                    feature,
                    style: AppTextStyles.body1.copyWith(
                      color: appColors.neutralBlack,
                      fontWeight: FontWeight.w500,
                    ),
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
          subtitle: l10n.plansSave40,
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
    required this.busy,
    required this.onSubscribe,
  });

  final bool isAnnual;
  final AppColors appColors;
  final AppLocalizations l10n;
  final bool busy;
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
              onPressed: busy ? null : onSubscribe,
              style: FilledButton.styleFrom(
                backgroundColor: appColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: busy
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: appColors.neutralWhite,
                      ),
                    )
                  : Text(
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
