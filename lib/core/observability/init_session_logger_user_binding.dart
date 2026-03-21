import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:package_session_logger/package_session_logger.dart';

bool _sessionLoggerUserBindingStarted = false;

/// Sincroniza [AuthRepository] com [SessionLogger] (`setUser` nos clientes).
///
/// Usa [AuthUser.uid] (Firebase UID) — o mesmo valor do **ID de Suporte** na UI
/// e das tags `user` / `support_id` no Sentry (`SentrySessionClient`).
/// Ver [docs/OBSERVABILITY.md](../../../docs/OBSERVABILITY.md) e
/// `modules/features/settings/docs/support-id.md`.
void initSessionLoggerUserBinding(GetIt getIt) {
  if (_sessionLoggerUserBindingStarted) return;
  if (!getIt.isRegistered<SessionLogger>()) return;

  _sessionLoggerUserBindingStarted = true;
  final sessionLogger = getIt<SessionLogger>();
  final auth = getIt<AuthRepository>();

  Future<void> apply(AuthUser? user) async {
    sessionLogger.setUser(user?.uid);
  }

  auth.authStateChanges.listen((user) {
    unawaited(apply(user));
  });
}
