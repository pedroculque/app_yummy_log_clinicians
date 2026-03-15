import 'dart:async';

import 'package:auth_foundation/src/auth_exceptions.dart';
import 'package:auth_foundation/src/auth_repository.dart';
import 'package:auth_foundation/src/presentation/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit para o fluxo de login (tela de login, guard).
/// Usa [AuthRepository]; escuta [AuthRepository.authStateChanges].
class AuthFlowCubit extends Cubit<AuthFlowState> {
  AuthFlowCubit(this._auth) : super(const AuthFlowInitial()) {
    _subscription = _auth.authStateChanges.listen(_onAuthChanged);
  }

  final AuthRepository _auth;
  StreamSubscription<AuthUser?>? _subscription;

  void _onAuthChanged(AuthUser? user) {
    if (user != null) {
      emit(AuthFlowAuthenticated(user));
    } else {
      emit(const AuthFlowUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthFlowLoading());
    try {
      await _auth.signInWithGoogle();
      // Estado atualizado por _onAuthChanged
    } on AuthCancelledException {
      final user = _auth.currentUser;
      if (user != null) {
        emit(AuthFlowAuthenticated(user));
      } else {
        emit(const AuthFlowUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthFlowError(e));
    }
  }

  Future<void> signInWithApple() async {
    emit(const AuthFlowLoading());
    try {
      await _auth.signInWithApple();
    } on AuthCancelledException {
      final user = _auth.currentUser;
      if (user != null) {
        emit(AuthFlowAuthenticated(user));
      } else {
        emit(const AuthFlowUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthFlowError(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void clearError() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthFlowAuthenticated(user));
    } else {
      emit(const AuthFlowUnauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
