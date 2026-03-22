/// Dados do usuário autenticado (ex.: Firebase Auth).
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Identificador estável da conta (Firebase UID).
  ///
  /// É o mesmo valor exibido como **ID de Suporte** nas Configurações e
  /// propagado ao session logger / Sentry para correlação com suporte.
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
  ///
  /// Na implementação Firebase, inclui alterações de perfil (foto, nome)
  /// via o stream `userChanges` do SDK, não só login/logout.
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

  /// Remove o usuário do provedor de autenticação (após limpar dados no
  /// backend).
  ///
  /// Pode exigir login recente; nesse caso o repositório lança a exceção
  /// correspondente (ex.: credencial recente).
  Future<void> deleteAccount();
}
