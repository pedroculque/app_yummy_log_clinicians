import 'package:feature_contract/feature_contract.dart';
import 'package:get_it/get_it.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:settings_feature/src/data/notification_push_preferences_repository.dart';

/// Dependências de UI para a página de configurações; resolvidas na rota —
/// a view não usa GetIt.
class SettingsPageDependencies {
  const SettingsPageDependencies({
    required this.showPushTokenDebug,
    required this.notificationPushPreferencesRepository,
    required this.themeModeService,
    required this.localeService,
  });

  /// Resolve a partir do service locator (apenas na composição da feature / router).
  factory SettingsPageDependencies.fromGetIt(GetIt getIt) {
    return SettingsPageDependencies(
      showPushTokenDebug: getIt.isRegistered<AppBuildFlavorConfig>() &&
          getIt<AppBuildFlavorConfig>().showPushTokenDebug,
      notificationPushPreferencesRepository:
          getIt<NotificationPushPreferencesRepository>(),
      themeModeService: getIt<ThemeModeService>(),
      localeService: getIt<LocaleService>(),
    );
  }

  /// Dev/staging: mostrar tiles de debug APNS/FCM (flavor).
  final bool showPushTokenDebug;

  final NotificationPushPreferencesRepository
      notificationPushPreferencesRepository;
  final ThemeModeService themeModeService;
  final LocaleService localeService;
}
