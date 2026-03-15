import 'package:get_it/get_it.dart';
import 'package:persistence_foundation/src/connection_local_data_source.dart';
import 'package:persistence_foundation/src/locale_local_data_source.dart';
import 'package:persistence_foundation/src/meal_entry_local_data_source.dart';
import 'package:persistence_foundation/src/sembast_connection_local_data_source.dart';
import 'package:persistence_foundation/src/sembast_locale_local_data_source.dart';
import 'package:persistence_foundation/src/sembast_meal_entry_local_data_source.dart';
import 'package:persistence_foundation/src/sembast_theme_local_data_source.dart';
import 'package:persistence_foundation/src/theme_local_data_source.dart';

/// Inicializa a persistência (abre o banco Sembast) e registra no [getIt].
/// Chamar uma vez no startup, antes de runApp.
Future<void> initPersistence(GetIt getIt) async {
  final mealDs = await SembastMealEntryLocalDataSource.open();
  getIt.registerSingleton<MealEntryLocalDataSource>(mealDs);

  final connDs = SembastConnectionLocalDataSource(mealDs.database);
  getIt.registerSingleton<ConnectionLocalDataSource>(connDs);

  final themeDs = SembastThemeLocalDataSource(mealDs.database);
  getIt.registerSingleton<ThemeLocalDataSource>(themeDs);

  final localeDs = SembastLocaleLocalDataSource(mealDs.database);
  getIt.registerSingleton<LocaleLocalDataSource>(localeDs);
}
