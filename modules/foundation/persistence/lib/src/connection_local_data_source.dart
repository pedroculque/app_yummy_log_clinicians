/// Interface para persistência local das conexões com clínicos.
abstract class ConnectionLocalDataSource {
  /// Salva uma conexão. [id] deve ser único; se já existir, substitui.
  Future<void> save(String id, Map<String, dynamic> connection);

  /// Retorna todas as conexões.
  Future<List<Map<String, dynamic>>> getAll();

  /// Remove uma conexão pelo [id].
  Future<void> delete(String id);

  /// Retorna conexões com syncStatus != 'synced'.
  Future<List<Map<String, dynamic>>> getUnsyncedConnections();

  /// Faz merge de conexões vindas do remoto (last-write-wins por updatedAt).
  /// Retorna os IDs efetivamente atualizados.
  Future<List<String>> mergeFromRemote(List<Map<String, dynamic>> remote);
}
