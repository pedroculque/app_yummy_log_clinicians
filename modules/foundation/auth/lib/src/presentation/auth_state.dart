import 'package:auth_foundation/src/auth_exceptions.dart';
import 'package:auth_foundation/src/auth_repository.dart';

/// Estados do fluxo de autenticação (login/logout).
sealed class AuthFlowState {
  const AuthFlowState();
}

/// Estado inicial, verificando autenticação.
class AuthFlowInitial extends AuthFlowState {
  const AuthFlowInitial();
}

/// Carregando (login em progresso).
class AuthFlowLoading extends AuthFlowState {
  const AuthFlowLoading();
}

/// Usuário não autenticado.
class AuthFlowUnauthenticated extends AuthFlowState {
  const AuthFlowUnauthenticated();
}

/// Usuário autenticado.
class AuthFlowAuthenticated extends AuthFlowState {
  const AuthFlowAuthenticated(this.user);

  final AuthUser user;
}

/// Erro de autenticação.
class AuthFlowError extends AuthFlowState {
  const AuthFlowError(this.exception);

  final AuthException exception;
}
