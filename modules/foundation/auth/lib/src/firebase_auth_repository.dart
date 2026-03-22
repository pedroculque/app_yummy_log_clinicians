import 'dart:io';

import 'package:auth_foundation/src/auth_exceptions.dart';
import 'package:auth_foundation/src/auth_repository.dart';
import 'package:feature_contract/crash_reporter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Implementação do [AuthRepository] usando Firebase Auth.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    GetIt? getIt,
  })  : _auth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            ),
        _getIt = getIt;

  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final GetIt? _getIt;

  void _report(Object e, StackTrace? st, {required String hint}) {
    final g = _getIt;
    if (g == null) return;
    reportCaughtError(g, e, st, feature: 'auth', hint: hint);
  }

  /// Usa o stream `userChanges` do Firebase Auth (inclui authState, token e
  /// perfil). Assim `updatePhotoURL` / nome atualizado disparam nova emissão.
  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.userChanges().map(_userFromFirebase);

  @override
  AuthUser? get currentUser => _userFromFirebase(_auth.currentUser);

  static AuthUser? _userFromFirebase(firebase_auth.User? u) {
    if (u == null) return null;
    return AuthUser(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      photoUrl: u.photoURL,
    );
  }

  /// Igual a _userFromFirebase, mas usa [photoUrlFallback] se [u?.photoURL]
  /// for null.
  AuthUser? _userFromFirebaseWithPhotoFallback(
    firebase_auth.User? u, {
    String? photoUrlFallback,
  }) {
    if (u == null) return null;
    final photoUrl = u.photoURL ?? photoUrlFallback;
    return AuthUser(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      photoUrl: photoUrl,
    );
  }

  AuthException _mapFirebaseException(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthUserNotFoundException(),
      'wrong-password' => const AuthWrongPasswordException(),
      'invalid-credential' => const AuthInvalidCredentialException(),
      'email-already-in-use' => const AuthEmailAlreadyInUseException(),
      'weak-password' => const AuthWeakPasswordException(),
      'network-request-failed' => const AuthNetworkException(),
      'account-exists-with-different-credential' =>
        AuthAccountExistsException(_getExistingProvider(e)),
      _ => AuthUnknownException(e.message ?? ''),
    };
  }

  String _getExistingProvider(firebase_auth.FirebaseAuthException e) {
    final message = e.message ?? '';
    if (message.contains('google')) return 'Google';
    if (message.contains('apple')) return 'Apple';
    if (message.contains('password')) return 'Email';
    return 'outro método';
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }
      // Debug: o que o Google retorna
      debugPrint(
        '[Auth] Google account: email=${googleUser.email}, '
        'displayName=${googleUser.displayName}, '
        'photoUrl=${googleUser.photoUrl}',
      );
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null || idToken == null) {
        throw const AuthUnknownException(
          'Google Sign-In não retornou token (accessToken ou idToken nulo)',
        );
      }
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      // Debug: o que o Firebase Auth retorna após credential
      debugPrint(
        '[Auth] Firebase user: uid=${firebaseUser?.uid}, '
        'email=${firebaseUser?.email}, '
        'displayName=${firebaseUser?.displayName}, '
        'photoURL=${firebaseUser?.photoURL}',
      );
      // Se o Google tem foto mas o Firebase não, persiste no perfil do Auth
      final googlePhotoUrl = googleUser.photoUrl;
      if (firebaseUser != null &&
          googlePhotoUrl != null &&
          googlePhotoUrl.isNotEmpty &&
          (firebaseUser.photoURL == null || firebaseUser.photoURL!.isEmpty)) {
        debugPrint(
          '[Auth] Firebase sem photoURL; atualizando com Google: '
          '$googlePhotoUrl',
        );
        try {
          await firebaseUser.updatePhotoURL(googlePhotoUrl);
        } on Object catch (e, st) {
          debugPrint(
            '[Auth] updatePhotoURL falhou: $e $st',
          );
          _report(e, st, hint: 'update_photo_url');
        }
      }
      // Retornar com foto do Google se o Firebase ainda não tiver
      // no objeto local
      final user = _userFromFirebaseWithPhotoFallback(
        firebaseUser,
        photoUrlFallback: googleUser.photoUrl,
      );
      if (user == null) {
        throw const AuthUnknownException('No user after sign in');
      }
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (e, st) {
      _report(e, st, hint: 'sign_in_google_unexpected');
      throw AuthUnknownException(e.toString());
    }
  }

  @override
  Future<AuthUser> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple só retorna o nome na primeira vez; atualiza no Firebase se veio.
      if (Platform.isIOS &&
          appleCredential.givenName != null &&
          userCredential.user != null) {
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      final user = _userFromFirebase(userCredential.user);
      if (user == null) {
        throw const AuthUnknownException('No user after sign in');
      }
      return user;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledException();
      }
      throw AuthUnknownException(e.message);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (e, st) {
      _report(e, st, hint: 'sign_in_apple_unexpected');
      throw AuthUnknownException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  @override
  Future<void> deleteAccount() async {
    final u = _auth.currentUser;
    if (u == null) {
      throw const AuthUnknownException('No user signed in');
    }
    try {
      await u.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthRequiresRecentLoginException();
      }
      throw _mapFirebaseException(e);
    }
    await _googleSignIn.signOut();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final u = _auth.currentUser;
    if (u == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await u.updateDisplayName(trimmed);
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    final u = _auth.currentUser;
    if (u == null) return;
    if (photoUrl.trim().isEmpty) return;
    await u.updatePhotoURL(photoUrl);
  }
}
