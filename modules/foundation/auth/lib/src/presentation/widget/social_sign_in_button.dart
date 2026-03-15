import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Botão de login social (Google, Apple).
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.text,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.enabled = true,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromContext(context);
    final typography = AppTypography.fromContext(context);

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.gray),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 24, height: 24, child: icon),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: typography.buttonMedium.copyWith(
                      color: colors.neutralBlack,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Ícone da Apple para o botão de login.
class AppleIcon extends StatelessWidget {
  const AppleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromContext(context);
    return Icon(
      Icons.apple,
      size: 24,
      color: colors.neutralBlack,
    );
  }
}
