// Firebase Console (projeto do app clínico):
// - Ativar Remote Config e definir parâmetros (keys em ForceUpdateConfigKeys).
// - Ativar Google Analytics / Measurement se ainda não estiver.
// - iOS: definir URL da App Store em RC (force_update_store_url_ios) e/ou
//   preencher kCliniciansIosStoreListingUrl quando o ID estiver disponível.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:module_force_update/module_force_update.dart';
import 'package:package_remote_config/package_remote_config.dart';

/// Play Store listing (package do app clínico).
const kCliniciansAndroidStoreListingUrl =
    'https://play.google.com/store/apps/details?id=com.yummylogdiaryforclinicians.app';

/// App Store: substituir pelo ID numérico real em Remote Config / App Store Connect.
const kCliniciansIosStoreListingUrl = '';

/// Intervalo mínimo entre fetches do Remote Config em produção (SDK Firebase).
/// Não há custo por fetch na faturação típica do Firebase; impacto é sobretudo
/// rede/bateria.
const kRemoteConfigMinimumFetchIntervalProduction = Duration(minutes: 2);

/// Configura [RemoteConfig] (Firebase ou in-memory se não houver Firebase).
Future<void> initRemoteConfig() async {
  final defaults = ForceUpdateDefaults.withStoreUrls(
    androidUrl: kCliniciansAndroidStoreListingUrl,
    iosUrl: kCliniciansIosStoreListingUrl,
  );

  if (Firebase.apps.isEmpty) {
    RemoteConfig.instance.configure(
      InMemoryRemoteConfigProvider(values: Map<String, dynamic>.from(defaults)),
    );
    await RemoteConfig.instance.initialize();
    return;
  }

  // Debug: intervalo 0 para alinhar logo com a consola.
  // Produção: 5 min — ver [kRemoteConfigMinimumFetchIntervalProduction].
  RemoteConfig.instance.configure(
    FirebaseRemoteConfigProvider(
      defaults: defaults,
      minimumFetchInterval: kDebugMode
          ? Duration.zero
          : kRemoteConfigMinimumFetchIntervalProduction,
    ),
  );
  await RemoteConfig.instance.initialize();
  try {
    await RemoteConfig.instance.fetchAndActivate();
  } on Object {
    // Mantém defaults (rede / RC).
  }
}
