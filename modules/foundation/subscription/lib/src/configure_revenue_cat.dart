import 'dart:io' show Platform;

import 'package:feature_contract/app_build_flavor.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Configura o SDK RevenueCat com a chave pública da loja corrente.
///
/// Resolução (Fastlane injeta `REVENUECAT_API_KEY` do `.env`):
/// - iOS: override `REVENUECAT_APPLE_API_KEY`, senão chave unificada (appl_).
/// - Android: override `REVENUECAT_GOOGLE_API_KEY`, senão chave unificada.
Future<void> configureRevenueCat(AppBuildFlavor flavor) async {
  if (kDebugMode && flavor != AppBuildFlavor.production) {
    await Purchases.setLogLevel(LogLevel.debug);
  }

  const unified = String.fromEnvironment('REVENUECAT_API_KEY');
  const appleOverride = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
  const googleOverride = String.fromEnvironment('REVENUECAT_GOOGLE_API_KEY');

  final apiKey = Platform.isIOS
      ? (appleOverride.isNotEmpty ? appleOverride : unified)
      : (googleOverride.isNotEmpty ? googleOverride : unified);

  if (apiKey.isEmpty) {
    debugPrint(
      'RevenueCat: chave ausente. Defina REVENUECAT_API_KEY em .env.dev / '
      '.env.prod (launch.json usa --dart-define-from-file), ou via Fastlane / '
      'dart-define; opcional: REVENUECAT_APPLE_API_KEY / REVENUECAT_GOOGLE_API_KEY.',
    );
    return;
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));
}
