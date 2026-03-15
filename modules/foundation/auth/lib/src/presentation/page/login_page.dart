import 'dart:async';
import 'dart:io';

import 'package:auth_foundation/src/presentation/auth_cubit.dart';
import 'package:auth_foundation/src/presentation/auth_state.dart';
import 'package:auth_foundation/src/presentation/widget/google_icon.dart';
import 'package:auth_foundation/src/presentation/widget/social_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui_kit/ui_kit.dart';

/// Página de login (Google / Apple).
class LoginPage extends StatelessWidget {
  const LoginPage({
    this.onSkip,
    this.onSuccess,
    this.showSkipButton = true,
    super.key,
  });

  final VoidCallback? onSkip;
  final VoidCallback? onSuccess;
  final bool showSkipButton;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromContext(context);

    return BlocListener<AuthFlowCubit, AuthFlowState>(
      listener: (context, state) {
        if (state is AuthFlowAuthenticated) {
          onSuccess?.call();
        } else if (state is AuthFlowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.exception.message),
              backgroundColor: colors.error,
            ),
          );
          context.read<AuthFlowCubit>().clearError();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildButtons(context),
                const Spacer(),
                if (showSkipButton) _buildSkipButton(context),
                const SizedBox(height: 16),
                _buildTerms(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = AppColors.fromContext(context);
    final typography = AppTypography.fromContext(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.restaurant,
            size: 48,
            color: colors.neutralWhite,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Yummy Log',
          style: typography.heading2.copyWith(
            color: colors.neutralBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Registre suas refeições e\nconecte-se ao seu nutricionista',
          textAlign: TextAlign.center,
          style: typography.body2.copyWith(
            color: colors.grayDark,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return BlocBuilder<AuthFlowCubit, AuthFlowState>(
      builder: (context, state) {
        final isLoading = state is AuthFlowLoading;

        return Column(
          children: [
            SocialSignInButton(
              text: 'Continuar com Google',
              icon: const GoogleIcon(),
              isLoading: isLoading,
              onPressed: () {
                unawaited(context.read<AuthFlowCubit>().signInWithGoogle());
              },
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 12),
              SocialSignInButton(
                text: 'Continuar com Apple',
                icon: const AppleIcon(),
                isLoading: isLoading,
                onPressed: () {
                  unawaited(context.read<AuthFlowCubit>().signInWithApple());
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    final typography = AppTypography.fromContext(context);
    final colors = AppColors.fromContext(context);

    return TextButton(
      onPressed: onSkip,
      child: Text(
        'Continuar sem conta',
        style: typography.body2.copyWith(
          color: colors.grayDark,
        ),
      ),
    );
  }

  Widget _buildTerms(BuildContext context) {
    final typography = AppTypography.fromContext(context);
    final colors = AppColors.fromContext(context);

    return Text(
      'Ao continuar, você concorda com os\n'
      'Termos de Uso e Política de Privacidade',
      textAlign: TextAlign.center,
      style: typography.body3.copyWith(
        color: colors.gray,
      ),
    );
  }
}
