import 'package:ui_kit/ui_kit.dart';

/// Configuração do design system do app Yummy Log.
///
/// Centraliza em [lib/] a definição do tema; no futuro pode ser resolvido
/// por segmento (free/paid) ou via DI (GetIt).
DesignSystemConfig get yummyLogDesignConfig =>
    DesignSystemConfig.defaultConfig();
