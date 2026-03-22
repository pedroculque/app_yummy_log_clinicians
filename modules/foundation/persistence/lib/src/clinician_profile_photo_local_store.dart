import 'package:persistence_foundation/src/clinician_profile_photo_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda a última URL de avatar do clínico logado (e token alinhado ao
/// `CachedNetworkImage.cacheKey`). Sobrevive a cold start / rebuild; **não**
/// sobrevive a desinstalar a app. O ficheiro em disco do `CachedNetworkImage`
/// pode ser limpo pelo SO — por isso rebaixamos a URL cedo para voltar a
/// descarregar a imagem.
class ClinicianProfilePhotoLocalStore {
  ClinicianProfilePhotoLocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _uidKey = 'clinician_self_profile_uid_v1';
  static const _urlKey = 'clinician_self_profile_url_v1';
  static const _tokenKey = 'clinician_self_profile_cache_token_v1';

  /// Última URL conhecida para [uid], ou null se não houver / outro utilizador.
  ({String url, String? cacheToken})? readForUid(String uid) {
    final storedUid = _prefs.getString(_uidKey);
    if (storedUid != uid) {
      logClinicianProfilePhoto(
        'disk.read miss uid=$uid storedUid=${storedUid ?? '(null)'}',
      );
      return null;
    }
    final url = _prefs.getString(_urlKey);
    if (url == null || url.isEmpty) {
      logClinicianProfilePhoto('disk.read miss uid=$uid url empty');
      return null;
    }
    final token = _prefs.getString(_tokenKey);
    logClinicianProfilePhoto(
      'disk.read hit uid=$uid url=${clinicianProfilePhotoUrlHint(url)} '
      'token=${token ?? '(null)'}',
    );
    return (url: url, cacheToken: token);
  }

  Future<void> write({
    required String uid,
    required String url,
    String? cacheToken,
  }) async {
    final prevUid = _prefs.getString(_uidKey);
    final prevUrl = _prefs.getString(_urlKey);
    await _prefs.setString(_uidKey, uid);
    await _prefs.setString(_urlKey, url);
    if (cacheToken != null && cacheToken.isNotEmpty) {
      await _prefs.setString(_tokenKey, cacheToken);
      logClinicianProfilePhoto(
        'disk.write uid=$uid url=${clinicianProfilePhotoUrlHint(url)} '
        'token=$cacheToken',
      );
    } else {
      final uidChanged = prevUid != null && prevUid != uid;
      final urlChanged = prevUrl != null && prevUrl != url;
      if (uidChanged || urlChanged) {
        await _prefs.remove(_tokenKey);
        logClinicianProfilePhoto(
          'disk.write uid=$uid url=${clinicianProfilePhotoUrlHint(url)} '
          'token=(cleared)',
        );
      } else {
        logClinicianProfilePhoto(
          'disk.write uid=$uid url=${clinicianProfilePhotoUrlHint(url)} '
          'token=(kept, no new cacheToken)',
        );
      }
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_uidKey);
    await _prefs.remove(_urlKey);
    await _prefs.remove(_tokenKey);
    logClinicianProfilePhoto('disk.clear');
  }
}
