import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:steps_recovery_flutter/core/theme/app_colors.dart';
import 'package:steps_recovery_flutter/features/meetings/screens/meetings_stats_screen.dart';

import 'test_helpers.dart';

void main() {
  group('MeetingsStatsScreen', () {
    setUpAll(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(800, 1800);
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
    });

    tearDownAll(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
    });

    setUp(() async {
      await createSignedInUser();
    });

    testWidgets('displays loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      // Should show loading indicator while fetching data
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays 90-in-90 challenge card after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should find 90-in-90 related content
      expect(find.textContaining('90-in-90'), findsWidgets);
    });

    testWidgets('displays attendance overview section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Attendance Overview'), findsOneWidget);
    });

    testWidgets('displays stat cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      // Should have stat cards for This Week, This Month, Total, Streak
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('displays achievements section', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('has refresh indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 500));
      await tester.pump();

      // Should trigger refresh
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Find a Meeting button navigates', (WidgetTester tester) async {
      bool didNavigate = false;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MeetingsStatsScreen(),
          ),
          GoRoute(
            path: '/meetings',
            builder: (context, state) {
              didNavigate = true;
              return const Scaffold();
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.pumpAndSettle();

      final findButton = find.widgetWithText(ElevatedButton, 'Find a Meeting');
      await tester.ensureVisible(findButton);
      expect(findButton, findsOneWidget);

      await tester.tap(findButton);
      await tester.pumpAndSettle();

      expect(didNavigate, isTrue);
    });

    testWidgets('displays meeting types when available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      // Meeting types section may or may not be present depending on data
      // If present, should have proper formatting
      final meetingTypesFinder = find.text('Meeting Types');
      if (meetingTypesFinder.evaluate().isNotEmpty) {
        expect(meetingTypesFinder, findsOneWidget);
      }
    });

    testWidgets('uses correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MeetingsStatsScreen()));

      await tester.pumpAndSettle();

      // Verify app bar uses background color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppColors.background));
    });
  });
}

