import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:insights_feature/src/cubit/insights_cubit.dart';
import 'package:insights_feature/src/data/insights_repository.dart';
import 'package:insights_feature/src/pages/insights_page.dart';
import 'package:patients_feature/patients_feature.dart';

class InsightsFeature implements YummyLogFeature {
  @override
  String get name => 'insights';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerLazySingleton<InsightsRepository>(
        () => FirestoreInsightsRepository(
          patientsRepository: getIt<PatientsRepository>(),
          mealsRepository: getIt<PatientMealsRepository>(),
        ),
      )
      ..registerFactory<InsightsCubit>(
        () => InsightsCubit(
          repository: getIt<InsightsRepository>(),
          authRepository: getIt<AuthRepository>(),
        ),
      );
  }

  @override
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    return [
      GoRoute(
        path: '/insights',
        builder: (context, state) => RepositoryProvider<AuthRepository>.value(
          value: getIt<AuthRepository>(),
          child: BlocProvider(
            create: (_) => getIt<InsightsCubit>(),
            child: const InsightsPage(),
          ),
        ),
      ),
    ];
  }
}
