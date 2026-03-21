import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:diary_feature/src/cubit/diary_cubit.dart';
import 'package:diary_feature/src/cubit/entry_detail_cubit.dart';
import 'package:diary_feature/src/data/meal_entry_repository.dart';
import 'package:diary_feature/src/pages/add_meal_page.dart';
import 'package:diary_feature/src/pages/diary_page.dart';
import 'package:diary_feature/src/pages/entry_detail_page.dart';
import 'package:feature_contract/feature_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_domain/meal_domain.dart';
import 'package:persistence_foundation/persistence_foundation.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

/// Feature Diário: lista do diário, adicionar refeição (FAB).
/// Regras de negócio e acesso a dados ficam nos cubits; páginas são “dumb”.
class DiaryFeature implements YummyLogFeature {
  @override
  String get name => 'diary';

  @override
  void registerDependencies(GetIt getIt) {
    getIt
      ..registerSingleton<MealEntryRepository>(
        MealEntryRepository(getIt<MealEntryLocalDataSource>()),
      )
      ..registerSingleton<DiaryCubit>(
        DiaryCubit(
          getIt<MealEntryRepository>(),
          crashReporter: getIt.isRegistered<CrashReporter>()
              ? getIt<CrashReporter>()
              : null,
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
          path: '/diary',
          builder: (context, state) => BlocProvider.value(
            value: getIt<DiaryCubit>(),
            child: DiaryPage(
              authStateStream: getIt<AuthRepository>().authStateChanges,
            ),
          ),
          routes: [
            GoRoute(
              path: 'add',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                final forDate = state.extra as DateTime?;
                return BlocProvider.value(
                  value: getIt<DiaryCubit>(),
                  child: AddMealPage(
                    onSaved: () {},
                    forDate: forDate,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'entry/:id',
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final repo = getIt<MealEntryRepository>();
                return BlocProvider(
                  create: (_) {
                    final cubit = EntryDetailCubit(
                      repo,
                      id,
                      crashReporter: getIt.isRegistered<CrashReporter>()
                          ? getIt<CrashReporter>()
                          : null,
                    );
                    unawaited(cubit.load());
                    return cubit;
                  },
                  child: EntryDetailPage(
                    entryId: id,
                    onUpdated: () =>
                        unawaited(getIt<DiaryCubit>().load()),
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final entry = state.extra as MealEntry?;
                    if (entry == null) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(context.l10n.editMeal),
                        ),
                        body: Center(
                          child: Text(context.l10n.entryNotFound),
                        ),
                      );
                    }
                    return BlocProvider.value(
                      value: getIt<DiaryCubit>(),
                      child: AddMealPage(
                        initialEntry: entry,
                        onSaved: () {
                          if (context.mounted) context.pop();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ];
}
