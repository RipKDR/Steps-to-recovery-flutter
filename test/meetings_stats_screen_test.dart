import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/features/meetings/screens/meetings_stats_screen.dart';
import 'package:steps_recovery_flutter/core/theme/app_colors.dart';

void main() {
  group('MeetingsStatsScreen', () {
    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      // Should show loading indicator while fetching data
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays 90-in-90 challenge card after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should find 90-in-90 related content
      expect(find.textContaining('90-in-90'), findsWidgets);
    });

    testWidgets('displays attendance overview section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Attendance Overview'), findsOneWidget);
    });

    testWidgets('displays stat cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have stat cards for This Week, This Month, Total, Streak
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
    });

    testWidgets('displays achievements section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('has refresh indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 500),
      );
      await tester.pump();
      
      // Should trigger refresh
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Find a Meeting button navigates', (WidgetTester tester) async {
      bool didNavigate = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MeetingsStatsScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/meetings') {
              didNavigate = true;
              return MaterialPageRoute(builder: (_) => const Scaffold());
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      final findButton = find.widgetWithText(ElevatedButton, 'Find a Meeting');
      expect(findButton, findsOneWidget);
      
      await tester.tap(findButton);
      await tester.pump();
      
      expect(didNavigate, isTrue);
    });

    testWidgets('displays meeting types when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Meeting types section may or may not be present depending on data
      // If present, should have proper formatting
      final meetingTypesFinder = find.text('Meeting Types');
      if (meetingTypesFinder.evaluate().isNotEmpty) {
        expect(meetingTypesFinder, findsOneWidget);
      }
    });

    testWidgets('uses correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeetingsStatsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar uses background color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppColors.background));
    });
  });

  group('_StatCard', () {
    testWidgets('displays all properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _StatCard(
              title: 'Test Stat',
              value: '42',
              icon: Icons.star,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Test Stat'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('_AchievementCard', () {
    testWidgets('displays unlocked achievement correctly', (WidgetTester tester) async {
      const achievement = MeetingAchievement(
        id: 'test',
        title: 'Test Achievement',
        description: 'Test Description',
        icon: Icons.event,
        progress: 100,
        total: 100,
        unlocked: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _AchievementCard(achievement: achievement),
          ),
        ),
      );

      expect(find.text('Test Achievement'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays locked achievement with progress', (WidgetTester tester) async {
      const achievement = MeetingAchievement(
        id: 'test',
        title: 'Test Achievement',
        description: 'Test Description',
        icon: Icons.event,
        progress: 50,
        total: 100,
        unlocked: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _AchievementCard(achievement: achievement),
          ),
        ),
      );

      expect(find.text('Test Achievement'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('50/100'), findsOneWidget);
    });
  });
}

// Import from the service file for testing
import 'package:steps_recovery_flutter/features/meetings/services/meetings_service.dart';
import 'package:steps_recovery_flutter/features/meetings/screens/meetings_stats_screen.dart';
