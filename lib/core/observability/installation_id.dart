import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kInstallationIdKey = 'cl_session_installation_id';

/// ID estável por instalação (não é PII); usado como `deviceId` do session
/// logger.
Future<String> readOrCreateInstallationId(SharedPreferences prefs) async {
  var id = prefs.getString(_kInstallationIdKey);
  if (id == null || id.isEmpty) {
    id = const Uuid().v4();
    await prefs.setString(_kInstallationIdKey, id);
  }
  return id;
}
