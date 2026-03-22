import 'package:flutter/foundation.dart';

/// Filtrar consola: `[ClinicianProfilePhoto]` (apenas em modo debug).
void logClinicianProfilePhoto(String message) {
  if (kDebugMode) {
    debugPrint('[ClinicianProfilePhoto] $message');
  }
}

/// Resumo de URL para logs (tokens Firebase são longos).
String clinicianProfilePhotoUrlHint(String? url) {
  if (url == null || url.isEmpty) return '(empty)';
  if (url.length <= 64) return url;
  return '${url.substring(0, 64)}…(len=${url.length})';
}
