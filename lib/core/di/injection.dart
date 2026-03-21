import 'package:app_yummy_log_clinicians/app/app.dart';
import 'package:app_yummy_log_clinicians/core/analytics/init_analytics_user_binding.dart';
import 'package:app_yummy_log_clinicians/core/app_rating/clinician_app_rating_modal.dart';
import 'package:app_yummy_log_clinicians/core/app_rating/shared_preferences_rating_storage.dart';
import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:insights_feature/insights_feature.dart';
import 'package:package_analytics/package_analytics.dart';
import 'package:package_app_rating/package_app_rating.dart';
import 'package:package_firebase_analytics/package_firebase_analytics.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:settings_feature/settings_feature.dart'
    show AuthCubit, SettingsFeature, createProfilePhotoSheet;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subscription_foundation/subscription_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

/// Instância global do service locator.
final GetIt getIt = GetIt.instance;

/// Configura todas as dependências do app (foundation + features).
/// Chamar no startup, depois de initPersistence(getIt) e initAuth(getIt).
Future<void> configureDependencies({
  AppBuildFlavor flavor = AppBuildFlavor.production,
}) async {
  if (getIt.isRegistered<AppBuildFlavorConfig>()) {
    await getIt.unregister<AppBuildFlavorConfig>();
  }

  final prefs = await SharedPreferences.getInstance();

  if (!getIt.isRegistered<AnalyticsLogger>()) {
    final clients = <AnalyticsClient>[
      if (Firebase.apps.isNotEmpty)
        FirebaseAnalyticsClient(firebaseAnalytics: FirebaseAnalytics.instance)
      else
        ConsoleAnalyticsClient(),
    ];
    final analyticsLogger = AnalyticsLoggerImpl(
      clients: clients,
      config: const AnalyticsLoggerConfig(showDebugLogs: kDebugMode),
    );
    await analyticsLogger.initialize();
    getIt.registerSingleton<AnalyticsLogger>(analyticsLogger);
  }

  if (!getIt.isRegistered<AppRating>()) {
    final appRating = AppRating(
      config: AppRatingConfig(
        appleStoreId: '0',
        androidPackageId: 'com.yummylogdiaryforclinicians.app',
        // enabled: pedidos automáticos ativos (default do AppRatingConfig).
        triggers: [
          const SessionTrigger(minSessions: 6),
          CountTrigger(actionsRequired: 10),
          TimeTrigger.betweenPrompts(days: 30),
          TimeTrigger.afterPostpone(days: 7),
        ],
      ),
      storage: SharedPreferencesRatingStorage(prefs),
      modalProvider: const DefaultAppRatingModalProvider(
        showClinicianAppRatingModal,
      ),
      translations: const AppRatingTranslations(
        title: 'appRatingModalTitle',
        subtitle: 'appRatingModalSubtitle',
        buttonText: 'appRatingButton',
      ),
      onEvent: (event) {
        getIt<AnalyticsLogger>().logEvent(
          event.name,
          params: {
            for (final e in event.params.entries) e.key: e.value as Object?,
          },
        );
      },
    );
    await appRating.initialize();
    getIt.registerSingleton<AppRating>(appRating);
  }

  getIt
    ..registerSingleton<AppBuildFlavorConfig>(AppBuildFlavorConfig(flavor))
    ..registerSingleton<ProfilePhotoSheet>(
      createProfilePhotoSheet(getIt),
    );

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
    )
    ..registerSingleton<AuthCubit>(
      AuthCubit(
        authRepository: getIt<AuthRepository>(),
        photoUploadService: getIt<PhotoUploadService>(),
        userDocumentWriter: getIt<UserDocumentWriter>(),
        userProfileReader: getIt<UserProfileReader>(),
        patientsRepository: getIt<PatientsRepository>(),
        clearPushRegistration: () =>
            getIt<ClinicianNotificationService>().clearCurrentToken(),
      ),
    )
    ..registerSingleton<SubscriptionEntitlementCubit>(
      SubscriptionEntitlementCubit(
        authRepository: getIt<AuthRepository>(),
      ),
    );

  initAnalyticsUserBinding(getIt);
}
