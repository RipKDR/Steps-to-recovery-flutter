import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugDumpSemanticsTree;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/theme/app_theme.dart';
import 'package:steps_recovery_flutter/features/home/screens/evening_pulse_screen.dart';
import 'package:steps_recovery_flutter/features/home/screens/home_screen.dart';
import 'package:steps_recovery_flutter/features/home/screens/morning_intention_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('guided home hub shows inline daily actions and support status', (
    tester,
  ) async {
    await createSignedInUser();

    await tester.pumpWidget(_buildHomeHarness());
    await _pumpHomeScreen(tester);

    expect(find.text("Today's path"), findsOneWidget);
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-morning-intention-field')),
    );
    expect(
      find.byKey(const Key('home-morning-intention-field')),
      findsOneWidget,
    );
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-evening-save')),
    );
    expect(find.byKey(const Key('home-evening-save')), findsOneWidget);
    await _scrollHomeUntilVisible(tester, find.text('Sponsor not added'));
    expect(find.text('Sponsor not added'), findsOneWidget);
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-more-support')),
    );
    expect(find.byKey(const Key('home-more-support')), findsOneWidget);
  });

  testWidgets('guided home hub surfaces unread achievements in the hero', (
    tester,
  ) async {
    await createSignedInUser(
      sobrietyDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    await tester.pumpWidget(_buildHomeHarness());
    await _pumpHomeScreen(tester);

    expect(find.text('Share 1 Month'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('achievement') ?? false) &&
            (widget.data?.contains('waiting') ?? false),
      ),
      findsOneWidget,
    );
  });

  testWidgets('guided home hub prioritizes evening once morning is complete', (
    tester,
  ) async {
    await createSignedInUser();
    await _saveCheckIn(
      CheckInType.morning,
      intention: 'Stay grounded and honest.',
    );

    await tester.pumpWidget(_buildHomeHarness());
    await _pumpHomeScreen(tester);

    await _scrollHomeUntilVisible(
      tester,
      find.text('Stay grounded and honest.'),
    );
    expect(find.text('Stay grounded and honest.'), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
    expect(find.text('Next up'), findsOneWidget);
  });

  testWidgets(
    'guided home hub shows completion summary when both check-ins exist',
    (tester) async {
      await createSignedInUser();
      await _saveCheckIn(CheckInType.morning, intention: 'Stay present.');
      await _saveCheckIn(
        CheckInType.evening,
        reflection: 'Called my sponsor and stayed calm.',
        craving: 2,
      );

      await tester.pumpWidget(_buildHomeHarness());
      await _pumpHomeScreen(tester);

      expect(find.text('Daily path complete'), findsOneWidget);
      await _scrollHomeUntilVisible(
        tester,
        find.byKey(const Key('home-open-evening-screen')),
      );
      expect(find.text('Done today'), findsNWidgets(2));
    },
  );

  testWidgets('inline morning save persists and refreshes home state', (
    tester,
  ) async {
    await createSignedInUser();

    await tester.pumpWidget(_buildHomeHarness(disableAnimations: true));
    await _pumpHomeScreen(tester);

    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-morning-intention-field')),
    );
    await tester.enterText(
      find.byKey(const Key('home-morning-intention-field')),
      'Keep the next right thing small.',
    );
    await tester.pump();
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-morning-save')),
    );
    await tester.tap(find.byKey(const Key('home-morning-save')));
    await _pumpHomeScreen(tester);

    final saved = await DatabaseService().getTodayCheckIn(CheckInType.morning);
    expect(saved, isNotNull);
    expect(saved?.intention, 'Keep the next right thing small.');
    expect(find.text('Evening pulse is next'), findsOneWidget);
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-open-morning-screen')),
    );
    expect(find.byKey(const Key('home-open-morning-screen')), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
  });

  testWidgets('inline evening save persists and refreshes home state', (
    tester,
  ) async {
    await createSignedInUser();

    await tester.pumpWidget(_buildHomeHarness(disableAnimations: true));
    await _pumpHomeScreen(tester);

    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-evening-save')),
    );
    await tester.tap(find.byKey(const Key('home-evening-save')));
    await _pumpHomeScreen(tester);

    final saved = await DatabaseService().getTodayCheckIn(CheckInType.evening);
    expect(saved, isNotNull);
    expect(saved?.mood, 3);
    expect(saved?.craving, 0);
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-open-evening-screen')),
    );
    expect(find.text('Done today'), findsOneWidget);
  });

  testWidgets(
    'home hub refreshes when app state changes outside the database snapshot',
    (tester) async {
      await createSignedInUser();

      await tester.pumpWidget(_buildHomeHarness(disableAnimations: true));
      await _pumpHomeScreen(tester);

      expect(find.text('Welcome back, member'), findsOneWidget);

      await AppStateService.instance.updateDisplayName('Jordan');
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Jordan'), findsOneWidget);
    },
  );

  testWidgets('primary inline controls keep accessible touch target sizes', (
    tester,
  ) async {
    await createSignedInUser();

    await tester.pumpWidget(_buildHomeHarness(disableAnimations: true));
    await _pumpHomeScreen(tester);

    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-morning-save')),
    );
    expect(
      tester.getSize(find.byKey(const Key('home-morning-save'))).height,
      greaterThanOrEqualTo(44),
    );
    await _scrollHomeUntilVisible(
      tester,
      find.byKey(const Key('home-evening-save')),
    );
    expect(
      tester.getSize(find.byKey(const Key('home-evening-save'))).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('guided home hub exposes grouped semantics for assistive tech', (
    tester,
  ) async {
    await createSignedInUser();
    final semantics = tester.ensureSemantics();
    String captureSemanticsDump() {
      final buffer = StringBuffer();
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          buffer.writeln(message);
        }
      };
      try {
        debugDumpSemanticsTree();
      } finally {
        debugPrint = originalDebugPrint;
      }
      return buffer.toString();
    }

    try {
      await tester.pumpWidget(_buildHomeHarness(disableAnimations: true));
      await _pumpHomeScreen(tester);

      final topSemanticsTree = captureSemanticsDump();
      expect(topSemanticsTree, contains('Recovery overview.'));
      expect(topSemanticsTree, contains('Morning intention.'));
      expect(topSemanticsTree, contains('Next up.'));

      await _scrollHomeUntilVisible(
        tester,
        find.byKey(const Key('home-more-support')),
      );

      final lowerSemanticsTree = captureSemanticsDump();
      expect(lowerSemanticsTree, contains('Steady supports.'));
      expect(lowerSemanticsTree, contains('Sponsor:'));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'guided home hub opens dedicated morning and evening screens from daily actions',
    (tester) async {
      await createSignedInUser();

      await tester.pumpWidget(_buildHomeRouterHarness());
      await _pumpHomeScreen(tester);

      await _scrollHomeUntilVisible(
        tester,
        find.byKey(const Key('home-open-morning-screen')),
      );
      await tester.tap(find.byKey(const Key('home-open-morning-screen')));
      await tester.pumpAndSettle();
      expect(find.text('Morning Intention'), findsOneWidget);

      final router = GoRouter.of(
        tester.element(find.text('Morning Intention')),
      );
      router.go('/home');
      await tester.pumpAndSettle();

      await _scrollHomeUntilVisible(
        tester,
        find.byKey(const Key('home-open-evening-screen')),
      );
      await tester.tap(find.byKey(const Key('home-open-evening-screen')));
      await tester.pumpAndSettle();
      expect(find.text('Evening Pulse'), findsOneWidget);
    },
  );

  testWidgets('more support sheet routes to secondary support tools', (
    tester,
  ) async {
    await createSignedInUser();

    await tester.pumpWidget(_buildHomeRouterHarness());
    await _pumpHomeScreen(tester);

    const supportRoutes = <(String, String)>[
      ('Quick journal', 'Quick journal route'),
      ('Gratitude', 'Gratitude route'),
      ('Daily reading', 'Daily reading route'),
      ('Meetings', 'Meetings route'),
      ('AI companion', 'AI companion route'),
      ('Emergency tools', 'Emergency tools route'),
    ];

    for (final route in supportRoutes) {
      await _scrollHomeUntilVisible(
        tester,
        find.byKey(const Key('home-more-support')),
      );
      await tester.tap(find.byKey(const Key('home-more-support')));
      await tester.pumpAndSettle();

      expect(find.text(route.$1), findsOneWidget);
      await tester.ensureVisible(find.text(route.$1).last);
      await tester.tap(find.text(route.$1).last);
      await tester.pumpAndSettle();
      expect(find.text(route.$2), findsOneWidget);

      final router = GoRouter.of(tester.element(find.text(route.$2)));
      router.go('/home');
      await tester.pumpAndSettle();
    }
  });
}

Widget _buildHomeHarness({bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const HomeScreen(showCelebration: false),
    ),
  );
}

Widget _buildHomeRouterHarness() {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(showCelebration: false),
        routes: [
          GoRoute(
            path: 'morning-intention',
            builder: (context, state) => const MorningIntentionScreen(),
          ),
          GoRoute(
            path: 'evening-pulse',
            builder: (context, state) => const EveningPulseScreen(),
          ),
          GoRoute(
            path: 'gratitude',
            builder: (context, state) => const _RouteMarker('Gratitude route'),
          ),
          GoRoute(
            path: 'daily-reading',
            builder: (context, state) =>
                const _RouteMarker('Daily reading route'),
          ),
          GoRoute(
            path: 'companion-chat',
            builder: (context, state) =>
                const _RouteMarker('AI companion route'),
          ),
          GoRoute(
            path: 'emergency',
            builder: (context, state) =>
                const _RouteMarker('Emergency tools route'),
          ),
        ],
      ),
      GoRoute(
        path: '/journal/editor',
        builder: (context, state) => const _RouteMarker('Quick journal route'),
      ),
      GoRoute(
        path: '/meetings',
        builder: (context, state) => const _RouteMarker('Meetings route'),
      ),
    ],
  );

  return MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router);
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}

Future<void> _saveCheckIn(
  CheckInType type, {
  String? intention,
  String? reflection,
  int mood = 3,
  int craving = 0,
}) async {
  await DatabaseService().saveCheckIn(
    DailyCheckIn(
      id: '',
      userId: DatabaseService().activeUserId ?? '',
      checkInType: type,
      checkInDate: DateTime.now(),
      intention: intention,
      reflection: reflection,
      mood: mood,
      craving: type == CheckInType.evening ? craving : null,
      createdAt: DateTime.now(),
    ),
  );
}

Future<void> _pumpHomeScreen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump(const Duration(milliseconds: 150));
}

Future<void> _scrollHomeUntilVisible(WidgetTester tester, Finder finder) async {
  final scrollView = find.byType(CustomScrollView);
  for (var i = 0; i < 8; i++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(scrollView, const Offset(0, -260), warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}
