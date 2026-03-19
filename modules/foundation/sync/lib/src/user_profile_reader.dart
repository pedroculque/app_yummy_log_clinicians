/// Lê dados do perfil do usuário no Firestore (ex.: photoUrl quando o Auth
/// não retorna).
// ignore: one_member_abstracts — interface para injeção e testes
abstract class UserProfileReader {
  /// Retorna a URL da foto do usuário em `users/{userId}`, ou null se não existir.
  Future<String?> getPhotoUrl(String userId);
}
