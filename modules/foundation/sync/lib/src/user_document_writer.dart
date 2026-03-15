/// Garante que o documento do usuário exista na coleção `users` do Firestore.
///
/// Sem isso, a coleção "users" aparece vazia no console, pois o app só grava
/// em subcoleções (users/{userId}/meals e users/{userId}/connections).
// ignore: one_member_abstracts — interface para injeção e testes, alinhada aos *Remote
abstract class UserDocumentWriter {
  /// Cria ou atualiza o documento [users/{userId}] para que o usuário
  /// apareça no Firestore. Usa merge para não sobrescrever dados existentes.
  Future<void> ensureExists(
    String userId, {
    String? email,
    String? displayName,
    String? photoUrl,
  });
}
