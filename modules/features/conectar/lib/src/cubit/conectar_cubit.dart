import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:conectar_feature/src/data/connected_clinician.dart';
import 'package:conectar_feature/src/data/connection_repository.dart';
import 'package:sync_foundation/sync_foundation.dart';

class ConectarState {
  const ConectarState({
    this.connections = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ConnectedClinician> connections;
  final bool isLoading;
  final String? errorMessage;
}

class ConectarCubit extends Cubit<ConectarState> {
  ConectarCubit(
    this._repo,
    this._clinicianLink,
    this._auth,
  ) : super(const ConectarState()) {
    unawaited(_load());
  }

  final ConnectionRepository _repo;
  final ClinicianLinkService _clinicianLink;
  final AuthRepository _auth;

  Future<void> _load() async {
    try {
      final list = await _repo.getConnections();
      emit(ConectarState(connections: list));
    } on Object catch (_) {
      emit(const ConectarState());
    }
  }

  Future<void> linkWithCode(String code) async {
    if (code.trim().isEmpty) return;
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      emit(state.copyWith(errorMessage: 'Faça login para conectar.'));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final resolved = await _clinicianLink.resolveCode(code);
      if (resolved == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Código inválido. Verifique e tente novamente.',
        ));
        return;
      }
      await _clinicianLink.addPatientToClinician(userId, resolved.clinicianUid);
      await _repo.linkWithCode(
        code,
        resolved: ResolvedClinicianInfo(
          clinicianUid: resolved.clinicianUid,
          displayName: resolved.displayName,
        ),
      );
      final list = await _repo.getConnections();
      emit(ConectarState(connections: list));
    } on Object catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> removeConnection(String id) async {
    final userId = _auth.currentUser?.uid;
    ConnectedClinician? conn;
    for (final c in state.connections) {
      if (c.id == id) {
        conn = c;
        break;
      }
    }
    try {
      if (userId != null &&
          conn != null &&
          conn.clinicianUid != null &&
          conn.clinicianUid!.isNotEmpty) {
        await _clinicianLink.removePatientFromClinician(
          userId,
          conn.clinicianUid!,
        );
      }
      await _repo.removeConnection(id);
      final list = await _repo.getConnections();
      emit(ConectarState(connections: list));
    } on Object catch (_) {
      // mantém estado atual
    }
  }
}

extension on ConectarState {
  ConectarState copyWith({
    List<ConnectedClinician>? connections,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConectarState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
