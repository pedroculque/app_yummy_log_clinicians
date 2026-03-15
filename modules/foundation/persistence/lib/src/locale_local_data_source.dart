import 'dart:ui';

/// Interface para persistência da preferência de idioma.
abstract class LocaleLocalDataSource {
  /// Retorna o [Locale] salvo, ou null se não houver preferência.
  Future<Locale?> getLocale();

  /// Salva a preferência de [Locale].
  Future<void> setLocale(Locale locale);
}
