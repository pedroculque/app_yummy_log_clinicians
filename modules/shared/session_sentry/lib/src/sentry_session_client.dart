import 'package:flutter/foundation.dart';
import 'package:package_session_logger/package_session_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Erro sintético para logs do session logger (mensagem + stack em string).
class _SessionLoggerReportedError implements Exception {
  _SessionLoggerReportedError(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Session logger → Sentry: [LogType.error] vira exception; resto, breadcrumb.
/// Contexto de sessão no scope antes dos logs.
class SentrySessionClient implements SessionClient {
  @override
  String get name => 'sentry';

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> sendSession(SessionData session) async {
    if (!Sentry.isEnabled) return true;
    try {
      await Sentry.configureScope((scope) async {
        await scope.setTag('session_logger_id', session.sessionId);
        await scope.setTag('session_logger_platform', session.platform);
        await scope.setContexts('session_logger', {
          'session_id': session.sessionId,
          'started_at': session.startedAt.toIso8601String(),
          if (session.endedAt != null)
            'ended_at': session.endedAt!.toIso8601String(),
          'device_id': session.deviceId,
          'app_version': session.appVersion,
          if (session.userHash != null) 'user_hash': session.userHash,
          if (session.endReason != null) 'end_reason': session.endReason!.name,
        });
      });

      const maxLogs = 120;
      final logs = session.logs;
      final start = logs.length > maxLogs ? logs.length - maxLogs : 0;

      for (var i = start; i < logs.length; i++) {
        final log = logs[i];
        if (log.type == LogType.error) {
          await _sendError(log, session.sessionId);
        } else {
          await _addBreadcrumb(log);
        }
      }
      return true;
    } on Object catch (e, st) {
      debugPrint('[SentrySessionClient] sendSession failed: $e $st');
      return false;
    }
  }

  Future<void> _sendError(LogEntry log, String sessionId) async {
    final message = log.errorMessage ?? log.name;
    final error = _SessionLoggerReportedError(message);
    StackTrace? stackTrace;
    final raw = log.stackTrace;
    if (raw != null && raw.isNotEmpty) {
      try {
        stackTrace = StackTrace.fromString(raw);
      } on Object {
        stackTrace = null;
      }
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async {
        scope.fingerprint = [
          'session_logger',
          log.name,
          log.context ?? 'no_context',
        ];
        await scope.setTag('session_logger', 'true');
        await scope.setTag('session_logger_log_id', log.id);
        await scope.setTag('session_id', sessionId);
        if (log.context != null) {
          await scope.setTag('session_logger_context', log.context!);
        }
        if (log.data != null && log.data!.isNotEmpty) {
          await scope.setContexts('session_logger_error_data', {
            for (final e in log.data!.entries) e.key: e.value,
          });
        }
      },
    );
  }

  Future<void> _addBreadcrumb(LogEntry log) async {
    final data = <String, Object?>{
      if (log.data != null) ...log.data!,
      if (log.errorMessage != null) 'error': log.errorMessage,
      if (log.context != null) 'ctx': log.context,
    };
    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: '${log.type.name}:${log.name}',
        level: _breadcrumbLevel(log.level),
        timestamp: log.timestamp.toUtc(),
        data: data.isEmpty ? null : data,
      ),
    );
  }

  SentryLevel _breadcrumbLevel(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return SentryLevel.error;
      case LogLevel.warning:
        return SentryLevel.warning;
      case LogLevel.debug:
        return SentryLevel.debug;
      case LogLevel.info:
        return SentryLevel.info;
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    await Sentry.configureScope((scope) async {
      if (userId == null) {
        await scope.setUser(null);
        await scope.removeTag('user');
        await scope.removeTag('support_id');
      } else {
        await scope.setUser(SentryUser(id: userId));
        await scope.setTag('user', userId);
        await scope.setTag('support_id', userId);
      }
    });
  }

  @override
  Future<void> dispose() async {}
}
