import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:app_yummy_log_clinicians/core/router/app_shell.dart';
import 'package:auth_foundation/auth_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/insights_feature.dart';
import 'package:package_analytics/package_analytics.dart';
import 'package:package_session_logger/package_session_logger.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:settings_feature/settings_feature.dart';
import 'package:subscription_foundation/subscription_foundation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Configuração do go_router com tab bar (StatefulShellRoute).
/// Login NÃO é obrigatório para acessar o app.
/// Login é solicitado apenas quando o usuário tenta convidar pacientes.
GoRouter createAppRouter() {
  final patientsFeature = PatientsFeature();
  final insightsFeature = InsightsFeature();
  final settingsFeature = SettingsFeature();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/patients',
    debugLogDiagnostics: true,
    observers: [
      AnalyticsRouteObserver(
        logger: getIt<AnalyticsLogger>(),
        sessionLogger: getIt<SessionLogger>(),
      ),
    ],
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthFlowCubit>(),
          child: LoginPage(
            onSuccess: () => context.go('/patients'),
            onSkip: () => context.go('/patients'),
          ),
        ),
      ),
      ...patientsFeature.getFullScreenRoutes(
        getIt,
        rootNavigatorKey: _rootNavigatorKey,
      ),
      ...insightsFeature.getFullScreenRoutes(
        getIt,
        rootNavigatorKey: _rootNavigatorKey,
      ),
      ...settingsFeature.getFullScreenRoutes(
        getIt,
        rootNavigatorKey: _rootNavigatorKey,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BlocProvider.value(
          value: getIt<SubscriptionEntitlementCubit>(),
          child: AppShell(
            navigationShell: navigationShell,
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: patientsFeature.getRoutes(getIt),
          ),
          StatefulShellBranch(routes: insightsFeature.getRoutes(getIt)),
          StatefulShellBranch(routes: settingsFeature.getRoutes(getIt)),
        ],
      ),
    ],
  );
}
