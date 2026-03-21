import 'dart:async';

import 'package:app_yummy_log_clinicians/app/app.dart';
import 'package:app_yummy_log_clinicians/bootstrap.dart';
import 'package:app_yummy_log_clinicians/core/auth/init_auth.dart';
import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:app_yummy_log_clinicians/core/remote_config/init_remote_config.dart';
import 'package:app_yummy_log_clinicians/core/router/app_router.dart';
import 'package:feature_contract/app_build_flavor.dart';
import 'package:flutter/widgets.dart';
import 'package:package_app_rating/package_app_rating.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPersistence(getIt);
  await initAuth(getIt);
  await initRemoteConfig();
  await configureRevenueCat(AppBuildFlavor.production);
  initSync(getIt, config: const SyncConfig(watchersEnabled: false));
  await configureDependencies();
  await getIt<AppRating>().trackSession();
  await getIt<ThemeModeCubit>().init();
  await getIt<LocaleCubit>().init();
  final router = createAppRouter();
  unawaited(getIt<ClinicianNotificationService>().attachRouter(router));
  await bootstrap(() => App(router: router));
}
