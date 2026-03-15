/// Resultado de uma operação de sync.
class SyncResult {
  const SyncResult({
    required this.success,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    this.errors = const [],
  });

  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsResolved;
  final List<String> errors;

  int get totalSynced => uploadedCount + downloadedCount;
  bool get hasErrors => errors.isNotEmpty;
}
