/// Dados do usuário autenticado (ex.: Firebase Auth).
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  /// Cópia com [photoUrl] sobrescrito (ex.: fallback do Firestore).
  AuthUser copyWith({String? photoUrl}) => AuthUser(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  /// Iniciais do nome para avatar (ex.: "João Silva" → "JS").
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email?.isNotEmpty == true
        ? email!.substring(0, 1).toUpperCase()
        : '?';
  }
}

/// Interface do repositório de autenticação (Firebase Auth, etc.).
abstract class AuthRepository {
  /// Stream do usuário atual (null = deslogado).
  Stream<AuthUser?> get authStateChanges;

  /// Usuário atual de forma síncrona (pode ser null).
  AuthUser? get currentUser;

  /// Entrada com Google (Android e iOS).
  Future<AuthUser> signInWithGoogle();

  /// Entrada com Apple (principalmente iOS).
  Future<AuthUser> signInWithApple();

  /// Encerra a sessão.
  Future<void> signOut();

  /// Atualiza o nome de exibição do usuário atual.
  /// Ex.: para saudação no diário.
  /// Só tem efeito se o usuário estiver logado.
  Future<void> updateDisplayName(String name);

  /// Atualiza a URL da foto do perfil (ex.: após upload no Storage).
  Future<void> updatePhotoUrl(String photoUrl);
}
