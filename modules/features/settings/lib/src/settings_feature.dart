import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_feature/src/cubit/auth_cubit.dart';
import 'package:settings_feature/src/data/notification_push_preferences_repository.dart';
import 'package:settings_feature/src/pages/plans_page.dart';
import 'package:settings_feature/src/pages/settings_page.dart';

/// Feature Configurações: Login, idioma, aparência, etc.
class SettingsFeature implements YummyLogFeature {
  @override
  String get name => 'settings';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerSingleton<NotificationPushPreferencesRepository>(
        NotificationPushPreferencesRepository(),
      )
      ..registerSingleton<AuthCubit>(
        AuthCubit(
          authRepository: getIt<AuthRepository>(),
        ),
      );
  }

  @override
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) =>
      [
        GoRoute(
          path: '/settings',
          builder: (context, state) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SettingsPage(),
          ),
        ),
      ];

  List<RouteBase> getFullScreenRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) =>
      [
        GoRoute(
          path: '/plans',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const PlansPage(),
        ),
      ];
}
