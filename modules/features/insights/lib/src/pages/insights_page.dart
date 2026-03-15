import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);

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
                  'Insights',
                  style: AppTextStyles.h2.copyWith(
                    color: appColors.neutralBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Em breve você poderá visualizar métricas e dados '
                  'dos seus pacientes aqui.',
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
