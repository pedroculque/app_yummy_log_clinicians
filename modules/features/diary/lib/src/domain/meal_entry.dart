/// Tipo de refeição (Qual Refeição?).
enum MealType {
  breakfast('Café da manhã'),
  lunch('Almoço'),
  dinner('Jantar'),
  supper('Ceia'),
  morningSnack('Lanche da manhã'),
  afternoonSnack('Lanche da tarde'),
  eveningSnack('Lanche da noite');

  const MealType(this.label);
  final String label;
}

/// Quanto comeu (opcional).
enum AmountEaten {
  nothing('Nada'),
  aLittle('Um pouco'),
  half('Metade'),
  most('A maior parte'),
  all('Tudo');

  const AmountEaten(this.label);
  final String label;
}

/// Sentimento pré-definido (Como você se sentiu?).
enum FeelingLabel {
  sad('Triste'),
  nothing('Nada'),
  happy('Alegre'),
  proud('Orgulho'),
  angry('Raivoso');

  const FeelingLabel(this.label);
  final String label;
}

/// Status de sincronização (local only — não persiste no Firestore).
enum SyncStatus { synced, pending, error }

/// Entrada do diário (uma refeição registrada).
class MealEntry {
  const MealEntry({
    required this.id,
    required this.mealType,
    required this.dateTime,
    this.userId,
    this.description,
    this.feelingLabel,
    this.feelingText,
    this.whereAte,
    this.ateWithOthers,
    this.amountEaten,
    this.photoPath,
    this.photoUrl,
    this.hiddenFood,
    this.regurgitated,
    this.forcedVomit,
    this.ateInSecret,
    this.usedLaxatives,
    this.updatedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.pending,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    final mealTypeName = json['mealType'] as String;
    final mealType = MealType.values.firstWhere((e) => e.name == mealTypeName);
    final syncName = json['syncStatus'] as String?;
    return MealEntry(
      id: json['id'] as String,
      mealType: mealType,
      dateTime: DateTime.parse(json['dateTime'] as String),
      userId: json['userId'] as String?,
      description: json['description'] as String?,
      feelingLabel: json['feelingLabel'] != null
          ? FeelingLabel.values
              .firstWhere((e) => e.name == json['feelingLabel'] as String)
          : null,
      feelingText: json['feelingText'] as String?,
      whereAte: json['whereAte'] as String?,
      ateWithOthers: json['ateWithOthers'] as bool?,
      amountEaten: json['amountEaten'] != null
          ? AmountEaten.values
              .firstWhere((e) => e.name == json['amountEaten'] as String)
          : null,
      photoPath: json['photoPath'] as String?,
      photoUrl: json['photoUrl'] as String?,
      hiddenFood: json['hiddenFood'] as bool?,
      regurgitated: json['regurgitated'] as bool?,
      forcedVomit: json['forcedVomit'] as bool?,
      ateInSecret: json['ateInSecret'] as bool?,
      usedLaxatives: json['usedLaxatives'] as bool?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      syncStatus: syncName != null
          ? SyncStatus.values.firstWhere((e) => e.name == syncName,
              orElse: () => SyncStatus.pending)
          : SyncStatus.pending,
    );
  }

  final String id;
  final MealType mealType;
  final DateTime dateTime;
  /// ID do usuário (Firebase UID) após login; null = apenas locais.
  final String? userId;
  /// Descrição do que comeu (exibida quando não há foto).
  final String? description;
  final FeelingLabel? feelingLabel;
  final String? feelingText;
  final String? whereAte;
  final bool? ateWithOthers;
  final AmountEaten? amountEaten;
  /// Caminho local da foto (cache offline).
  final String? photoPath;
  /// URL da foto no Cloud Storage (sync).
  final String? photoUrl;
  final bool? hiddenFood;
  final bool? regurgitated;
  final bool? forcedVomit;
  final bool? ateInSecret;
  final bool? usedLaxatives;
  /// Timestamp da última modificação (resolução de conflitos no sync).
  final DateTime? updatedAt;
  /// Soft delete: quando não-nulo, a entrada foi excluída logicamente.
  final DateTime? deletedAt;
  /// Status de sync local (não persiste no Firestore).
  final SyncStatus syncStatus;

  MealEntry copyWith({
    String? id,
    MealType? mealType,
    DateTime? dateTime,
    String? userId,
    String? description,
    FeelingLabel? feelingLabel,
    String? feelingText,
    String? whereAte,
    bool? ateWithOthers,
    AmountEaten? amountEaten,
    String? photoPath,
    String? photoUrl,
    bool? hiddenFood,
    bool? regurgitated,
    bool? forcedVomit,
    bool? ateInSecret,
    bool? usedLaxatives,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
  }) {
    return MealEntry(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      dateTime: dateTime ?? this.dateTime,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      feelingLabel: feelingLabel ?? this.feelingLabel,
      feelingText: feelingText ?? this.feelingText,
      whereAte: whereAte ?? this.whereAte,
      ateWithOthers: ateWithOthers ?? this.ateWithOthers,
      amountEaten: amountEaten ?? this.amountEaten,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      hiddenFood: hiddenFood ?? this.hiddenFood,
      regurgitated: regurgitated ?? this.regurgitated,
      forcedVomit: forcedVomit ?? this.forcedVomit,
      ateInSecret: ateInSecret ?? this.ateInSecret,
      usedLaxatives: usedLaxatives ?? this.usedLaxatives,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  static const int maxFeelingTextLength = 512;
  static const int maxDescriptionLength = 512;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType.name,
      'dateTime': dateTime.toIso8601String(),
      'userId': userId,
      'description': description,
      'feelingLabel': feelingLabel?.name,
      'feelingText': feelingText,
      'whereAte': whereAte,
      'ateWithOthers': ateWithOthers,
      'amountEaten': amountEaten?.name,
      'photoPath': photoPath,
      'photoUrl': photoUrl,
      'hiddenFood': hiddenFood,
      'regurgitated': regurgitated,
      'forcedVomit': forcedVomit,
      'ateInSecret': ateInSecret,
      'usedLaxatives': usedLaxatives,
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
    };
  }

  /// JSON para envio ao Firestore (sem campos locais como
  /// photoPath e syncStatus).
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'mealType': mealType.name,
      'dateTime': dateTime.toIso8601String(),
      'userId': userId,
      'description': description,
      'feelingLabel': feelingLabel?.name,
      'feelingText': feelingText,
      'whereAte': whereAte,
      'ateWithOthers': ateWithOthers,
      'amountEaten': amountEaten?.name,
      'photoUrl': photoUrl,
      'hiddenFood': hiddenFood,
      'regurgitated': regurgitated,
      'forcedVomit': forcedVomit,
      'ateInSecret': ateInSecret,
      'usedLaxatives': usedLaxatives,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
