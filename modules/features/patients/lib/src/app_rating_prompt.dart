import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_app_rating/package_app_rating.dart';

/// Regista uma ação “feliz” e, se o utilizador for elegível, pede avaliação.
///
/// Usar após momentos de valor (ex.: primeiro paciente, insights carregados).
/// Requer `AppRating` registado no service locator (app principal).
Future<void> trackActionAndRequestAppRatingIfEligible(
  BuildContext context, {
  required String origin,
}) async {
  if (!GetIt.I.isRegistered<AppRating>()) return;
  final appRating = GetIt.I<AppRating>();
  await appRating.trackAction();
  if (!context.mounted) return;
  await appRating.requestIfEligible(
    context: context,
    origin: origin,
  );
}
