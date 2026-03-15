import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:patients_feature/src/cubit/patients_cubit.dart';
import 'package:patients_feature/src/data/patients_repository.dart';
import 'package:patients_feature/src/pages/patients_page.dart';

class PatientsFeature implements YummyLogFeature {
  @override
  String get name => 'patients';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerLazySingleton<PatientsRepository>(
        FirestorePatientsRepository.new,
      )
      ..registerFactory<PatientsCubit>(
        () => PatientsCubit(
          repository: getIt<PatientsRepository>(),
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
        path: '/patients',
        builder: (context, state) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(
              value: getIt<AuthRepository>(),
            ),
          ],
          child: BlocProvider(
            create: (_) => getIt<PatientsCubit>(),
            child: const PatientsPage(),
          ),
        ),
      ),
    ];
  }
}
