import 'package:get_it/get_it.dart';

/// Erros já tratados na UI/dados que ainda devem aparecer no Sentry
/// (tags `feature` / `hint`).
typedef CrashReporter = void Function(
  Object error,
  StackTrace? stackTrace, {
  required String feature,
  String? hint,
  Map<String, Object?>? extras,
});

/// Envia ao [CrashReporter] registado no [getIt], se existir.
void reportCaughtError(
  GetIt getIt,
  Object error,
  StackTrace? stackTrace, {
  required String feature,
  String? hint,
  Map<String, Object?>? extras,
}) {
  if (!getIt.isRegistered<CrashReporter>()) return;
  getIt<CrashReporter>()(
    error,
    stackTrace,
    feature: feature,
    hint: hint,
    extras: extras,
  );
}
