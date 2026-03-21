import 'package:app_yummy_log_clinicians/core/observability/installation_id.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:package_session_logger/package_session_logger.dart';
import 'package:session_sentry/session_sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regista `SessionLogger` no `GetIt` e chama `initialize()`.
Future<void> registerSessionLogger(
  GetIt getIt, {
  required SharedPreferences prefs,
}) async {
  if (getIt.isRegistered<SessionLogger>()) return;

  final packageInfo = await PackageInfo.fromPlatform();
  final installationId = await readOrCreateInstallationId(prefs);
  final sentryClient = SentrySessionClient();

  final sessionLogger = SessionLoggerImpl(
    config: SessionLoggerConfig(
      deviceId: installationId,
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      strategy: kDebugMode ? SendStrategy.realtime : SendStrategy.onError,
      showDebugLogs: kDebugMode,
    ),
    clients: [sentryClient],
  );

  await sessionLogger.initialize();
  getIt.registerSingleton<SessionLogger>(sessionLogger);
}
