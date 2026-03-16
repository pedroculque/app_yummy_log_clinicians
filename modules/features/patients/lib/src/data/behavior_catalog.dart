/// Catálogo padrão de comportamentos do formulário.
///
/// Única fonte da verdade para "quais comportamentos existem" e "em que ordem".
/// Cada entrada pode ter [categoryKey] para agrupar na tela de config.
class BehaviorCatalogEntry {
  const BehaviorCatalogEntry({
    required this.id,
    required this.l10nKey,
    this.categoryKey,
  });

  /// ID no Firestore (form_config/behavior.behaviors) e no app do paciente.
  final String id;

  /// Chave de localização do label (ex.: behaviorHiddenFood) nos ARBs.
  final String l10nKey;

  /// Chave l10n do título da categoria. Null = usar "Outros" ou genérico.
  final String? categoryKey;
}

/// Lista padrão de comportamentos, na ordem de exibição na tela de config.
abstract final class BehaviorCatalog {
  static const List<BehaviorCatalogEntry> entries = [
    // Métodos compensatórios
    BehaviorCatalogEntry(
      id: 'forcedVomit',
      l10nKey: 'behaviorForcedVomit',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    BehaviorCatalogEntry(
      id: 'usedLaxatives',
      l10nKey: 'behaviorUsedLaxatives',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    BehaviorCatalogEntry(
      id: 'diuretics',
      l10nKey: 'behaviorDiuretics',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    BehaviorCatalogEntry(
      id: 'otherMedication',
      l10nKey: 'behaviorOtherMedication',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    BehaviorCatalogEntry(
      id: 'compensatoryExercise',
      l10nKey: 'behaviorCompensatoryExercise',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    BehaviorCatalogEntry(
      id: 'chewAndSpit',
      l10nKey: 'behaviorChewAndSpit',
      categoryKey: 'formConfigCategoryCompensatory',
    ),
    // Restrição alimentar
    BehaviorCatalogEntry(
      id: 'intermittentFast',
      l10nKey: 'behaviorIntermittentFast',
      categoryKey: 'formConfigCategoryRestriction',
    ),
    BehaviorCatalogEntry(
      id: 'skipMeal',
      l10nKey: 'behaviorSkipMeal',
      categoryKey: 'formConfigCategoryRestriction',
    ),
    // Exagero alimentar
    BehaviorCatalogEntry(
      id: 'bingeEating',
      l10nKey: 'behaviorBingeEating',
      categoryKey: 'formConfigCategoryBinge',
    ),
    // Outros
    BehaviorCatalogEntry(
      id: 'ateInSecret',
      l10nKey: 'behaviorAteInSecret',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'guiltAfterEating',
      l10nKey: 'behaviorGuiltAfterEating',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'calorieCounting',
      l10nKey: 'behaviorCalorieCounting',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'bodyChecking',
      l10nKey: 'behaviorBodyChecking',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'bodyWeighing',
      l10nKey: 'behaviorBodyWeighing',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'hiddenFood',
      l10nKey: 'behaviorHiddenFood',
      categoryKey: 'formConfigCategoryOther',
    ),
    BehaviorCatalogEntry(
      id: 'regurgitated',
      l10nKey: 'behaviorRegurgitated',
      categoryKey: 'formConfigCategoryOther',
    ),
  ];

  /// IDs na mesma ordem que [entries], para uso em toFirestore e iteração.
  static List<String> get ids => entries.map((e) => e.id).toList();

  /// Agrupa [entries] por categoryKey (ordem de aparição das categorias).
  static Map<String?, List<BehaviorCatalogEntry>> get entriesByCategory {
    final map = <String?, List<BehaviorCatalogEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.categoryKey, () => []).add(e);
    }
    return map;
  }
}
