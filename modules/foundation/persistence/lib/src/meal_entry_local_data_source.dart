/// Interface para persistência local das entradas do diário (refeições).
/// A implementação usa Sembast; a feature diary converte entre modelo e Map.
abstract class MealEntryLocalDataSource {
  /// Salva uma entrada. [id] deve ser único; se já existir, substitui.
  Future<void> save(String id, Map<String, dynamic> entry);

  /// Retorna todas as entradas, ordenadas por data/hora (mais recente primeiro).
  Future<List<Map<String, dynamic>>> getAll();

  /// Remove uma entrada pelo [id].
  Future<void> delete(String id);

  /// Retorna entradas com syncStatus != 'synced' (pendentes de upload).
  Future<List<Map<String, dynamic>>> getUnsyncedEntries();

  /// Retorna entradas modificadas desde [since] (para sync incremental).
  Future<List<Map<String, dynamic>>> getEntriesModifiedSince(DateTime since);

  /// Faz merge de entradas vindas do remoto usando updatedAt como critério
  /// (last-write-wins). Retorna os IDs que foram efetivamente atualizados.
  Future<List<String>> mergeFromRemote(List<Map<String, dynamic>> remote);
}
