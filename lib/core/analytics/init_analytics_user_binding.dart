import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:package_analytics/package_analytics.dart';

bool _analyticsUserBindingStarted = false;

/// Sincroniza o utilizador do [AuthRepository] com o [AnalyticsLogger]
/// (mobile-foundation: `package_analytics` + Firebase).
///
/// - Login / sessão existente: [AnalyticsLogger.setUserId] com `uid`.
/// - Logout: [AnalyticsLogger.resetAnalyticsData] (Firebase Analytics).
///
/// Chamar uma vez após registar `AnalyticsLogger` no service locator (ex.:
/// fim de `configureDependencies`).
void initAnalyticsUserBinding(GetIt getIt) {
  if (_analyticsUserBindingStarted) return;
  if (!getIt.isRegistered<AnalyticsLogger>()) return;

  _analyticsUserBindingStarted = true;
  final logger = getIt<AnalyticsLogger>();
  final auth = getIt<AuthRepository>();

  Future<void> apply(AuthUser? user) async {
    if (user == null) {
      await logger.resetAnalyticsData();
    } else {
      logger.setUserId(user.uid);
    }
  }

  auth.authStateChanges.listen((user) {
    unawaited(apply(user));
  });
}
