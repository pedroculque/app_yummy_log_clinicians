/// Formato do código de convite do clínico (invite code).
///
/// Regras: 6 caracteres, apenas letras (A–Z) e dígitos (0–9), sempre em
/// maiúsculas. Garante unicidade e permite formatador na UI.
class ClinicianInviteCode {
  ClinicianInviteCode._();

  /// Número de caracteres do código.
  static const int length = 6;

  /// Caracteres permitidos: letras e números (sem acentos).
  static const String allowedChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static final RegExp _pattern = RegExp(r'^[A-Z0-9]{6}$');

  /// Normaliza para comparação e persistência: maiúsculas, só A–Z e 0–9.
  static String normalize(String raw) {
    return raw
        .trim()
        .toUpperCase()
        .replaceAll(RegExp('[^A-Za-z0-9]'), '');
  }

  /// Retorna true se [raw] normalizado tem exatamente [length] caracteres.
  static bool isValid(String raw) {
    final n = normalize(raw);
    return n.length == length && _pattern.hasMatch(n);
  }

  /// Retorna o código normalizado para uso (lookup, persistência).
  /// Se após normalizar tiver mais de [length] caracteres,
  /// retorna os primeiros [length].
  static String toStored(String raw) {
    final n = normalize(raw);
    if (n.length >= length) return n.substring(0, length);
    return n;
  }
}
