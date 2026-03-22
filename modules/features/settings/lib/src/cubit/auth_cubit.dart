import 'dart:async';

import 'package:auth_foundation/auth_foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:feature_contract/clinicians_analytics.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:patients_feature/patients_feature.dart';
import 'package:persistence_foundation/persistence_foundation.dart'
    show ClinicianProfilePhotoLocalStore, clinicianProfilePhotoUrlHint,
        logClinicianProfilePhoto;
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
    this.profileFirestoreCacheToken,
  });

  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
  final bool profilePhotoUploading;
  /// Timestamp para forçar reload da foto após upload (evita cache).
  final int? profilePhotoCacheBuster;
  /// Derivado de `users/{uid}.updatedAt` — invalida cache quando a URL se repete.
  final String? profileFirestoreCacheToken;

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
    required ClinicianProfilePhotoLocalStore clinicianProfilePhotoLocalStore,
    Future<void> Function()? clearPushRegistration,
    CliniciansAnalytics? analytics,
    CrashReporter? crashReporter,
    this.onProfilePhotoUpdated,
  })  : _auth = authRepository,
        _photoUpload = photoUploadService,
        _userDoc = userDocumentWriter,
        _profileReader = userProfileReader,
        _patients = patientsRepository,
        _clinicianProfilePhotoLocalStore = clinicianProfilePhotoLocalStore,
        _clearPushRegistration = clearPushRegistration,
        _analytics = analytics,
        _crashReporter = crashReporter,
        super(const AuthState()) {
    _seedClinicianAvatarFromDisk();
    _subscription = _auth.authStateChanges.listen(_onAuthChanged);
    unawaited(_emitMergedFromAuth());
  }

  final AuthRepository _auth;
  final PhotoUploadService _photoUpload;
  final UserDocumentWriter _userDoc;
  final UserProfileReader _profileReader;
  final PatientsRepository _patients;
  final ClinicianProfilePhotoLocalStore _clinicianProfilePhotoLocalStore;
  final Future<void> Function()? _clearPushRegistration;
  final CliniciansAnalytics? _analytics;
  final CrashReporter? _crashReporter;
  late final StreamSubscription<AuthUser?> _subscription;
  // Atribuído em [_startProfileWatch].
  // Cancelado em [_stopProfileWatch] e [close].
  // ignore: cancel_subscriptions
  StreamSubscription<UserProfileSnapshot>? _profileSnapSub;
  String? _watchedProfileUid;

  /// Chamado após upload bem-sucedido da foto de perfil.
  void Function(AuthUser)? onProfilePhotoUpdated;

  bool _profilePhotoUploadInProgress = false;
  Timer? _profilePhotoUploadGuardTimer;

  /// Antes do primeiro evento do Auth, repõe URL guardada em disco (rebuild).
  void _seedClinicianAvatarFromDisk() {
    final cur = _auth.currentUser;
    if (cur == null) return;
    final disk = _clinicianProfilePhotoLocalStore.readForUid(cur.uid);
    if (disk == null) {
      logClinicianProfilePhoto('auth.seed skip disk miss uid=${cur.uid}');
      return;
    }
    final authHasPhoto = cur.photoUrl != null && cur.photoUrl!.isNotEmpty;
    if (authHasPhoto) {
      logClinicianProfilePhoto(
        'auth.seed skip auth already has photo uid=${cur.uid} '
        'url=${clinicianProfilePhotoUrlHint(cur.photoUrl)}',
      );
      return;
    }
    logClinicianProfilePhoto(
      'auth.seed apply disk uid=${cur.uid} '
      'url=${clinicianProfilePhotoUrlHint(disk.url)} '
      'token=${disk.cacheToken ?? '(null)'}',
    );
    emit(
      AuthState(
        user: cur.copyWith(photoUrl: disk.url),
        profileFirestoreCacheToken: disk.cacheToken,
      ),
    );
  }

  void _persistClinicianAvatarToDisk() {
    final u = state.user;
    if (u == null) {
      logClinicianProfilePhoto('auth.persist skip no state.user');
      return;
    }
    final url = u.photoUrl;
    if (url == null || url.isEmpty) {
      logClinicianProfilePhoto('auth.persist skip empty photoUrl uid=${u.uid}');
      return;
    }
    final bust = state.profilePhotoCacheBuster;
    final token = bust != null
        ? 'u$bust'
        : (state.profileFirestoreCacheToken != null &&
                state.profileFirestoreCacheToken!.isNotEmpty
            ? state.profileFirestoreCacheToken
            : null);
    unawaited(
      _clinicianProfilePhotoLocalStore.write(
        uid: u.uid,
        url: url,
        cacheToken: token,
      ),
    );
  }

  AuthUser _withPreservedPhoto(AuthUser fromAuth) {
    final preserved = state.user?.photoUrl;
    if (preserved != null &&
        preserved.isNotEmpty &&
        (fromAuth.photoUrl == null || fromAuth.photoUrl!.isEmpty)) {
      return fromAuth.copyWith(photoUrl: preserved);
    }
    return fromAuth;
  }

  AuthUser _applySnapshotToAuth(AuthUser base, UserProfileSnapshot snap) {
    if (snap.photoUrl != null && snap.photoUrl!.isNotEmpty) {
      return base.copyWith(photoUrl: snap.photoUrl);
    }
    return base;
  }

  void _stopProfileWatch() {
    final prev = _watchedProfileUid;
    _watchedProfileUid = null;
    final sub = _profileSnapSub;
    _profileSnapSub = null;
    if (sub != null) {
      logClinicianProfilePhoto(
        'auth.profileWatch stop uid=${prev ?? '(null)'}',
      );
      unawaited(sub.cancel());
    }
  }

  void _startProfileWatch(String userId) {
    if (_watchedProfileUid == userId && _profileSnapSub != null) {
      logClinicianProfilePhoto(
        'auth.profileWatch already uid=$userId (no-op)',
      );
      return;
    }
    _stopProfileWatch();
    _watchedProfileUid = userId;
    logClinicianProfilePhoto('auth.profileWatch start uid=$userId');
    _profileSnapSub = _profileReader.watchSnapshot(userId).listen(
      _onProfileSnapshot,
      onError: (Object e, StackTrace st) {
        _crashReporter?.call(
          e,
          st,
          feature: 'settings_auth',
          hint: 'profile_watch',
        );
      },
    );
  }

  void _onProfileSnapshot(UserProfileSnapshot snap) {
    if (isClosed) return;
    if (_profilePhotoUploadInProgress) {
      logClinicianProfilePhoto(
        'auth.onProfileSnapshot skip upload in progress '
        'url=${clinicianProfilePhotoUrlHint(snap.photoUrl)}',
      );
      return;
    }
    final authUser = _auth.currentUser;
    if (authUser == null) {
      logClinicianProfilePhoto('auth.onProfileSnapshot skip no currentUser');
      return;
    }
    final user = _applySnapshotToAuth(_withPreservedPhoto(authUser), snap);
    logClinicianProfilePhoto(
      'auth.onProfileSnapshot uid=${authUser.uid} '
      'mergedUrl=${clinicianProfilePhotoUrlHint(user.photoUrl)} '
      'snapUrl=${clinicianProfilePhotoUrlHint(snap.photoUrl)} '
      'token=${snap.cacheToken ?? '(null)'}',
    );
    if (!isClosed) {
      emit(
        AuthState(
          user: user,
          profileFirestoreCacheToken: snap.cacheToken,
          profilePhotoCacheBuster: state.profilePhotoCacheBuster,
          profilePhotoUploading: state.profilePhotoUploading,
          isLoading: state.isLoading,
        ),
      );
      _persistClinicianAvatarToDisk();
    }
  }

  Future<void> _emitFullyMerged(AuthUser fromAuth) async {
    if (isClosed) return;
    if (_profilePhotoUploadInProgress) {
      logClinicianProfilePhoto(
        'auth.emitFullyMerged skip upload in progress uid=${fromAuth.uid}',
      );
      return;
    }
    logClinicianProfilePhoto(
      'auth.emitFullyMerged readSnapshot uid=${fromAuth.uid}',
    );
    final snap = await _profileReader.readSnapshot(fromAuth.uid);
    final user = _applySnapshotToAuth(_withPreservedPhoto(fromAuth), snap);
    logClinicianProfilePhoto(
      'auth.emitFullyMerged done uid=${fromAuth.uid} '
      'mergedUrl=${clinicianProfilePhotoUrlHint(user.photoUrl)} '
      'token=${snap.cacheToken ?? '(null)'}',
    );
    if (!isClosed) {
      emit(
        AuthState(
          user: user,
          profileFirestoreCacheToken: snap.cacheToken,
          profilePhotoCacheBuster: state.profilePhotoCacheBuster,
          profilePhotoUploading: state.profilePhotoUploading,
          isLoading: state.isLoading,
        ),
      );
      _persistClinicianAvatarToDisk();
    }
  }

  void _onAuthChanged(AuthUser? user) {
    if (user == null) {
      logClinicianProfilePhoto(
        'auth.onAuthChanged signed out: clear watch + disk',
      );
      _stopProfileWatch();
      _profilePhotoUploadInProgress = false;
      _profilePhotoUploadGuardTimer?.cancel();
      unawaited(_clinicianProfilePhotoLocalStore.clear());
      if (!isClosed) emit(const AuthState());
      return;
    }
    if (_profilePhotoUploadInProgress) {
      logClinicianProfilePhoto(
        'auth.onAuthChanged skip merge (upload) uid=${user.uid}',
      );
      return;
    }
    logClinicianProfilePhoto(
      'auth.onAuthChanged uid=${user.uid} '
      'photoUrl=${clinicianProfilePhotoUrlHint(user.photoUrl)}',
    );
    _startProfileWatch(user.uid);
    unawaited(_emitFullyMerged(user));
  }

  Future<void> _emitMergedFromAuth() async {
    final user = _auth.currentUser;
    if (user == null) {
      _stopProfileWatch();
      if (!isClosed) emit(const AuthState());
      return;
    }
    _startProfileWatch(user.uid);
    await _emitFullyMerged(user);
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
        _startProfileWatch(current.uid);
        logClinicianProfilePhoto(
          'auth.signInGoogle readSnapshot uid=${current.uid}',
        );
        final snap = await _profileReader.readSnapshot(current.uid);
        final merged = _applySnapshotToAuth(_withPreservedPhoto(current), snap);
        logClinicianProfilePhoto(
          'auth.signInGoogle merged '
          'url=${clinicianProfilePhotoUrlHint(merged.photoUrl)} '
          'token=${snap.cacheToken ?? '(null)'}',
        );
        emit(
          AuthState(
            user: merged,
            profileFirestoreCacheToken: snap.cacheToken,
          ),
        );
        _persistClinicianAvatarToDisk();
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
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'sign_in_google',
      );
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
        _startProfileWatch(current.uid);
        logClinicianProfilePhoto(
          'auth.signInApple readSnapshot uid=${current.uid}',
        );
        final snap = await _profileReader.readSnapshot(current.uid);
        final merged = _applySnapshotToAuth(_withPreservedPhoto(current), snap);
        logClinicianProfilePhoto(
          'auth.signInApple merged '
          'url=${clinicianProfilePhotoUrlHint(merged.photoUrl)} '
          'token=${snap.cacheToken ?? '(null)'}',
        );
        emit(
          AuthState(
            user: merged,
            profileFirestoreCacheToken: snap.cacheToken,
          ),
        );
        _persistClinicianAvatarToDisk();
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
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'sign_in_apple',
      );
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
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'sign_out',
      );
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
      logClinicianProfilePhoto('auth.deleteAccount clear local avatar cache');
      unawaited(_clinicianProfilePhotoLocalStore.clear());
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
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'delete_account',
      );
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
      final u = _auth.currentUser;
      if (u != null) {
        unawaited(_emitFullyMerged(u));
      }
    } on Object catch (e, st) {
      debugPrint('updateDisplayName: $e $st');
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'display_name',
      );
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Upload da foto de perfil (Storage + Auth + Firestore).
  /// Retorna `true` se concluiu com sucesso.
  Future<bool> uploadProfilePhoto(String localPath) async {
    final user = _auth.currentUser;
    if (user == null) {
      logClinicianProfilePhoto('auth.upload skip not signed in');
      return false;
    }
    logClinicianProfilePhoto(
      'auth.upload start uid=${user.uid} pathLen=${localPath.length}',
    );
    _profilePhotoUploadInProgress = true;
    emit(
      AuthState(
        user: state.user ?? user,
        profilePhotoUploading: true,
        profileFirestoreCacheToken: state.profileFirestoreCacheToken,
        profilePhotoCacheBuster: state.profilePhotoCacheBuster,
      ),
    );
    try {
      final uploadResult = await _photoUpload.uploadProfilePhoto(
        userId: user.uid,
        localPath: localPath,
      );
      if (!uploadResult.isSuccess) {
        logClinicianProfilePhoto(
          'auth.upload fail code=${uploadResult.failureCode}',
        );
        _profilePhotoUploadInProgress = false;
        final err = switch (uploadResult.failureCode) {
          'unauthenticated' => kProfilePhotoNeedSignIn,
          'user_mismatch' => kProfilePhotoWrongAccount,
          'token' => kProfilePhotoTokenFailed,
          _ => kProfilePhotoUploadFailed,
        };
        emit(
          AuthState(
            user: _auth.currentUser ?? user,
            errorMessage: err,
            profileFirestoreCacheToken: state.profileFirestoreCacheToken,
            profilePhotoCacheBuster: state.profilePhotoCacheBuster,
          ),
        );
        return false;
      }
      final url = uploadResult.url!;
      logClinicianProfilePhoto(
        'auth.upload storage ok url=${clinicianProfilePhotoUrlHint(url)}',
      );
      try {
        await _auth.updatePhotoUrl(url);
      } on Object catch (e, st) {
        logClinicianProfilePhoto(
          'auth.upload updatePhotoUrl (Auth) failed, '
          'continuing with Firestore: $e',
        );
        debugPrint('updatePhotoUrl (Auth) failed, using Firestore: $e $st');
        _crashReporter?.call(
          e,
          st,
          feature: 'settings_auth',
          hint: 'update_photo_url',
        );
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
      logClinicianProfilePhoto(
        'auth.upload readSnapshot after write uid=${user.uid}',
      );
      final postSnap = await _profileReader.readSnapshot(user.uid);
      final bust = DateTime.now().millisecondsSinceEpoch;
      logClinicianProfilePhoto(
        'auth.upload success bust=$bust '
        'firestoreToken=${postSnap.cacheToken ?? '(null)'} '
        'url=${clinicianProfilePhotoUrlHint(url)}',
      );
      _profilePhotoUploadGuardTimer?.cancel();
      _profilePhotoUploadGuardTimer = Timer(const Duration(seconds: 3), () {
        _profilePhotoUploadInProgress = false;
        final u = _auth.currentUser;
        if (u != null && !isClosed) {
          unawaited(_emitFullyMerged(u));
        }
      });
      emit(
        AuthState(
          user: updatedUser,
          profilePhotoCacheBuster: bust,
          profileFirestoreCacheToken: postSnap.cacheToken,
        ),
      );
      _persistClinicianAvatarToDisk();
      onProfilePhotoUpdated?.call(updatedUser);
      return true;
    } on Object catch (e, st) {
      logClinicianProfilePhoto('auth.upload exception $e');
      debugPrint('uploadProfilePhoto: $e $st');
      _crashReporter?.call(
        e,
        st,
        feature: 'settings_auth',
        hint: 'upload_profile_photo',
      );
      _profilePhotoUploadInProgress = false;
      emit(
        AuthState(
          user: _auth.currentUser ?? user,
          errorMessage: e.toString(),
          profileFirestoreCacheToken: state.profileFirestoreCacheToken,
          profilePhotoCacheBuster: state.profilePhotoCacheBuster,
        ),
      );
      return false;
    }
  }

  @override
  Future<void> close() async {
    _profilePhotoUploadGuardTimer?.cancel();
    _stopProfileWatch();
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
    String? profileFirestoreCacheToken,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profilePhotoUploading:
          profilePhotoUploading ?? this.profilePhotoUploading,
      profilePhotoCacheBuster:
          profilePhotoCacheBuster ?? this.profilePhotoCacheBuster,
      profileFirestoreCacheToken:
          profileFirestoreCacheToken ?? this.profileFirestoreCacheToken,
    );
  }
}
