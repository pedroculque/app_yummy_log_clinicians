import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:insights_feature/src/cubit/insights_state.dart';
import 'package:insights_feature/src/data/insights_repository.dart';
import 'package:insights_feature/src/domain/insights_summary.dart';
import 'package:subscription_foundation/subscription_foundation.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required InsightsRepository repository,
    required AuthRepository authRepository,
    required SubscriptionEntitlementCubit subscriptionCubit,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
  })  : _repository = repository,
        _authRepository = authRepository,
        _subscriptionCubit = subscriptionCubit,
        _analytics = analytics,
        _crashReporter = crashReporter,
        super(const InsightsState()) {
    _authSubscription = authRepository.authStateChanges.listen(_onAuthChanged);
    _entitlementSubscription = subscriptionCubit.stream.listen((subState) {
      if (isClosed || subState.loading) return;
      unawaited(load());
    });
  }

  final InsightsRepository _repository;
  final AuthRepository _authRepository;
  final SubscriptionEntitlementCubit _subscriptionCubit;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;
  StreamSubscription<dynamic>? _subscription;
  late final StreamSubscription<AuthUser?> _authSubscription;
  late final StreamSubscription<SubscriptionEntitlementState>
      _entitlementSubscription;

  static const int _freeInsightsPeriodDays = 7;

  int get _effectivePeriodDays {
    if (_subscriptionCubit.state.isPro) return state.period.days;
    return _freeInsightsPeriodDays;
  }

  void _onAuthChanged(AuthUser? user) {
    final uid = user?.uid;
    if (uid == _lastLoadedUid) return;
    _lastLoadedUid = uid;
    unawaited(load());
  }

  String? _lastLoadedUid;

  Future<void> load() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: InsightsStatus.loaded,
          summary: const InsightsSummary.empty(),
        ),
      );
      return;
    }

    _lastLoadedUid = user.uid;
    emit(state.copyWith(status: InsightsStatus.loading));

    try {
      final summary = await _repository.getInsights(
        user.uid,
        periodDays: _effectivePeriodDays,
      );
      emit(
        state.copyWith(
          status: InsightsStatus.loaded,
          summary: summary,
          lastUpdated: DateTime.now(),
        ),
      );
    } on Object catch (e, st) {
      _crashReporter?.call(
        e,
        st,
        feature: 'insights',
        hint: 'load_summary',
      );
      emit(
        state.copyWith(
          status: InsightsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changePeriod(InsightsPeriod period) async {
    if (!_subscriptionCubit.state.isPro) return;
    if (period == state.period) return;
    emit(state.copyWith(period: period));
    await load();
    _analytics?.logInsightsPeriodSet(days: period.days);
  }

  void logInsightsPatientDrill({required String target}) {
    _analytics?.logInsightsPatientDrill(target: target);
  }

  Future<void> refresh() async {
    await load();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _entitlementSubscription.cancel();
    await _authSubscription.cancel();
    return super.close();
  }
}
