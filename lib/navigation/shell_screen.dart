import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/responsive_layout.dart';

/// Shell screen with adaptive navigation (bottom tabs / rail / sidebar)
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _calculateSelectedIndex(location);

    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primaryAmber.withValues(alpha: 0.15),
          indicatorShape: const StadiumBorder(),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.labelSmall.copyWith(
                color: AppColors.primaryAmber,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryAmber, size: 22);
            }
            return const IconThemeData(color: AppColors.textMuted, size: 22);
          }),
        ),
      ),
      child: PopScope(
        canPop: !_isRootTab(location),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && location != '/home') {
            context.go('/home');
          }
        },
        child: AdaptiveNavigation(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryAmber),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_outlined),
              selectedIcon: Icon(Icons.edit, color: AppColors.primaryAmber),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.stairs_outlined),
              selectedIcon: Icon(Icons.stairs, color: AppColors.primaryAmber),
              label: 'Steps',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outlined),
              selectedIcon: Icon(Icons.people, color: AppColors.primaryAmber),
              label: 'Meetings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primaryAmber),
              label: 'Profile',
            ),
          ],
          body: FocusTraversalGroup(child: child),
        ),
      ),
    );
  }

  bool _isRootTab(String location) {
    const roots = ['/home', '/journal', '/steps', '/meetings', '/profile'];
    return roots.contains(location);
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/journal')) return 1;
    if (location.startsWith('/steps')) return 2;
    if (location.startsWith('/meetings')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/journal');
        break;
      case 2:
        context.go('/steps');
        break;
      case 3:
        context.go('/meetings');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
