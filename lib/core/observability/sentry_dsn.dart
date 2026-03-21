/// DSN do Sentry via `--dart-define=SENTRY_DSN=...` (não commitar segredos).
String sentryDsnFromEnvironment() {
  const dsn = String.fromEnvironment('SENTRY_DSN');
  return dsn.trim();
}
