import 'dart:async';

import 'package:app_yummy_log_clinicians/core/notifications/clinician_notification_service.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yummy_log_l10n/yummy_log_l10n.dart';

/// Shell do app: tab bar (Pacientes, Insights, Configurações)
/// e área de conteúdo.
class AppShell extends StatefulWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    // Token FCM só após a home (tabs). No iOS, pequeno delay p/ APNS antes do getToken.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        Future<void>.delayed(
          const Duration(milliseconds: 800),
          () => unawaited(GetIt.I<ClinicianNotificationService>().start()),
        );
      } else {
        unawaited(GetIt.I<ClinicianNotificationService>().start());
      }
    });
  }

  static List<_TabItem> _buildTabs(AppLocalizations l10n) => [
    _TabItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: l10n.navPatients,
    ),
    _TabItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      label: l10n.navInsights,
    ),
    _TabItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: l10n.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appColors = AppColors.fromContext(context);
    final tabs = _buildTabs(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? appColors.neutralBlack : appColors.neutralWhite;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: barColor,
          border: Border(
            top: BorderSide(
              color: appColors.gray.withValues(alpha: 0.12),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: appColors.neutralBlack.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isSelected = widget.navigationShell.currentIndex == i;
                return Expanded(
                  child: _NavBarItem(
                    tab: tabs[i],
                    isSelected: isSelected,
                    selectedColor: appColors.primary,
                    unselectedColor: appColors.gray,
                    pillColor: appColors.primary.withValues(alpha: 0.1),
                    onTap: () => widget.navigationShell.goBranch(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.pillColor,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color pillColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? pillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: AppTextStyles.body3.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
