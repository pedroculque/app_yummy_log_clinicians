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

bool? _mealBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  return null;
}

/// Mesmo formato do app do paciente (`app_yummy_log`): mapa no Firestore.
Map<String, bool>? _parseBehaviorFlags(dynamic value) {
  if (value == null) return null;
  if (value is! Map) return null;
  final result = <String, bool>{};
  for (final e in value.entries) {
    final k = e.key?.toString();
    if (k == null) continue;
    result[k] = e.value == true;
  }
  return result.isEmpty ? null : result;
}

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
    this.behaviorFlags,
    this.diuretics,
    this.otherMedication,
    this.compensatoryExercise,
    this.chewAndSpit,
    this.intermittentFast,
    this.skipMeal,
    this.bingeEating,
    this.guiltAfterEating,
    this.calorieCounting,
    this.bodyChecking,
    this.bodyWeighing,
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
      ateWithOthers: _mealBool(json['ateWithOthers']),
      amountEaten: json['amountEaten'] != null
          ? AmountEaten.values
              .firstWhere((e) => e.name == json['amountEaten'] as String)
          : null,
      photoPath: json['photoPath'] as String?,
      photoUrl: json['photoUrl'] as String?,
      hiddenFood: _mealBool(json['hiddenFood']),
      regurgitated: _mealBool(json['regurgitated']),
      forcedVomit: _mealBool(json['forcedVomit']),
      ateInSecret: _mealBool(json['ateInSecret']),
      usedLaxatives: _mealBool(json['usedLaxatives']),
      behaviorFlags: _parseBehaviorFlags(json['behaviorFlags']),
      diuretics: _mealBool(json['diuretics']),
      otherMedication: _mealBool(json['otherMedication']),
      compensatoryExercise: _mealBool(json['compensatoryExercise']),
      chewAndSpit: _mealBool(json['chewAndSpit']),
      intermittentFast: _mealBool(json['intermittentFast']),
      skipMeal: _mealBool(json['skipMeal']),
      bingeEating: _mealBool(json['bingeEating']),
      guiltAfterEating: _mealBool(json['guiltAfterEating']),
      calorieCounting: _mealBool(json['calorieCounting']),
      bodyChecking: _mealBool(json['bodyChecking']),
      bodyWeighing: _mealBool(json['bodyWeighing']),
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

  /// IDs na mesma ordem do app do paciente / catálogo clínico.
  static const List<String> behaviorCatalogIds = [
    'forcedVomit',
    'usedLaxatives',
    'diuretics',
    'otherMedication',
    'compensatoryExercise',
    'chewAndSpit',
    'intermittentFast',
    'skipMeal',
    'bingeEating',
    'ateInSecret',
    'guiltAfterEating',
    'calorieCounting',
    'bodyChecking',
    'bodyWeighing',
    'hiddenFood',
    'regurgitated',
  ];

  final String id;
  final MealType mealType;
  final DateTime dateTime;
  final String? userId;
  final String? description;
  final FeelingLabel? feelingLabel;
  final String? feelingText;
  final String? whereAte;
  final bool? ateWithOthers;
  final AmountEaten? amountEaten;
  final String? photoPath;
  final String? photoUrl;
  final bool? hiddenFood;
  final bool? regurgitated;
  final bool? forcedVomit;
  final bool? ateInSecret;
  final bool? usedLaxatives;
  /// App paciente: demais comportamentos (exceto 5 legados) vêm neste mapa.
  final Map<String, bool>? behaviorFlags;
  /// Fallback top-level (ex.: refeição salva só pelo app clínico).
  final bool? diuretics;
  final bool? otherMedication;
  final bool? compensatoryExercise;
  final bool? chewAndSpit;
  final bool? intermittentFast;
  final bool? skipMeal;
  final bool? bingeEating;
  final bool? guiltAfterEating;
  final bool? calorieCounting;
  final bool? bodyChecking;
  final bool? bodyWeighing;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  bool get hasAnyBehaviorSelected =>
      behaviorCatalogIds.any(isBehaviorSelected);

  /// Cinco legados no topo do documento (igual app paciente).
  static const Set<String> _legacyTopLevelBehaviorIds = {
    'hiddenFood',
    'regurgitated',
    'forcedVomit',
    'ateInSecret',
    'usedLaxatives',
  };

  bool isBehaviorSelected(String behaviorId) {
    if (_legacyTopLevelBehaviorIds.contains(behaviorId)) {
      return switch (behaviorId) {
        'hiddenFood' => hiddenFood == true,
        'regurgitated' => regurgitated == true,
        'forcedVomit' => forcedVomit == true,
        'ateInSecret' => ateInSecret == true,
        'usedLaxatives' => usedLaxatives == true,
        _ => false,
      };
    }
    if (behaviorFlags?[behaviorId] == true) return true;
    return switch (behaviorId) {
      'diuretics' => diuretics == true,
      'otherMedication' => otherMedication == true,
      'compensatoryExercise' => compensatoryExercise == true,
      'chewAndSpit' => chewAndSpit == true,
      'intermittentFast' => intermittentFast == true,
      'skipMeal' => skipMeal == true,
      'bingeEating' => bingeEating == true,
      'guiltAfterEating' => guiltAfterEating == true,
      'calorieCounting' => calorieCounting == true,
      'bodyChecking' => bodyChecking == true,
      'bodyWeighing' => bodyWeighing == true,
      _ => false,
    };
  }

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
    Map<String, bool>? behaviorFlags,
    bool? diuretics,
    bool? otherMedication,
    bool? compensatoryExercise,
    bool? chewAndSpit,
    bool? intermittentFast,
    bool? skipMeal,
    bool? bingeEating,
    bool? guiltAfterEating,
    bool? calorieCounting,
    bool? bodyChecking,
    bool? bodyWeighing,
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
      behaviorFlags: behaviorFlags ?? this.behaviorFlags,
      diuretics: diuretics ?? this.diuretics,
      otherMedication: otherMedication ?? this.otherMedication,
      compensatoryExercise:
          compensatoryExercise ?? this.compensatoryExercise,
      chewAndSpit: chewAndSpit ?? this.chewAndSpit,
      intermittentFast: intermittentFast ?? this.intermittentFast,
      skipMeal: skipMeal ?? this.skipMeal,
      bingeEating: bingeEating ?? this.bingeEating,
      guiltAfterEating: guiltAfterEating ?? this.guiltAfterEating,
      calorieCounting: calorieCounting ?? this.calorieCounting,
      bodyChecking: bodyChecking ?? this.bodyChecking,
      bodyWeighing: bodyWeighing ?? this.bodyWeighing,
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
      'behaviorFlags': behaviorFlags,
      'diuretics': diuretics,
      'otherMedication': otherMedication,
      'compensatoryExercise': compensatoryExercise,
      'chewAndSpit': chewAndSpit,
      'intermittentFast': intermittentFast,
      'skipMeal': skipMeal,
      'bingeEating': bingeEating,
      'guiltAfterEating': guiltAfterEating,
      'calorieCounting': calorieCounting,
      'bodyChecking': bodyChecking,
      'bodyWeighing': bodyWeighing,
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
    };
  }

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
      if (behaviorFlags != null && behaviorFlags!.isNotEmpty)
        'behaviorFlags': behaviorFlags,
      if (diuretics != null) 'diuretics': diuretics,
      if (otherMedication != null) 'otherMedication': otherMedication,
      if (compensatoryExercise != null)
        'compensatoryExercise': compensatoryExercise,
      if (chewAndSpit != null) 'chewAndSpit': chewAndSpit,
      if (intermittentFast != null) 'intermittentFast': intermittentFast,
      if (skipMeal != null) 'skipMeal': skipMeal,
      if (bingeEating != null) 'bingeEating': bingeEating,
      if (guiltAfterEating != null) 'guiltAfterEating': guiltAfterEating,
      if (calorieCounting != null) 'calorieCounting': calorieCounting,
      if (bodyChecking != null) 'bodyChecking': bodyChecking,
      if (bodyWeighing != null) 'bodyWeighing': bodyWeighing,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
