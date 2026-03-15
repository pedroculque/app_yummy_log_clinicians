import 'package:auth_foundation/src/presentation/auth_cubit.dart';
import 'package:auth_foundation/src/presentation/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget que exibe conteúdo conforme o estado de autenticação.
class AuthGuard extends StatelessWidget {
  const AuthGuard({
    required this.authenticated,
    required this.unauthenticated,
    this.loading,
    super.key,
  });

  final Widget authenticated;
  final Widget unauthenticated;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthFlowCubit, AuthFlowState>(
      builder: (context, state) {
        return switch (state) {
          AuthFlowAuthenticated() => authenticated,
          AuthFlowLoading() => loading ?? unauthenticated,
          AuthFlowInitial() => loading ?? unauthenticated,
          _ => unauthenticated,
        };
      },
    );
  }
}
