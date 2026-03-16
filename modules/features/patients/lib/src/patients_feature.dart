import 'package:auth_foundation/auth_foundation.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:patients_feature/src/cubit/form_config_cubit.dart';
import 'package:patients_feature/src/cubit/patient_diary_cubit.dart';
import 'package:patients_feature/src/cubit/patients_cubit.dart';
import 'package:patients_feature/src/data/firestore_form_config_repository.dart';
import 'package:patients_feature/src/data/form_config_repository.dart';
import 'package:patients_feature/src/data/patient_meals_repository.dart';
import 'package:patients_feature/src/data/patients_repository.dart';
import 'package:patients_feature/src/pages/patient_diary_page.dart';
import 'package:patients_feature/src/pages/patient_form_config_page.dart';
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
      ..registerLazySingleton<PatientMealsRepository>(
        FirestorePatientMealsRepository.new,
      )
      ..registerLazySingleton<FormConfigRepository>(
        FirestoreFormConfigRepository.new,
      )
      ..registerFactory<PatientsCubit>(
        () => PatientsCubit(
          repository: getIt<PatientsRepository>(),
          authRepository: getIt<AuthRepository>(),
        ),
      )
      ..registerFactory<PatientDiaryCubit>(
        () => PatientDiaryCubit(
          repository: getIt<PatientMealsRepository>(),
        ),
      )
      ..registerFactory<FormConfigCubit>(
        () => FormConfigCubit(
          repository: getIt<FormConfigRepository>(),
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

  List<RouteBase> getFullScreenRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) {
    return [
      GoRoute(
        path: '/patients/:patientId/diary',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final patientId = state.pathParameters['patientId']!;
          final patientName = state.uri.queryParameters['name'];
          return BlocProvider(
            create: (_) => getIt<PatientDiaryCubit>(),
            child: PatientDiaryPage(
              patientId: patientId,
              patientName: patientName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/patients/:patientId/form-config',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final patientId = state.pathParameters['patientId']!;
          final patientName = state.uri.queryParameters['name'];
          return BlocProvider(
            create: (_) => getIt<FormConfigCubit>(),
            child: PatientFormConfigPage(
              patientId: patientId,
              patientName: patientName,
            ),
          );
        },
      ),
    ];
  }
}
