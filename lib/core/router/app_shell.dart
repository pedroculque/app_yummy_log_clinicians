import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

/// Shell do app: tab bar (Pacientes, Insights, Configurações)
/// e área de conteúdo.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_TabItem>[
    _TabItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Pacientes',
    ),
    _TabItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      label: 'Insights',
    ),
    _TabItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Configurações',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.fromContext(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? appColors.neutralBlack : appColors.neutralWhite;

    return Scaffold(
      body: navigationShell,
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
              children: List.generate(_tabs.length, (i) {
                final isSelected = navigationShell.currentIndex == i;
                return Expanded(
                  child: _NavBarItem(
                    tab: _tabs[i],
                    isSelected: isSelected,
                    selectedColor: appColors.primary,
                    unselectedColor: appColors.gray,
                    pillColor: appColors.primary.withValues(alpha: 0.1),
                    onTap: () => navigationShell.goBranch(i),
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
