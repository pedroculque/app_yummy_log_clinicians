import 'package:cloud_firestore/cloud_firestore.dart';

/// IDs dos comportamentos do formulário (MVP: 5 existentes no MealEntry).
/// Ordem de exibição na tela de configuração.
const List<String> kFormConfigBehaviorIds = [
  'hiddenFood',
  'regurgitated',
  'forcedVomit',
  'ateInSecret',
  'usedLaxatives',
];

/// Entrada do log de alterações da config (quem alterou e quando).
class FormConfigChangeLogEntry {
  const FormConfigChangeLogEntry({
    required this.at,
    required this.by,
    this.displayName,
  });

  factory FormConfigChangeLogEntry.fromMap(Map<String, dynamic> map) {
    final at = map['at'];
    final DateTime atParsed;
    if (at is DateTime) {
      atParsed = at;
    } else if (at is Timestamp) {
      atParsed = at.toDate();
    } else {
      atParsed = DateTime.parse(map['at'] as String? ?? '');
    }
    return FormConfigChangeLogEntry(
      at: atParsed,
      by: map['by'] as String? ?? '',
      displayName: map['displayName'] as String?,
    );
  }

  final DateTime at;
  final String by;
  final String? displayName;

  Map<String, dynamic> toMap() => {
        'at': at.toUtc().toIso8601String(),
        'by': by,
        if (displayName != null) 'displayName': displayName,
      };
}

/// Configuração do formulário de comportamento do paciente
/// (persistida em Firestore).
class BehaviorFormConfig {
  const BehaviorFormConfig({
    this.sectionEnabled = true,
    this.updatedAt,
    this.updatedBy,
    this.updatedByDisplayName,
    Map<String, bool>? behaviors,
    List<FormConfigChangeLogEntry>? changeLog,
  })  : behaviors = behaviors ?? const {},
        changeLog = changeLog ?? const [];

  factory BehaviorFormConfig.fromFirestore(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const BehaviorFormConfig();
    }
    final changeLogRaw = data['changeLog'] as List<dynamic>?;
    final changeLog = changeLogRaw
            ?.map((e) => FormConfigChangeLogEntry.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList() ??
        const <FormConfigChangeLogEntry>[];
    final behaviorsRaw = data['behaviors'] as Map<String, dynamic>?;
    final behaviors = behaviorsRaw != null
        ? behaviorsRaw.map((k, v) => MapEntry(k, v == true))
        : <String, bool>{};
    final updatedAtRaw = data['updatedAt'];
    final updatedAt = updatedAtRaw == null
        ? null
        : updatedAtRaw is DateTime
            ? updatedAtRaw
            : updatedAtRaw is Timestamp
                ? updatedAtRaw.toDate()
                : DateTime.tryParse(updatedAtRaw as String? ?? '');

    return BehaviorFormConfig(
      sectionEnabled: data['sectionEnabled'] as bool? ?? true,
      updatedAt: updatedAt,
      updatedBy: data['updatedBy'] as String?,
      updatedByDisplayName: data['updatedByDisplayName'] as String?,
      behaviors: behaviors,
      changeLog: changeLog,
    );
  }

  final bool sectionEnabled;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? updatedByDisplayName;
  final Map<String, bool> behaviors;
  final List<FormConfigChangeLogEntry> changeLog;

  /// Valor do comportamento (true = mostrar no form).
  /// Se não definido, considera true para MVP.
  bool isBehaviorEnabled(String behaviorId) =>
      behaviors[behaviorId] ?? true;

  BehaviorFormConfig copyWith({
    bool? sectionEnabled,
    DateTime? updatedAt,
    String? updatedBy,
    String? updatedByDisplayName,
    Map<String, bool>? behaviors,
    List<FormConfigChangeLogEntry>? changeLog,
  }) {
    return BehaviorFormConfig(
      sectionEnabled: sectionEnabled ?? this.sectionEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByDisplayName:
          updatedByDisplayName ?? this.updatedByDisplayName,
      behaviors: behaviors ?? this.behaviors,
      changeLog: changeLog ?? this.changeLog,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sectionEnabled': sectionEnabled,
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
      'updatedBy': updatedBy,
      'updatedByDisplayName': updatedByDisplayName,
      'behaviors': behaviors,
      'changeLog': changeLog.map((e) => e.toMap()).toList(),
    };
  }
}
