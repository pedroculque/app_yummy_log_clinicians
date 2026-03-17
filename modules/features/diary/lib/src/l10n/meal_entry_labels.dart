import 'package:diary_feature/src/domain/meal_entry.dart';
import 'package:yummy_log_l10n/l10n/gen/app_localizations.dart';

/// Retorna o rótulo localizado para [MealType].
String mealTypeLabel(MealType type, AppLocalizations l10n) {
  return switch (type) {
    MealType.breakfast => l10n.mealTypeBreakfast,
    MealType.lunch => l10n.mealTypeLunch,
    MealType.dinner => l10n.mealTypeDinner,
    MealType.supper => l10n.mealTypeSupper,
    MealType.morningSnack => l10n.mealTypeMorningSnack,
    MealType.afternoonSnack => l10n.mealTypeAfternoonSnack,
    MealType.eveningSnack => l10n.mealTypeEveningSnack,
  };
}

/// Retorna o rótulo localizado para [AmountEaten].
String amountEatenLabel(AmountEaten amount, AppLocalizations l10n) {
  return switch (amount) {
    AmountEaten.nothing => l10n.amountNothing,
    AmountEaten.aLittle => l10n.amountLittle,
    AmountEaten.half => l10n.amountHalf,
    AmountEaten.most => l10n.amountMost,
    AmountEaten.all => l10n.amountAll,
  };
}

/// Retorna o rótulo localizado para [FeelingLabel].
String feelingLabel(FeelingLabel feeling, AppLocalizations l10n) {
  return switch (feeling) {
    FeelingLabel.sad => l10n.feelingSad,
    FeelingLabel.nothing => l10n.feelingNothing,
    FeelingLabel.happy => l10n.feelingHappy,
    FeelingLabel.proud => l10n.feelingProud,
    FeelingLabel.angry => l10n.feelingAngry,
  };
}

/// Retorna o rótulo localizado para "onde comeu".
/// Valores conhecidos: `home`, `work`, `restaurant`, `other` (chaves estáveis).
/// Outros textos são exibidos como digitados (ex.: apps antigos).
String whereAteDisplay(String? key, AppLocalizations l10n) {
  if (key == null || key.isEmpty) return '';
  final k = key.trim().toLowerCase();
  return switch (k) {
    'home' => l10n.whereAteHome,
    'work' => l10n.whereAteWork,
    'restaurant' => l10n.whereAteRestaurant,
    'other' => l10n.whereAteOther,
    _ => key.trim(),
  };
}
