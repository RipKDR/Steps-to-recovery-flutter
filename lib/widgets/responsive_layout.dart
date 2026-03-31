import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Breakpoints for responsive layout.
enum ScreenSize { mobile, tablet, desktop }

/// Determines the current screen size from width.
ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= 900) return ScreenSize.desktop;
  if (width >= 600) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

/// Responsive layout builder that provides different widgets per breakpoint.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Master-detail layout for lists (journal, step work) on wider screens.
class MasterDetailLayout extends StatefulWidget {
  const MasterDetailLayout({
    super.key,
    required this.masterBuilder,
    required this.detailBuilder,
    this.emptyDetailBuilder,
    this.masterWidth = 360,
  });

  final Widget Function(BuildContext context, ValueChanged<int> onSelect)
      masterBuilder;
  final Widget Function(BuildContext context, int selectedIndex) detailBuilder;
  final Widget Function(BuildContext context)? emptyDetailBuilder;
  final double masterWidth;

  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);

    if (size == ScreenSize.mobile) {
      // On mobile, master and detail are separate routes (handled by router)
      return widget.masterBuilder(context, (index) {
        setState(() => _selectedIndex = index);
      });
    }

    // Tablet/desktop: side-by-side master-detail
    return Row(
      children: [
        SizedBox(
          width: widget.masterWidth,
          child: widget.masterBuilder(context, (index) {
            setState(() => _selectedIndex = index);
          }),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedIndex != null
              ? widget.detailBuilder(context, _selectedIndex!)
              : widget.emptyDetailBuilder?.call(context) ??
                  const Center(
                    child: Text('Select an item'),
                  ),
        ),
      ],
    );
  }
}

/// Adaptive navigation that switches between bottom tabs, rail, and sidebar.
class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);

    switch (size) {
      case ScreenSize.desktop:
        return Row(
          children: [
            NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Steps to Recovery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...destinations.map(
                  (d) => NavigationDrawerDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        );

      case ScreenSize.tablet:
        return Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        );

      case ScreenSize.mobile:
        return Scaffold(
          body: body,
          bottomNavigationBar: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.glassBorder.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: destinations,
                ),
              ),
            ),
          ),
        );
    }
  }
}
