/// Tipo de operação de sync.
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Representa uma operação de sincronização pendente.
class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
    this.lastAttemptAt,
  });

  factory SyncOperation.fromMap(Map<String, dynamic> map) {
    return SyncOperation(
      id: map['id'] as String,
      type: SyncOperationType.values.byName(map['type'] as String),
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      data: Map<String, dynamic>.from(map['data'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      attempts: map['attempts'] as int? ?? 0,
      lastError: map['lastError'] as String?,
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'] as String)
          : null,
    );
  }

  final String id;
  final SyncOperationType type;

  /// 'meal' ou 'connection'.
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  final DateTime? lastAttemptAt;

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? attempts,
    String? lastError,
    DateTime? lastAttemptAt,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  /// Incrementa tentativas e registra erro.
  SyncOperation withError(String error) {
    return copyWith(
      attempts: attempts + 1,
      lastError: error,
      lastAttemptAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'lastError': lastError,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    };
  }
}
