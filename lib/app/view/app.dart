import 'dart:ui' as ui;

import 'package:app_yummy_log_clinicians/app/cubit/locale_cubit.dart';
import 'package:app_yummy_log_clinicians/app/cubit/theme_mode_cubit.dart';
import 'package:app_yummy_log_clinicians/app_design_system.dart';
import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_force_update/module_force_update.dart';
import 'package:package_remote_config/package_remote_config.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class App extends StatelessWidget {
  const App({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final designConfig = yummyLogDesignConfig;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ThemeModeCubit>()),
        BlocProvider.value(value: getIt<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, ui.Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                theme: UiKitTheme.buildLight(designConfig),
                darkTheme: UiKitTheme.buildDark(designConfig),
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) {
                  return ForceUpdateChecker(
                    forceUpdateService: ForceUpdateService(
                      remoteConfig: RemoteConfig.instance,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
