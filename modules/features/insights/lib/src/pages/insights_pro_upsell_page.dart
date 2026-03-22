import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

/// Tela simples quando o utilizador sem Pro abre rotas só do plano pago.
class InsightsProUpsellPage extends StatelessWidget {
  const InsightsProUpsellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: appColors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: appColors.backgroundDefault,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: appColors.neutralBlack),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.insightsDashboard,
          style: AppTextStyles.h4.copyWith(color: appColors.neutralBlack),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56,
              color: appColors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.insightsProUpsellTitle,
              style: AppTextStyles.h2.copyWith(color: appColors.neutralBlack),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.insightsProUpsellBody,
              style: AppTextStyles.body1.copyWith(color: appColors.grayDark),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                context.pop();
                unawaited(context.push('/plans'));
              },
              style: FilledButton.styleFrom(
                backgroundColor: appColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.upgradeToPro,
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
