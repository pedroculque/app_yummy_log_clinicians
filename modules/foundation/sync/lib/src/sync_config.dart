import 'package:sync_foundation/src/conflict_resolver.dart';

/// Configurações de sincronização.
class SyncConfig {
  const SyncConfig({
    this.autoSyncEnabled = true,
    this.syncIntervalSeconds = 30,
    this.maxRetries = 3,
    this.retryDelaySeconds = 5,
    this.batchSize = 50,
    this.conflictStrategy = ConflictStrategy.lastWriteWins,
    this.syncOnConnectivity = true,
    this.syncOnAppResume = true,
  });

  final bool autoSyncEnabled;
  final int syncIntervalSeconds;
  final int maxRetries;
  final int retryDelaySeconds;
  final int batchSize;
  final ConflictStrategy conflictStrategy;
  final bool syncOnConnectivity;
  final bool syncOnAppResume;

  SyncConfig copyWith({
    bool? autoSyncEnabled,
    int? syncIntervalSeconds,
    int? maxRetries,
    int? retryDelaySeconds,
    int? batchSize,
    ConflictStrategy? conflictStrategy,
    bool? syncOnConnectivity,
    bool? syncOnAppResume,
  }) {
    return SyncConfig(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncIntervalSeconds:
          syncIntervalSeconds ?? this.syncIntervalSeconds,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelaySeconds:
          retryDelaySeconds ?? this.retryDelaySeconds,
      batchSize: batchSize ?? this.batchSize,
      conflictStrategy:
          conflictStrategy ?? this.conflictStrategy,
      syncOnConnectivity:
          syncOnConnectivity ?? this.syncOnConnectivity,
      syncOnAppResume: syncOnAppResume ?? this.syncOnAppResume,
    );
  }
}
