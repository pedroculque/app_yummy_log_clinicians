import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistence_foundation/persistence_foundation.dart';

/// Cubit para gerenciar o idioma do app.
///
/// No primeiro uso, detecta o idioma do sistema e persiste.
/// Se o idioma do sistema não for suportado (pt, en, es), usa pt como fallback.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._dataSource) : super(_fallbackLocale);

  final LocaleLocalDataSource _dataSource;

  static const _supportedLocales = ['pt', 'en', 'es'];
  static const _fallbackLocale = Locale('pt');

  /// Carrega a preferência salva ou detecta o idioma do sistema.
  /// Deve ser chamado no startup.
  Future<void> init() async {
    final saved = await _dataSource.getLocale();
    if (saved != null) {
      emit(saved);
      return;
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    final detected = _supportedLocales.contains(systemLocale.languageCode)
        ? Locale(systemLocale.languageCode)
        : _fallbackLocale;

    await _dataSource.setLocale(detected);
    emit(detected);
  }

  /// Altera o idioma e persiste a preferência.
  Future<void> setLocale(Locale locale) async {
    await _dataSource.setLocale(locale);
    emit(locale);
  }
}
