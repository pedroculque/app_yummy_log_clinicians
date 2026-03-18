import 'package:meal_domain/meal_domain.dart';
import 'package:yummy_log_l10n/l10n/gen/app_localizations.dart';

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

String amountEatenLabel(AmountEaten amount, AppLocalizations l10n) {
  return switch (amount) {
    AmountEaten.nothing => l10n.amountNothing,
    AmountEaten.aLittle => l10n.amountLittle,
    AmountEaten.half => l10n.amountHalf,
    AmountEaten.most => l10n.amountMost,
    AmountEaten.all => l10n.amountAll,
  };
}

String feelingLabel(FeelingLabel feeling, AppLocalizations l10n) {
  return switch (feeling) {
    FeelingLabel.sad => l10n.feelingSad,
    FeelingLabel.nothing => l10n.feelingNothing,
    FeelingLabel.happy => l10n.feelingHappy,
    FeelingLabel.proud => l10n.feelingProud,
    FeelingLabel.angry => l10n.feelingAngry,
  };
}

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
