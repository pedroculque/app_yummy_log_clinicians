import 'package:flutter/material.dart';
import 'package:persistence_foundation/src/theme_local_data_source.dart';
import 'package:sembast/sembast.dart';

const String _storeName = 'app_settings';
const String _themeKey = 'theme_mode';

/// Implementação do [ThemeLocalDataSource] usando Sembast.
class SembastThemeLocalDataSource implements ThemeLocalDataSource {
  SembastThemeLocalDataSource(this._db);

  final Database _db;

  static final StoreRef<String, dynamic> _store =
      StoreRef<String, dynamic>(_storeName);

  @override
  Future<ThemeMode?> getThemeMode() async {
    final value = await _store.record(_themeKey).get(_db);
    if (value == null) return null;
    return _stringToThemeMode(value as String);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await _store.record(_themeKey).put(_db, _themeModeToString(mode));
  }

  static String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static ThemeMode? _stringToThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}
