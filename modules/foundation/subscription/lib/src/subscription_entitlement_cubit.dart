import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:subscription_foundation/src/subscription_constants.dart';

/// Resultado de compra in-app (RevenueCat / lojas).
enum SubscriptionPurchaseOutcome {
  success,
  cancelled,
  offeringsUnavailable,
  notConfigured,
  failed,
}

/// Resultado de restaurar compras.
enum SubscriptionRestoreOutcome {
  success,
  nothingFound,
  notConfigured,
  failed,
}

class SubscriptionEntitlementState extends Equatable {
  const SubscriptionEntitlementState({
    required this.isPro,
    required this.loading,
  });

  const SubscriptionEntitlementState.initial()
      : isPro = false,
        loading = true;

  final bool isPro;
  final bool loading;

  SubscriptionEntitlementState copyWith({
    bool? isPro,
    bool? loading,
  }) {
    return SubscriptionEntitlementState(
      isPro: isPro ?? this.isPro,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [isPro, loading];
}

/// Estado da assinatura Clínicos (entitlement RevenueCat) + Firebase Auth.
class SubscriptionEntitlementCubit extends Cubit<SubscriptionEntitlementState> {
  SubscriptionEntitlementCubit({
    required AuthRepository authRepository,
    CrashReporter? crashReporter,
  })  : _auth = authRepository,
        _crashReporter = crashReporter,
        super(const SubscriptionEntitlementState.initial()) {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    _authSub = _auth.authStateChanges.listen(_onAuthUserChanged);
    unawaited(_bootstrap());
  }

  final AuthRepository _auth;
  final CrashReporter? _crashReporter;
  late final StreamSubscription<AuthUser?> _authSub;

  void _report(
    Object e,
    StackTrace? st, {
    required String hint,
    Map<String, Object?>? extras,
  }) {
    _crashReporter?.call(
      e,
      st,
      feature: 'subscription',
      hint: hint,
      extras: extras,
    );
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    if (isClosed) return;
    emit(_stateFrom(info));
  }

  Future<void> _bootstrap() async {
    if (!await Purchases.isConfigured) {
      emit(const SubscriptionEntitlementState(isPro: false, loading: false));
      return;
    }
    await _syncRevenueCatUser(_auth.currentUser);
    await refresh();
  }

  Future<void> _onAuthUserChanged(AuthUser? user) async {
    await _syncRevenueCatUser(user);
    await refresh();
  }

  Future<void> _syncRevenueCatUser(AuthUser? user) async {
    if (!await Purchases.isConfigured) return;
    try {
      if (user != null) {
        await Purchases.logIn(user.uid);
      } else {
        await Purchases.logOut();
      }
    } on Object catch (e, st) {
      debugPrint('SubscriptionEntitlementCubit RevenueCat user sync: $e $st');
      _report(e, st, hint: 'revenuecat_user_sync');
    }
  }

  Future<void> refresh() async {
    if (!await Purchases.isConfigured) {
      emit(state.copyWith(isPro: false, loading: false));
      return;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      emit(_stateFrom(info));
    } on Object catch (e, st) {
      debugPrint('SubscriptionEntitlementCubit refresh: $e $st');
      _report(e, st, hint: 'customer_info_refresh');
      emit(state.copyWith(loading: false));
    }
  }

  SubscriptionEntitlementState _stateFrom(CustomerInfo info) {
    final active =
        info.entitlements.active[kCliniciansProEntitlementId] != null;
    return SubscriptionEntitlementState(isPro: active, loading: false);
  }

  Package? _packageFor(Offerings offerings, {required bool annual}) {
    final current = offerings.current;
    if (current == null) return null;
    for (final pkg in current.availablePackages) {
      if (annual && pkg.packageType == PackageType.annual) return pkg;
      if (!annual && pkg.packageType == PackageType.monthly) return pkg;
    }
    return null;
  }

  Future<SubscriptionPurchaseOutcome> purchaseSelectedPlan({
    required bool annual,
  }) async {
    if (!await Purchases.isConfigured) {
      return SubscriptionPurchaseOutcome.notConfigured;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final pkg = _packageFor(offerings, annual: annual);
      if (pkg == null) {
        return SubscriptionPurchaseOutcome.offeringsUnavailable;
      }
      try {
        await Purchases.purchase(PurchaseParams.package(pkg));
      } on PlatformException catch (e, st) {
        final code = PurchasesErrorHelper.getErrorCode(e);
        if (code == PurchasesErrorCode.purchaseCancelledError) {
          return SubscriptionPurchaseOutcome.cancelled;
        }
        _report(e, st, hint: 'purchase_platform', extras: {'code': e.code});
        return SubscriptionPurchaseOutcome.failed;
      }
      return SubscriptionPurchaseOutcome.success;
    } on Object catch (e, st) {
      debugPrint('purchaseSelectedPlan: $e $st');
      _report(e, st, hint: 'purchase_or_offerings');
      return SubscriptionPurchaseOutcome.failed;
    }
  }

  Future<SubscriptionRestoreOutcome> restorePurchases() async {
    if (!await Purchases.isConfigured) {
      return SubscriptionRestoreOutcome.notConfigured;
    }
    try {
      final info = await Purchases.restorePurchases();
      emit(_stateFrom(info));
      final isPro =
          info.entitlements.active[kCliniciansProEntitlementId] != null;
      return isPro
          ? SubscriptionRestoreOutcome.success
          : SubscriptionRestoreOutcome.nothingFound;
    } on Object catch (e, st) {
      debugPrint('restorePurchases: $e $st');
      _report(e, st, hint: 'restore_purchases');
      return SubscriptionRestoreOutcome.failed;
    }
  }

  @override
  Future<void> close() async {
    if (await Purchases.isConfigured) {
      Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    }
    await _authSub.cancel();
    return super.close();
  }
}
