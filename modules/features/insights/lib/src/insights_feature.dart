import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/src/cubit/insights_cubit.dart';
import 'package:insights_feature/src/cubit/patient_analytics_cubit.dart';
import 'package:insights_feature/src/data/insights_repository.dart';
import 'package:insights_feature/src/domain/patient_insight.dart';
import 'package:insights_feature/src/pages/insights_page.dart';
import 'package:insights_feature/src/pages/insights_pro_upsell_page.dart';
import 'package:insights_feature/src/pages/patient_analytics_page.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:subscription_foundation/subscription_foundation.dart';

class InsightsFeature implements YummyLogFeature {
  @override
  String get name => 'insights';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerLazySingleton<InsightsRepository>(
        () => FirestoreInsightsRepository(
          patientsRepository: getIt<PatientsRepository>(),
          mealsRepository: getIt<PatientMealsRepository>(),
        ),
      )
      ..registerFactory<InsightsCubit>(
        () => InsightsCubit(
          repository: getIt<InsightsRepository>(),
          authRepository: getIt<AuthRepository>(),
          subscriptionCubit: getIt<SubscriptionEntitlementCubit>(),
          analytics: getIt.isRegistered<CliniciansAnalytics>()
              ? getIt<CliniciansAnalytics>()
              : null,
          crashReporter: getIt.isRegistered<CrashReporter>()
              ? getIt<CrashReporter>()
              : null,
        ),
      );
  }

  @override
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    return [
      GoRoute(
        path: '/insights',
        builder: (context, state) => RepositoryProvider<AuthRepository>.value(
          value: getIt<AuthRepository>(),
          child: BlocProvider(
            create: (_) => getIt<InsightsCubit>(),
            child: const InsightsPage(),
          ),
        ),
      ),
      GoRoute(
        path: '/insights/score-help',
        builder: (context, state) => const _ScoreHelpRoutePage(),
      ),
    ];
  }

  List<RouteBase> getFullScreenRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    return [
      GoRoute(
        path: '/insights/patient-detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final insight = state.extra as PatientInsight?;
          return BlocProvider.value(
            value: getIt<SubscriptionEntitlementCubit>(),
            child: _InsightsProRouteGate(
              buildForAccess: ({required hasPro}) {
                if (!hasPro) return const InsightsProUpsellPage();
                return _PatientDetailRoutePage(insight: insight);
              },
            ),
          );
        },
      ),
      GoRoute(
        path: '/patients/:patientId/analytics',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final patientId = state.pathParameters['patientId']!;
          final patientName =
              state.uri.queryParameters['name'] ?? '';
          return BlocProvider.value(
            value: getIt<SubscriptionEntitlementCubit>(),
            child: _InsightsProRouteGate(
              buildForAccess: ({required hasPro}) {
                if (!hasPro) return const InsightsProUpsellPage();
                final cubit = PatientAnalyticsCubit(
                  patientId: patientId,
                  mealsRepository: getIt<PatientMealsRepository>(),
                  analytics: getIt.isRegistered<CliniciansAnalytics>()
                      ? getIt<CliniciansAnalytics>()
                      : null,
                  crashReporter: getIt.isRegistered<CrashReporter>()
                      ? getIt<CrashReporter>()
                      : null,
                );
                return PatientAnalyticsPage(
                  patientId: patientId,
                  patientName: patientName,
                  cubit: cubit,
                );
              },
            ),
          );
        },
      ),
    ];
  }
}

class _ScoreHelpRoutePage extends StatelessWidget {
  const _ScoreHelpRoutePage();

  @override
  Widget build(BuildContext context) {
    return const InsightsPage(scoreHelpMode: true);
  }
}

class _InsightsProRouteGate extends StatelessWidget {
  const _InsightsProRouteGate({required this.buildForAccess});

  final Widget Function({required bool hasPro}) buildForAccess;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionEntitlementCubit,
        SubscriptionEntitlementState>(
      buildWhen: (p, c) =>
          p.isPro != c.isPro || p.loading != c.loading,
      builder: (context, sub) {
        if (sub.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildForAccess(hasPro: sub.isPro);
      },
    );
  }
}

class _PatientDetailRoutePage extends StatelessWidget {
  const _PatientDetailRoutePage({required this.insight});

  final PatientInsight? insight;

  @override
  Widget build(BuildContext context) {
    return PatientDetailPage(insight: insight);
  }
}
