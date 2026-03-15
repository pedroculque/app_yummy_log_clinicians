import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/src/pages/insights_page.dart';

class InsightsFeature implements YummyLogFeature {
  @override
  String get name => 'insights';

  @override
  void registerDependencies(GetIt getIt) {
    // No dependencies for now
  }

  @override
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    return [
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsPage(),
      ),
    ];
  }
}
