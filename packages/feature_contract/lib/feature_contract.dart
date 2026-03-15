import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Contrato que cada feature package implementa para ser registrado no app.
abstract class YummyLogFeature {
  /// Nome da feature (para debug/log).
  String get name;

  /// Registra no [getIt] apenas as dependências desta feature.
  void registerDependencies(GetIt getIt);

  /// Retorna as rotas desta feature (para o branch do shell).
  /// [getIt] permite à feature injetar dependências nos builders (ex.: cubits).
  /// [rootNavigatorKey] quando fornecido, permite que rotas filhas usem
  /// `parentNavigatorKey` do GoRoute para tela cheia sobre a tab bar.
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  });
}
