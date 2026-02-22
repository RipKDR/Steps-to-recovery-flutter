import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages.dart';
import 'recovery_controller.dart';

GoRouter buildRouter(RecoveryController controller) {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppScaffold(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => HomePage(controller: controller),
          ),
          GoRoute(
            path: '/checkin',
            builder: (context, state) => CheckinPage(controller: controller),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => JournalPage(controller: controller),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => ProgressPage(controller: controller),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => SupportPage(controller: controller),
          ),
        ],
      ),
    ],
  );
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  int _indexFromLocation(String path) {
    if (path.startsWith('/checkin')) return 1;
    if (path.startsWith('/journal')) return 2;
    if (path.startsWith('/progress')) return 3;
    if (path.startsWith('/support')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexFromLocation(location);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              return;
            case 1:
              context.go('/checkin');
              return;
            case 2:
              context.go('/journal');
              return;
            case 3:
              context.go('/progress');
              return;
            case 4:
              context.go('/support');
              return;
            default:
              return;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
