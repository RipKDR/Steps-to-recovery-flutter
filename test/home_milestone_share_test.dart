import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';
import 'package:steps_recovery_flutter/features/home/screens/home_screen.dart';

import 'test_helpers.dart';

void main() {
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  late String shareResult;
  late List<MethodCall> shareCalls;

  setUp(() {
    shareResult = 'dev.fluttercommunity.plus/share/unavailable';
    shareCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, (call) async {
      shareCalls.add(call);
      return shareResult;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shareChannel, null);
  });

  testWidgets('share milestone CTA stays hidden without unread milestones', (
    tester,
  ) async {
    await createSignedInUser(sobrietyDate: DateTime.now());

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Share '), findsNothing);
  });

  testWidgets(
    'share milestone CTA prefers the highest unread milestone and clears on success',
    (tester) async {
      shareResult = 'com.example.share';

      await createSignedInUser(
        sobrietyDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Share 1 Month'), findsOneWidget);

      await tester.tap(find.text('Share 1 Month'));
      await tester.pumpAndSettle();

      expect(shareCalls, hasLength(1));
      expect(shareCalls.single.method, 'share');
      final arguments = Map<String, dynamic>.from(
        shareCalls.single.arguments as Map<Object?, Object?>,
      );
      expect(arguments['text'], contains('I just hit 30 days in recovery.'));
      expect(
        arguments['text'],
        contains('Tracking it with Steps to Recovery.'),
      );
      expect(arguments['subject'], '1 Month in recovery');
      expect(await PreferencesService().getAchievementShareTappedCount(), 1);
      expect(await PreferencesService().getAchievementShareCompletedCount(), 1);
      expect(find.text('Share 1 Month'), findsNothing);
      expect(find.text('1 Month shared.'), findsOneWidget);
    },
  );

  testWidgets('dismissed share keeps the milestone prompt and skips completion metric', (
    tester,
  ) async {
    shareResult = '';

    await createSignedInUser(
      sobrietyDate: DateTime.now().subtract(const Duration(days: 7)),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Share 1 Week'), findsOneWidget);

    await tester.tap(find.text('Share 1 Week'));
    await tester.pumpAndSettle();

    expect(await PreferencesService().getAchievementShareTappedCount(), 1);
    expect(await PreferencesService().getAchievementShareCompletedCount(), 0);
    expect(find.text('Share 1 Week'), findsOneWidget);
  });
}
