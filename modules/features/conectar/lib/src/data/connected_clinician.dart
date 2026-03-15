/// Status de sincronização (local only).
enum ConnectionSyncStatus { synced, pending, error }

/// Modelo de um clínico conectado (nutricionista).
class ConnectedClinician {
  const ConnectedClinician({
    required this.id,
    required this.code,
    required this.displayName,
    required this.linkedAt,
    this.clinicianUid,
    this.profession,
    this.crn,
    this.bio,
    this.email,
    this.whatsapp,
    this.photoUrl,
    this.status = 'active',
    this.updatedAt,
    this.syncStatus = ConnectionSyncStatus.pending,
  });

  factory ConnectedClinician.fromJson(Map<String, dynamic> json) {
    final syncName = json['syncStatus'] as String?;
    return ConnectedClinician(
      id: json['id'] as String,
      code: json['code'] as String,
      displayName: json['displayName'] as String? ?? 'Nutricionista',
      linkedAt: DateTime.parse(json['linkedAt'] as String),
      clinicianUid: json['clinicianUid'] as String?,
      profession: json['profession'] as String?,
      crn: json['crn'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      whatsapp: json['whatsapp'] as String?,
      photoUrl: json['photoUrl'] as String?,
      status: json['status'] as String? ?? 'active',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      syncStatus: syncName != null
          ? ConnectionSyncStatus.values.firstWhere((e) => e.name == syncName,
              orElse: () => ConnectionSyncStatus.pending)
          : ConnectionSyncStatus.pending,
    );
  }

  final String id;
  final String code;
  final String displayName;
  final DateTime linkedAt;
  /// Firebase UID do clínico (preenchido quando backend resolver o código).
  final String? clinicianUid;
  final String? profession;
  final String? crn;
  final String? bio;
  final String? email;
  final String? whatsapp;
  final String? photoUrl;
  /// 'active' ou 'removed'.
  final String status;
  final DateTime? updatedAt;
  /// Local only — não persiste no Firestore.
  final ConnectionSyncStatus syncStatus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'displayName': displayName,
        'linkedAt': linkedAt.toIso8601String(),
        'clinicianUid': clinicianUid,
        'profession': profession,
        'crn': crn,
        'bio': bio,
        'email': email,
        'whatsapp': whatsapp,
        'photoUrl': photoUrl,
        'status': status,
        'updatedAt': updatedAt?.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  /// JSON para envio ao Firestore (sem campos locais).
  Map<String, dynamic> toFirestoreJson() => {
        'id': id,
        'code': code,
        'displayName': displayName,
        'linkedAt': linkedAt.toIso8601String(),
        'clinicianUid': clinicianUid,
        'profession': profession,
        'crn': crn,
        'bio': bio,
        'email': email,
        'whatsapp': whatsapp,
        'photoUrl': photoUrl,
        'status': status,
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  ConnectedClinician copyWith({
    String? id,
    String? code,
    String? displayName,
    DateTime? linkedAt,
    String? clinicianUid,
    String? profession,
    String? crn,
    String? bio,
    String? email,
    String? whatsapp,
    String? photoUrl,
    String? status,
    DateTime? updatedAt,
    ConnectionSyncStatus? syncStatus,
  }) {
    return ConnectedClinician(
      id: id ?? this.id,
      code: code ?? this.code,
      displayName: displayName ?? this.displayName,
      linkedAt: linkedAt ?? this.linkedAt,
      clinicianUid: clinicianUid ?? this.clinicianUid,
      profession: profession ?? this.profession,
      crn: crn ?? this.crn,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
