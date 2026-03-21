import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:flutter/scheduler.dart';
import 'package:settings_feature/src/cubit/plans_state.dart';
import 'package:subscription_foundation/subscription_foundation.dart';

/// UI da paywall `/plans` + analytics de compra.
///
/// Analytics opcional para testes; o cubit de subscrição vem do app.
class PlansCubit extends Cubit<PlansUiState> {
  PlansCubit({
    required SubscriptionEntitlementCubit subscriptionCubit,
    CliniciansAnalytics? analytics,
  })  : _subscription = subscriptionCubit,
        _analytics = analytics,
        super(const PlansUiState());

  final SubscriptionEntitlementCubit _subscription;
  final CliniciansAnalytics? _analytics;
  bool _paywallViewScheduled = false;

  static String purchaseOutcomeParam(SubscriptionPurchaseOutcome o) =>
      switch (o) {
        SubscriptionPurchaseOutcome.success => 'success',
        SubscriptionPurchaseOutcome.cancelled => 'cancelled',
        SubscriptionPurchaseOutcome.offeringsUnavailable =>
          'offerings_unavailable',
        SubscriptionPurchaseOutcome.notConfigured => 'not_configured',
        SubscriptionPurchaseOutcome.failed => 'failed',
      };

  /// Dispara o evento de paywall uma vez quando o ecrã fica visível.
  void tryLogPaywallViewIfNeeded({required String source}) {
    final sub = _subscription.state;
    if (sub.isPro || sub.loading || _paywallViewScheduled) return;
    _paywallViewScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _analytics?.logPaywallView(source: source);
    });
  }

  void setAnnual({required bool isAnnual}) {
    if (isAnnual == state.isAnnual) return;
    emit(state.copyWith(isAnnual: isAnnual));
  }

  Future<SubscriptionPurchaseOutcome> purchase() async {
    if (state.purchaseBusy) {
      return SubscriptionPurchaseOutcome.failed;
    }
    final annual = state.isAnnual;
    final planPeriod = annual ? 'annual' : 'monthly';
    _analytics?.logPurchaseSubmit(planPeriod: planPeriod);
    emit(state.copyWith(purchaseBusy: true));
    final outcome = await _subscription.purchaseSelectedPlan(annual: annual);
    emit(state.copyWith(purchaseBusy: false));
    _analytics?.logPurchaseOutcome(result: purchaseOutcomeParam(outcome));
    return outcome;
  }
}
