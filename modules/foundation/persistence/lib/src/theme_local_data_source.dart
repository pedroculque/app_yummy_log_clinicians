import 'package:flutter/material.dart';

/// Interface para persistência da preferência de tema.
abstract class ThemeLocalDataSource {
  /// Retorna o [ThemeMode] salvo, ou null se não houver preferência.
  Future<ThemeMode?> getThemeMode();

  /// Salva a preferência de [ThemeMode].
  Future<void> setThemeMode(ThemeMode mode);
}
