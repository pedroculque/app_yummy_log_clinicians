/// Status da sincronização.
enum SyncServiceStatus {
  idle,
  syncing,
  error,

  /// Usuário não logado (sync desabilitado).
  disabled,
}
