import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:sync_foundation/sync_foundation.dart';

/// Chaves para mapear erros de upload nas strings localizadas.
const String kProfilePhotoUploadFailed = 'PROFILE_PHOTO_UPLOAD_FAILED';
const String kProfilePhotoNeedSignIn = 'PROFILE_PHOTO_NEED_SIGN_IN';
const String kProfilePhotoWrongAccount = 'PROFILE_PHOTO_WRONG_ACCOUNT';
const String kProfilePhotoTokenFailed = 'PROFILE_PHOTO_TOKEN_FAILED';

/// Exclusão de conta (mensagens localizadas na tela de configurações).
const String kDeleteAccountRequiresRecentLogin =
    'DELETE_ACCOUNT_REQUIRES_RECENT_LOGIN';
const String kDeleteAccountFailed = 'DELETE_ACCOUNT_FAILED';

/// Estado do auth na tela de configurações.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.profilePhotoUploading = false,
    this.profilePhotoCacheBuster,
  });

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
  final bool profilePhotoUploading;
  /// Timestamp para forçar reload da foto após upload (evita cache).
  final int? profilePhotoCacheBuster;

  bool get isLoggedIn => user != null;
}

/// Cubit de auth para Configurações: login, logout, foto de perfil.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required PhotoUploadService photoUploadService,
    required UserDocumentWriter userDocumentWriter,
    required UserProfileReader userProfileReader,
    required PatientsRepository patientsRepository,
    Future<void> Function()? clearPushRegistration,
    CliniciansAnalytics? analytics,
    this.onProfilePhotoUpdated,
  })  : _auth = authRepository,
        _photoUpload = photoUploadService,
        _userDoc = userDocumentWriter,
        _profileReader = userProfileReader,
        _patients = patientsRepository,
        _clearPushRegistration = clearPushRegistration,
        _analytics = analytics,
        super(const AuthState()) {
    _subscription = _auth.authStateChanges.listen(_onAuthChanged);
    unawaited(_emitMergedFromAuth());
  }

  final AuthRepository _auth;
  final PhotoUploadService _photoUpload;
  final UserDocumentWriter _userDoc;
  final UserProfileReader _profileReader;
  final PatientsRepository _patients;
  final Future<void> Function()? _clearPushRegistration;
  final CliniciansAnalytics? _analytics;
  late final StreamSubscription<AuthUser?> _subscription;

  /// Chamado após upload bem-sucedido da foto de perfil.
  void Function(AuthUser)? onProfilePhotoUpdated;

  bool _profilePhotoUploadInProgress = false;
  Timer? _profilePhotoUploadGuardTimer;

  void _onAuthChanged(AuthUser? user) {
    if (user == null) {
      _profilePhotoUploadInProgress = false;
      _profilePhotoUploadGuardTimer?.cancel();
      emit(const AuthState());
      return;
    }
    if (_profilePhotoUploadInProgress) return;
    final preserved = state.user?.photoUrl;
    final merged = preserved != null &&
            preserved.isNotEmpty &&
            (user.photoUrl == null || user.photoUrl!.isEmpty)
        ? user.copyWith(photoUrl: preserved)
        : user;
    emit(AuthState(user: merged));
  }

  Future<AuthUser> _withFirestorePhoto(AuthUser user) async {
    try {
      final url = await _profileReader.getPhotoUrl(user.uid);
      if (url != null && url.isNotEmpty) {
        return user.copyWith(photoUrl: url);
      }
    } on Object catch (e, st) {
      debugPrint('AuthCubit _withFirestorePhoto: $e $st');
    }
    return user;
  }

  Future<void> _emitMergedFromAuth() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (!isClosed) emit(const AuthState());
      return;
    }
    final merged = await _withFirestorePhoto(user);
    if (!isClosed) emit(AuthState(user: merged));
  }

  Future<void> signInWithGoogle() async {
    _analytics?.logAuthStart(method: 'google');
    emit(state.copyWith(isLoading: true));
    try {
      await _auth.signInWithGoogle();
      final current = _auth.currentUser;
      if (current == null) {
        _analytics?.logAuthResult(
          method: 'google',
          success: false,
        );
        emit(const AuthState());
      } else {
        _analytics?.logAuthResult(
          method: 'google',
          success: true,
        );
        final merged = await _withFirestorePhoto(current);
        emit(AuthState(user: merged));
      }
    } on AuthException catch (e) {
      _analytics?.logAuthResult(
        method: 'google',
        success: false,
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } on Object catch (e, st) {
      debugPrint('signInWithGoogle: $e $st');
      _analytics?.logAuthResult(
        method: 'google',
        success: false,
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signInWithApple() async {
    _analytics?.logAuthStart(method: 'apple');
    emit(state.copyWith(isLoading: true));
    try {
      await _auth.signInWithApple();
      final current = _auth.currentUser;
      if (current == null) {
        _analytics?.logAuthResult(
          method: 'apple',
          success: false,
        );
        emit(const AuthState());
      } else {
        _analytics?.logAuthResult(
          method: 'apple',
          success: true,
        );
        final merged = await _withFirestorePhoto(current);
        emit(AuthState(user: merged));
      }
    } on AuthException catch (e) {
      _analytics?.logAuthResult(
        method: 'apple',
        success: false,
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } on Object catch (e, st) {
      debugPrint('signInWithApple: $e $st');
      _analytics?.logAuthResult(
        method: 'apple',
        success: false,
      );
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
      if (current == null) {
        _analytics?.logLogout();
      }
      emit(current == null ? const AuthState() : AuthState(user: current));
    } on Object catch (e, st) {
      debugPrint('signOut: $e $st');
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Remove dados no Firestore/Storage e apaga o usuário no Firebase Auth.
  ///
  /// Pacientes podem manter entradas antigas em `connections` no app deles;
  /// indique suporte se precisarem limpar vínculo manualmente.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _clearPushRegistration?.call();
      await _patients.deleteClinicianAccountData(user.uid);
      await _photoUpload.deleteProfilePhotos(userId: user.uid);
      await _auth.deleteAccount();
      _analytics?.logAccountDeleteComplete();
      emit(const AuthState());
    } on AuthRequiresRecentLoginException {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: kDeleteAccountRequiresRecentLogin,
        ),
      );
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
    } on Object catch (e, st) {
      debugPrint('deleteAccount: $e $st');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: kDeleteAccountFailed,
        ),
      );
    }
  }

  Future<void> updateDisplayName(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await _auth.updateDisplayName(name);
      unawaited(_emitMergedFromAuth());
    } on Object catch (e, st) {
      debugPrint('updateDisplayName: $e $st');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Upload da foto de perfil (Storage + Auth + Firestore).
  /// Retorna `true` se concluiu com sucesso.
  Future<bool> uploadProfilePhoto(String localPath) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    _profilePhotoUploadInProgress = true;
    emit(AuthState(
      user: state.user ?? user,
      profilePhotoUploading: true,
    ));
    try {
      final uploadResult = await _photoUpload.uploadProfilePhoto(
        userId: user.uid,
        localPath: localPath,
      );
      if (!uploadResult.isSuccess) {
        _profilePhotoUploadInProgress = false;
        final err = switch (uploadResult.failureCode) {
          'unauthenticated' => kProfilePhotoNeedSignIn,
          'user_mismatch' => kProfilePhotoWrongAccount,
          'token' => kProfilePhotoTokenFailed,
          _ => kProfilePhotoUploadFailed,
        };
        emit(AuthState(
          user: _auth.currentUser ?? user,
          errorMessage: err,
        ));
        return false;
      }
      final url = uploadResult.url!;
      try {
        await _auth.updatePhotoUrl(url);
      } on Object catch (e, st) {
        debugPrint('updatePhotoUrl (Auth) failed, using Firestore: $e $st');
      }
      await _userDoc.ensureExists(
        user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: url,
      );
      final updatedUser = (state.user ?? _auth.currentUser ?? user).copyWith(
        photoUrl: url,
      );
      _profilePhotoUploadGuardTimer?.cancel();
      _profilePhotoUploadGuardTimer = Timer(const Duration(seconds: 3), () {
        _profilePhotoUploadInProgress = false;
      });
      emit(AuthState(
        user: updatedUser,
        profilePhotoCacheBuster: DateTime.now().millisecondsSinceEpoch,
      ));
      onProfilePhotoUpdated?.call(updatedUser);
      return true;
    } on Object catch (e, st) {
      debugPrint('uploadProfilePhoto: $e $st');
      _profilePhotoUploadInProgress = false;
      emit(AuthState(
        user: _auth.currentUser ?? user,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  @override
  Future<void> close() async {
    _profilePhotoUploadGuardTimer?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}

extension on AuthState {
  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    bool? profilePhotoUploading,
    int? profilePhotoCacheBuster,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profilePhotoUploading:
          profilePhotoUploading ?? this.profilePhotoUploading,
      profilePhotoCacheBuster:
          profilePhotoCacheBuster ?? this.profilePhotoCacheBuster,
    );
  }
}
