import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:insights_feature/src/cubit/insights_state.dart';
import 'package:insights_feature/src/data/insights_repository.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required InsightsRepository repository,
    required AuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const InsightsState());

  final InsightsRepository _repository;
  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> load() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: InsightsStatus.loaded,
        ),
      );
      return;
    }

    emit(state.copyWith(status: InsightsStatus.loading));

    try {
      final summary = await _repository.getInsights(
        user.uid,
        periodDays: state.period.days,
      );
      emit(
        state.copyWith(
          status: InsightsStatus.loaded,
          summary: summary,
          lastUpdated: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: InsightsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changePeriod(InsightsPeriod period) async {
    if (period == state.period) return;
    emit(state.copyWith(period: period));
    await load();
  }

  Future<void> refresh() async {
    await load();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
