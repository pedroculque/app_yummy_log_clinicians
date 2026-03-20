import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Cores da paleta clínica (teal) — alinhadas ao logo YummyLog Clínicos.
///
/// Base: #0D5C63 (teal escuro), #67A1A5 (teal claro do ícone).
class _CliniciansColors {
  // --- Light theme
  static const Color primary = Color(0xFF0D5C63);
  static const Color primaryLight = Color(0xFF67A1A5);
  static const Color primaryDark = Color(0xFF0A3D42);

  static const Color secondary = Color(0xFF44A1A0);
  static const Color secondaryLight = Color(0xFF7BC4C3);
  static const Color secondaryDark = Color(0xFF2E7D6E);

  // --- Dark theme (primary mais claro sobre fundo escuro)
  static const Color primaryDarkTheme = Color(0xFF67A1A5);
  static const Color primaryLightDarkTheme = Color(0xFF8BB9BC);
  static const Color primaryDarkDarkTheme = Color(0xFF0D5C63);

  static const Color secondaryDarkTheme = Color(0xFF7BC4C3);
  static const Color secondaryLightDarkTheme = Color(0xFFA8D9D8);
  static const Color secondaryDarkDarkTheme = Color(0xFF44A1A0);
}

/// Configuração do design system do app Yummy Log Clínicos.
///
/// Usa paleta teal para diferenciar do app paciente (periwinkle).
/// Centraliza em [lib/] a definição do tema; no futuro pode ser resolvido
/// por segmento (free/paid) ou via DI (GetIt).
DesignSystemConfig get yummyLogDesignConfig => _YummyLogCliniciansConfig._();

class _YummyLogCliniciansConfig extends DesignSystemConfig {
  _YummyLogCliniciansConfig._();

  static final DesignSystemConfig _default = DesignSystemConfig.defaultConfig();

  static const ColorPalette _lightColors = ColorPalette(
    primary: _CliniciansColors.primary,
    primaryLight: _CliniciansColors.primaryLight,
    primaryDark: _CliniciansColors.primaryDark,
    backgroundDefault: Color(0xFFFFFFFF),
    secondary: _CliniciansColors.secondary,
    secondaryLight: _CliniciansColors.secondaryLight,
    secondaryDark: _CliniciansColors.secondaryDark,
    gray: Color(0xFF6C7278),
    grayLight: Color(0xFFF0F3F5),
    grayDark: Color(0xFF4A4F54),
    success: Color(0xFF4DC591),
    successLight: Color(0xFFEDF9F4),
    successDark: Color(0xFF348B65),
    error: Color(0xFFFF5A4F),
    errorLight: Color(0xFFFFE4E2),
    errorDark: Color(0xFFB23D35),
    alert: Color(0xFFFFC670),
    alertLight: Color(0xFFFFEDD3),
    alertDark: Color(0xFFC39754),
    neutralWhite: Color(0xFFFFFFFF),
    neutralBlack: Color(0xFF1A1C1E),
    neutralSilver: Color(0xFFFAF9F9),
  );

  static const ColorPalette _darkColors = ColorPalette(
    primary: _CliniciansColors.primaryDarkTheme,
    primaryLight: _CliniciansColors.primaryLightDarkTheme,
    primaryDark: _CliniciansColors.primaryDarkDarkTheme,
    backgroundDefault: Color(0xFF1A1C1E),
    secondary: _CliniciansColors.secondaryDarkTheme,
    secondaryLight: _CliniciansColors.secondaryLightDarkTheme,
    secondaryDark: _CliniciansColors.secondaryDarkDarkTheme,
    gray: Color(0xFF9CA3AF),
    grayLight: Color(0xFF3C3E42),
    grayDark: Color(0xFF6C7278),
    success: Color(0xFF4DC591),
    successLight: Color(0xFF1B3D2E),
    successDark: Color(0xFF348B65),
    error: Color(0xFFFF5A4F),
    errorLight: Color(0xFF4A2020),
    errorDark: Color(0xFFB23D35),
    alert: Color(0xFFFFC670),
    alertLight: Color(0xFF4A3820),
    alertDark: Color(0xFFC39754),
    neutralWhite: Color(0xFFFFFFFF),
    neutralBlack: Color(0xFFE8E8E8),
    neutralSilver: Color(0xFF2C2E30),
  );

  @override
  ColorPalette get lightColors => _lightColors;

  @override
  ColorPalette get darkColors => _darkColors;

  @override
  TypographyPalette get lightTypography => _default.lightTypography;

  @override
  TypographyPalette get darkTypography => _default.darkTypography;
}
