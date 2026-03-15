/// Interface para operações remotas de refeições (Firestore).
abstract class MealSyncRemote {
  /// Cria ou atualiza uma refeição no remoto.
  Future<void> upsert(String userId, Map<String, dynamic> entry);

  /// Marca uma refeição como excluída (soft delete).
  Future<void> softDelete(String userId, String mealId);

  /// Observa mudanças desde [since]. Emite listas incrementais.
  Stream<List<Map<String, dynamic>>> watchChanges(
    String userId,
    DateTime since,
  );

  /// Busca todas as refeições do usuário (para full pull).
  Future<List<Map<String, dynamic>>> fetchAll(String userId);
}
