import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 64,
                  color: appColors.gray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.insightsTitle,
                  style: AppTextStyles.h2.copyWith(
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.insightsComingSoonSubtitle,
                  style: AppTextStyles.body1.copyWith(
                    color: appColors.gray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
