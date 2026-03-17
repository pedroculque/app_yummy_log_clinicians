import 'package:yummy_log_l10n/l10n/gen/app_localizations.dart';

/// Rótulo localizado para um id do catálogo de comportamentos.
String mealBehaviorLabel(String behaviorId, AppLocalizations l10n) {
  return switch (behaviorId) {
    'forcedVomit' => l10n.behaviorForcedVomit,
    'usedLaxatives' => l10n.behaviorUsedLaxatives,
    'diuretics' => l10n.behaviorDiuretics,
    'otherMedication' => l10n.behaviorOtherMedication,
    'compensatoryExercise' => l10n.behaviorCompensatoryExercise,
    'chewAndSpit' => l10n.behaviorChewAndSpit,
    'intermittentFast' => l10n.behaviorIntermittentFast,
    'skipMeal' => l10n.behaviorSkipMeal,
    'bingeEating' => l10n.behaviorBingeEating,
    'ateInSecret' => l10n.behaviorAteInSecret,
    'guiltAfterEating' => l10n.behaviorGuiltAfterEating,
    'calorieCounting' => l10n.behaviorCalorieCounting,
    'bodyChecking' => l10n.behaviorBodyChecking,
    'bodyWeighing' => l10n.behaviorBodyWeighing,
    'hiddenFood' => l10n.behaviorHiddenFood,
    'regurgitated' => l10n.behaviorRegurgitated,
    _ => behaviorId,
  };
}
