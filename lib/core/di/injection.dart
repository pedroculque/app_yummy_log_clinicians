import 'package:app_yummy_log_clinicians/app/app.dart';
import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:auth_foundation/auth_foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:insights_feature/insights_feature.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:settings_feature/settings_feature.dart';

/// Instância global do service locator.
final GetIt getIt = GetIt.instance;

/// Configura todas as dependências do app (foundation + features).
/// Chamar no startup, depois de initPersistence(getIt) e initAuth(getIt).
void configureDependencies() {
  PatientsFeature().registerDependencies(getIt);
  InsightsFeature().registerDependencies(getIt);
  SettingsFeature().registerDependencies(getIt);

  final themeCubit = ThemeModeCubit(getIt<ThemeLocalDataSource>());
  getIt
    ..registerSingleton<ThemeModeCubit>(themeCubit)
    ..registerSingleton<ThemeModeService>(
      ThemeModeService(
        getThemeMode: () => themeCubit.state,
        setThemeMode: themeCubit.setTheme,
      ),
    );

  final localeCubit = LocaleCubit(getIt<LocaleLocalDataSource>());
  getIt
    ..registerSingleton<LocaleCubit>(localeCubit)
    ..registerSingleton<LocaleService>(
      LocaleService(
        getLocale: () => localeCubit.state,
        setLocale: localeCubit.setLocale,
      ),
    )
    ..registerSingleton<ClinicianNotificationService>(
      ClinicianNotificationService(authRepository: getIt<AuthRepository>()),
    );
}
