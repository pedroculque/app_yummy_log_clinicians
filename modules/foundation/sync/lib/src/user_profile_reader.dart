/// Dados de perfil em `users/{userId}` (foto + token para cache de imagem).
class UserProfileSnapshot {
  const UserProfileSnapshot({this.photoUrl, this.cacheToken});

  final String? photoUrl;
  /// Muda quando o documento é atualizado (ex.: `updatedAt`) — invalida cache
  /// local se a URL do Storage for reutilizada no mesmo path.
  final String? cacheToken;
}

/// Lê perfil em Firestore (foto quando o Auth não reflete ou está atrasado).
abstract class UserProfileReader {
  /// Retorna a URL da foto do usuário em `users/{userId}`, ou null se não existir.
  Future<String?> getPhotoUrl(String userId);

  /// Leitura única do documento (login, merge com Auth).
  Future<UserProfileSnapshot> readSnapshot(String userId);

  /// Atualizações em tempo real (ex.: foto alterada noutro dispositivo).
  Stream<UserProfileSnapshot> watchSnapshot(String userId);
}
