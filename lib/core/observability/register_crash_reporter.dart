import 'package:app_yummy_log_clinicians/core/observability/session_logger_error_reporter.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:get_it/get_it.dart';

/// Regista o reporter de erros tratados
/// (só `SessionLogger`, sem Sentry direto).
void registerCrashReporterIfNeeded(GetIt getIt) {
  if (getIt.isRegistered<CrashReporter>()) return;
  final impl = SessionLoggerErrorReporter(getIt);
  getIt.registerSingleton<CrashReporter>(impl.record);
}
