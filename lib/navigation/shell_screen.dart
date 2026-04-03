import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/sponsor_service.dart';
import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

/// Shell screen with adaptive navigation (bottom tabs / rail / sidebar)
/// Now reactive to SponsorService for badge state
class ShellScreen extends StatefulWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  @override
  void initState() {
    super.initState();
    SponsorService.instance.addListener(_onSponsorChanged);
  }

  @override
  void dispose() {
    SponsorService.instance.removeListener(_onSponsorChanged);
    super.dispose();
  }

  void _onSponsorChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final hasBadge = SponsorService.instance.hasPendingMessage;

    // Clear badge when user visits sponsor-related screens
    if (location.startsWith('/profile') || location == '/home/companion-chat') {
      SponsorService.instance.clearPendingMessage();
    }

    return PopScope(
      canPop: !_isRootTab(location),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && location != '/home') {
          context.go('/home');
        }
      },
      child: AdaptiveNavigation(
        selectedIndex: _calculateSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryAmber),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit, color: AppColors.primaryAmber),
            label: 'Journal',
          ),
          const NavigationDestination(
            icon: Icon(Icons.stairs_outlined),
            selectedIcon: Icon(Icons.stairs, color: AppColors.primaryAmber),
            label: 'Steps',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people, color: AppColors.primaryAmber),
            label: 'Meetings',
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              icon: const Icon(Icons.person_outline),
              showBadge: hasBadge,
            ),
            selectedIcon: _BadgeIcon(
              icon: const Icon(Icons.person, color: AppColors.primaryAmber),
              showBadge: hasBadge,
            ),
            label: 'Profile',
          ),
        ],
        body: FocusTraversalGroup(child: widget.child),
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

/// Badge icon widget with amber dot overlay
class _BadgeIcon extends StatelessWidget {
  final Widget icon;
  final bool showBadge;

  const _BadgeIcon({required this.icon, required this.showBadge});

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryAmber,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
