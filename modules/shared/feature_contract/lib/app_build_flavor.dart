/// Flavor do build (alinhado a `main_development` / `main_staging` / `main_production`).
enum AppBuildFlavor {
  development,
  staging,
  production,
}

/// Registrado no GetIt no startup do app.
class AppBuildFlavorConfig {
  const AppBuildFlavorConfig(this.flavor);

  final AppBuildFlavor flavor;

  /// Tokens APNS/FCM de debug em Configurações — só fora de produção.
  bool get showPushTokenDebug => flavor != AppBuildFlavor.production;
}
