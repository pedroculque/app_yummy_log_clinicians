import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistence_foundation/persistence_foundation.dart';

/// Cubit para gerenciar o modo de tema do app.
///
/// O tema padrão é [ThemeMode.light]. A preferência do usuário é
/// persistida via [ThemeLocalDataSource].
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._dataSource) : super(ThemeMode.light);

  final ThemeLocalDataSource _dataSource;

  /// Carrega a preferência salva. Deve ser chamado no startup.
  Future<void> init() async {
    final saved = await _dataSource.getThemeMode();
    emit(saved ?? ThemeMode.light);
  }

  /// Altera o tema e persiste a preferência.
  Future<void> setTheme(ThemeMode mode) async {
    await _dataSource.setThemeMode(mode);
    emit(mode);
  }

  /// Alterna entre light e dark.
  Future<void> toggle() async {
    final newMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }
}
