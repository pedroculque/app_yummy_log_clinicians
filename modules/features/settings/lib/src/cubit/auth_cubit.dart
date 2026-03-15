import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Estado do auth na tela de configurações.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isLoggedIn => user != null;
}

/// Cubit de auth para Configurações: login, logout.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
  })  : _auth = authRepository,
        super(const AuthState()) {
    _subscription = _auth.authStateChanges.listen(_onAuthChanged);
    _emitCurrent();
  }

  final AuthRepository _auth;
  late final StreamSubscription<AuthUser?> _subscription;

  void _onAuthChanged(AuthUser? user) {
    _emitCurrent();
  }

  void _emitCurrent() {
    final user = _auth.currentUser;
    emit(user == null ? const AuthState() : AuthState(user: user));
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _auth.signInWithGoogle();
      final current = _auth.currentUser;
      emit(current == null ? const AuthState() : AuthState(user: current));
    } on AuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } on Object catch (e, st) {
      debugPrint('signInWithGoogle: $e $st');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signInWithApple() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _auth.signInWithApple();
      final current = _auth.currentUser;
      emit(current == null ? const AuthState() : AuthState(user: current));
    } on AuthException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } on Object catch (e, st) {
      debugPrint('signInWithApple: $e $st');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _auth.signOut();
      final current = _auth.currentUser;
      emit(current == null ? const AuthState() : AuthState(user: current));
    } on Object catch (e, st) {
      debugPrint('signOut: $e $st');
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateDisplayName(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await _auth.updateDisplayName(name);
      _emitCurrent();
    } on Object catch (e, st) {
      debugPrint('updateDisplayName: $e $st');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

extension on AuthState {
  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
