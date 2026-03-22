import 'dart:async' show unawaited;
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

  if (kDebugMode && Platform.isIOS) {
    unawaited(_debugLogStoreKitProductResolution());
  }
}

/// Só em debug iOS: confirma se StoreKit/App Store devolve os IDs esperados
/// (o erro CONFIGURATION_ERROR no paywall costuma ser 0 produtos aqui).
Future<void> _debugLogStoreKitProductResolution() async {
  const ids = <String>['clinicians_monthly', 'clinicians_annual'];
  try {
    final products = await Purchases.getProducts(ids);
    if (products.length >= ids.length) {
      debugPrint(
        'RevenueCat [debug] StoreKit: ${products.length} produto(s) — '
        '${products.map((p) => p.identifier).join(', ')}',
      );
    } else if (products.isEmpty) {
      debugPrint(
        'RevenueCat [debug] StoreKit: 0 produtos para $ids → offerings/compras '
        'falham com CONFIGURATION_ERROR. Causas comuns: '
        '(A) `flutter run` / hot restart — o .storekit do scheme costuma só '
        'atuar ao dar Run pelo Xcode (abrir ios/Runner.xcworkspace, scheme '
        '`development`, Product → Run; Options → StoreKit = '
        'YummyLogClinicians.storekit). '
        '(B) RevenueCat: app iOS com bundle = '
        'com.yummylogdiaryforclinicians.app.dev e os mesmos product IDs. '
        '(C) App Store Connect + contrato Paid Apps (dispositivo + sandbox). '
        'Ver docs/MONETIZATION_REVENUECAT.md.',
      );
    } else {
      debugPrint(
        'RevenueCat [debug] StoreKit: parcial (${products.length}/${ids.length}) — '
        '${products.map((p) => p.identifier).join(', ')}',
      );
    }
  } on Object catch (e, st) {
    debugPrint('RevenueCat [debug] StoreKit getProducts: $e');
    debugPrint('$st');
  }
}
