import 'package:auth_foundation/src/auth_exceptions.dart';
import 'package:auth_foundation/src/auth_repository.dart';

/// Implementação stub do [AuthRepository] quando Firebase não está configurado.
/// Sempre retorna "não logado"; métodos de login lançam.
class StubAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthUser> signInWithGoogle() async {
    throw const AuthUnknownException(
      'Configure Firebase (flutterfire configure) to use sign in.',
    );
  }

  @override
  Future<AuthUser> signInWithApple() async {
    throw const AuthUnknownException(
      'Configure Firebase (flutterfire configure) to use sign in.',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String name) async {}
}
