import 'dart:ui';

/// Typedef para função que altera o idioma.
typedef SetLocaleCallback = Future<void> Function(Locale locale);

/// Typedef para função que retorna o idioma atual.
typedef GetLocaleCallback = Locale Function();

/// Serviço para gerenciar o idioma do app.
/// Registrado no GetIt para ser acessível em qualquer módulo.
class LocaleService {
  LocaleService({
    required this.getLocale,
    required this.setLocale,
  });

  final GetLocaleCallback getLocale;
  final SetLocaleCallback setLocale;
}
