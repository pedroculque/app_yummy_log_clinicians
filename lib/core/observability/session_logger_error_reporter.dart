import 'package:get_it/get_it.dart';
import 'package:package_session_logger/package_session_logger.dart';

/// Encaminha erros tratados para o [SessionLogger] (flush → cliente Sentry).
/// Não chama o SDK Sentry diretamente.
class SessionLoggerErrorReporter {
  SessionLoggerErrorReporter(this._getIt);

  final GetIt _getIt;

  void record(
    Object error,
    StackTrace? stackTrace, {
    required String feature,
    String? hint,
    Map<String, Object?>? extras,
  }) {
    if (!_getIt.isRegistered<SessionLogger>()) return;
    Map<String, dynamic>? data;
    if (extras != null && extras.isNotEmpty) {
      final m = <String, dynamic>{};
      for (final e in extras.entries) {
        final v = e.value;
        if (v != null) m[e.key] = v;
      }
      data = m;
    }
    final context = hint != null ? '$feature:$hint' : feature;
    _getIt<SessionLogger>().error(
      error,
      stackTrace,
      context: context,
      data: data,
    );
  }
}
