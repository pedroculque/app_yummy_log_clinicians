import 'dart:async';

import 'package:app_yummy_log_clinicians/app/app.dart';
import 'package:app_yummy_log_clinicians/bootstrap.dart';
import 'package:app_yummy_log_clinicians/core/auth/init_auth.dart';
import 'package:app_yummy_log_clinicians/core/di/injection.dart';
import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:app_yummy_log_clinicians/core/router/app_router.dart';
import 'package:feature_contract/app_build_flavor.dart';
import 'package:flutter/widgets.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPersistence(getIt);
  await initAuth(getIt);
  // App do clínico: não observa users/{uid}/meals nem connections (evita permission-denied).
  initSync(getIt, config: const SyncConfig(watchersEnabled: false));
  await configureDependencies(flavor: AppBuildFlavor.development);
  await getIt<ThemeModeCubit>().init();
  await getIt<LocaleCubit>().init();
  final router = createAppRouter();
  unawaited(getIt<ClinicianNotificationService>().attachRouter(router));
  await bootstrap(() => App(router: router));
}
