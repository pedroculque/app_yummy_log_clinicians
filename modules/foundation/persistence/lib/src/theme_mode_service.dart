import 'package:flutter/material.dart';

/// Typedef para função que altera o tema.
typedef SetThemeModeCallback = Future<void> Function(ThemeMode mode);

/// Typedef para função que retorna o tema atual.
typedef GetThemeModeCallback = ThemeMode Function();

/// Serviço para gerenciar o tema do app.
/// Registrado no GetIt para ser acessível em qualquer módulo.
class ThemeModeService {
  ThemeModeService({
    required this.getThemeMode,
    required this.setThemeMode,
  });

  final GetThemeModeCallback getThemeMode;
  final SetThemeModeCallback setThemeMode;
}
