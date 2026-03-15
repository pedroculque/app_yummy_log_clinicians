/// Interface para operações remotas de conexões com clínicos (Firestore).
abstract class ConnectionSyncRemote {
  /// Cria ou atualiza uma conexão no remoto.
  Future<void> upsert(String userId, Map<String, dynamic> connection);

  /// Remove uma conexão no remoto.
  Future<void> remove(String userId, String connectionId);

  /// Observa mudanças nas conexões do usuário.
  Stream<List<Map<String, dynamic>>> watchChanges(String userId);

  /// Busca todas as conexões do usuário (para full pull).
  Future<List<Map<String, dynamic>>> fetchAll(String userId);
}
