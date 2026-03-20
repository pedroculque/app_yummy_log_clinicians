/// Exceções de autenticação.
sealed class AuthException implements Exception {
  const AuthException();

  /// Mensagem de erro para exibir ao usuário.
  String get message;
}

/// Usuário cancelou o login.
class AuthCancelledException extends AuthException {
  const AuthCancelledException();

  @override
  String get message => 'Login cancelado';
}

/// Erro de rede/conexão.
class AuthNetworkException extends AuthException {
  const AuthNetworkException();

  @override
  String get message => 'Erro de conexão. Verifique sua internet.';
}

/// Credencial inválida.
class AuthInvalidCredentialException extends AuthException {
  const AuthInvalidCredentialException();

  @override
  String get message => 'Credencial inválida';
}

/// Conta já existe com outro provider.
class AuthAccountExistsException extends AuthException {
  const AuthAccountExistsException(this.existingProvider);

  final String existingProvider;

  @override
  String get message =>
      'Esta conta já existe com $existingProvider. '
      'Use esse método para entrar.';
}

/// Email já está em uso.
class AuthEmailAlreadyInUseException extends AuthException {
  const AuthEmailAlreadyInUseException();

  @override
  String get message => 'Este email já está em uso.';
}

/// Senha fraca.
class AuthWeakPasswordException extends AuthException {
  const AuthWeakPasswordException();

  @override
  String get message => 'A senha é muito fraca. Use pelo menos 6 caracteres.';
}

/// Usuário não encontrado.
class AuthUserNotFoundException extends AuthException {
  const AuthUserNotFoundException();

  @override
  String get message => 'Usuário não encontrado.';
}

/// Senha incorreta.
class AuthWrongPasswordException extends AuthException {
  const AuthWrongPasswordException();

  @override
  String get message => 'Senha incorreta.';
}

/// Erro desconhecido.
class AuthUnknownException extends AuthException {
  const AuthUnknownException([this.details]);

  final String? details;

  @override
  String get message => 'Erro ao fazer login. Tente novamente.';
}

/// Exclusão de conta exige login recente (reautenticar e tentar de novo).
class AuthRequiresRecentLoginException extends AuthException {
  const AuthRequiresRecentLoginException();

  @override
  String get message =>
      'Por segurança, saia e entre novamente nesta conta e repita a exclusão.';
}
