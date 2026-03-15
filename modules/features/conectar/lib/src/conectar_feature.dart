import 'package:auth_foundation/auth_foundation.dart';
import 'package:conectar_feature/src/cubit/conectar_cubit.dart';
import 'package:conectar_feature/src/data/connection_repository.dart';
import 'package:conectar_feature/src/pages/conectar_page.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:sync_foundation/sync_foundation.dart';

/// Feature Conectar: vincular-se a um nutricionista (ex.: por código).
class ConectarFeature implements YummyLogFeature {
  @override
  String get name => 'conectar';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerSingleton<ConnectionRepository>(
        LocalConnectionRepository(getIt<ConnectionLocalDataSource>()),
      )
      ..registerFactory<ConectarCubit>(
        () => ConectarCubit(
          getIt<ConnectionRepository>(),
          getIt<ClinicianLinkService>(),
          getIt<AuthRepository>(),
        ),
      );
  }

  @override
  List<RouteBase> getRoutes(
    GetIt getIt, {
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) =>
      [
        GoRoute(
          path: '/conectar',
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ConectarCubit>(),
            child: ConectarPage(
              authRepository: getIt<AuthRepository>(),
            ),
          ),
        ),
      ];
}
