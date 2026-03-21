import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Shell screen with bottom navigation bar
class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryAmber.withOpacity(0.2),
        selectedIndex: _calculateSelectedIndex(location),
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
      ),
    );
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
