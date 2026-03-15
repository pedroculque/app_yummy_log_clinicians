/// Estratégia de resolução de conflitos.
enum ConflictStrategy {
  lastWriteWins,
  localWins,
  remoteWins,
}

/// Resultado da resolução de conflito.
class ConflictResult<T> {
  const ConflictResult({
    required this.resolved,
    required this.winner,
    this.hadConflict = false,
  });

  final T resolved;

  /// 'local' ou 'remote'.
  final String winner;
  final bool hadConflict;
}

/// Interface para resolução de conflitos.
abstract class ConflictResolver<T> {
  ConflictResult<T> resolve({
    required T local,
    required T remote,
    ConflictStrategy strategy = ConflictStrategy.lastWriteWins,
  });

  bool hasConflict(T local, T remote);
}

/// Resolver baseado em timestamp (updatedAt).
class TimestampConflictResolver<T> implements ConflictResolver<T> {
  const TimestampConflictResolver({required this.getUpdatedAt});

  final DateTime Function(T entity) getUpdatedAt;

  @override
  ConflictResult<T> resolve({
    required T local,
    required T remote,
    ConflictStrategy strategy = ConflictStrategy.lastWriteWins,
  }) {
    switch (strategy) {
      case ConflictStrategy.localWins:
        return ConflictResult(
          resolved: local,
          winner: 'local',
          hadConflict: true,
        );
      case ConflictStrategy.remoteWins:
        return ConflictResult(
          resolved: remote,
          winner: 'remote',
          hadConflict: true,
        );
      case ConflictStrategy.lastWriteWins:
        return _resolveByTimestamp(local, remote);
    }
  }

  @override
  bool hasConflict(T local, T remote) {
    return getUpdatedAt(local) != getUpdatedAt(remote);
  }

  ConflictResult<T> _resolveByTimestamp(T local, T remote) {
    final localTime = getUpdatedAt(local);
    final remoteTime = getUpdatedAt(remote);

    if (localTime.isAfter(remoteTime)) {
      return ConflictResult(
        resolved: local,
        winner: 'local',
        hadConflict: true,
      );
    }

    return ConflictResult(
      resolved: remote,
      winner: 'remote',
      hadConflict: true,
    );
  }
}
