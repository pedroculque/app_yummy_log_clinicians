import 'dart:async';

import 'package:app_yummy_log_clinicians/app/app.dart';
import 'package:app_yummy_log_clinicians/bootstrap.dart';
import 'package:app_yummy_log_clinicians/core/auth/init_auth.dart';
import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:app_yummy_log_clinicians/core/observability/register_crash_reporter.dart';
import 'package:app_yummy_log_clinicians/core/observability/register_session_logger.dart';
import 'package:app_yummy_log_clinicians/core/observability/sentry_dsn.dart';
import 'package:app_yummy_log_clinicians/core/remote_config/init_remote_config.dart';
import 'package:app_yummy_log_clinicians/core/router/app_router.dart';
import 'package:feature_contract/app_build_flavor.dart';
import 'package:flutter/foundation.dart';
import 'package:package_app_rating/package_app_rating.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:session_sentry/session_sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

/// Arranque único com [SentryFlutter.init] e corpo comum aos três flavors.
Future<void> launchClinicianApp(AppBuildFlavor flavor) async {
  SentryWidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = sentryDsnFromEnvironment()
        ..environment = flavor.name
        ..sendDefaultPii = false
        ..debug = kDebugMode
        ..beforeSend = sentryBeforeSend;
      if (kDebugMode) {
        options
          ..tracesSampleRate = 1.0
          // Profiling iOS/macOS; API experimental no sentry_flutter.
          // ignore: experimental_member_use
          ..profilesSampleRate = 1.0;
      }
    },
    appRunner: () async {
      await initPersistence(getIt);
      final prefs = await SharedPreferences.getInstance();
      await registerSessionLogger(getIt, prefs: prefs);
      registerCrashReporterIfNeeded(getIt);
      await initAuth(getIt);
      await initRemoteConfig();
      await configureRevenueCat(flavor);
      initSync(getIt, config: const SyncConfig(watchersEnabled: false));
      await configureDependencies(flavor: flavor);
      await getIt<AppRating>().trackSession();
      await getIt<ThemeModeCubit>().init();
      await getIt<LocaleCubit>().init();
      final router = createAppRouter();
      unawaited(getIt<ClinicianNotificationService>().attachRouter(router));
      await bootstrap(() => App(router: router));
    },
  );
}
