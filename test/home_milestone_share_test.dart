import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:share_plus/share_plus.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';
import 'package:steps_recovery_flutter/features/home/screens/home_screen.dart';

import 'test_helpers.dart';

/// A fake [SharePlatform] that captures calls and returns a controlled result.
/// Avoids any platform-channel or url_launcher path.
class _FakeSharePlatform extends SharePlatform {
  _FakeSharePlatform({required ShareResultStatus status})
      : _status = status;

  final ShareResultStatus _status;
  final List<ShareParams> calls = [];

  @override
  Future<ShareResult> share(ShareParams params) async {
    calls.add(params);
    return ShareResult('test', _status);
  }
}

void main() {
  testWidgets('share milestone CTA stays hidden without unread milestones', (
    tester,
  ) async {
    await createSignedInUser(sobrietyDate: DateTime.now());

    final fakePlatform = _FakeSharePlatform(
      status: ShareResultStatus.unavailable,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          showCelebration: false,
          sharePlus: SharePlus.custom(fakePlatform),
        ),
      ),
    );
    await _pumpHomeScreen(tester);

    expect(find.textContaining('Share '), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'share milestone CTA prefers the highest unread milestone and clears on success',
    (tester) async {
      final fakePlatform = _FakeSharePlatform(status: ShareResultStatus.success);

      await createSignedInUser(
        sobrietyDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            showCelebration: false,
            sharePlus: SharePlus.custom(fakePlatform),
          ),
        ),
      );
      await _pumpHomeScreen(tester);

      expect(find.text('Share 1 Month'), findsOneWidget);

      await tester.tap(find.text('Share 1 Month'));
      await _pumpAfterInteraction(tester);

      expect(fakePlatform.calls, hasLength(1));
      final params = fakePlatform.calls.single;
      expect(params.text, contains('I just hit 30 days in recovery.'));
      expect(params.text, contains('Tracking it with Steps to Recovery.'));
      expect(params.subject, '1 Month in recovery');
      expect(await PreferencesService().getAchievementShareTappedCount(), 1);
      expect(await PreferencesService().getAchievementShareCompletedCount(), 1);
      expect(find.text('Share 1 Month'), findsNothing);
      expect(find.text('1 Month shared.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'dismissed share keeps the milestone prompt and skips completion metric',
    (tester) async {
      final fakePlatform = _FakeSharePlatform(
        status: ShareResultStatus.dismissed,
      );

      await createSignedInUser(
        sobrietyDate: DateTime.now().subtract(const Duration(days: 7)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            showCelebration: false,
            sharePlus: SharePlus.custom(fakePlatform),
          ),
        ),
      );
      await _pumpHomeScreen(tester);

      expect(find.text('Share 1 Week'), findsOneWidget);

      await tester.tap(find.text('Share 1 Week'));
      await _pumpAfterInteraction(tester);

      expect(await PreferencesService().getAchievementShareTappedCount(), 1);
      expect(await PreferencesService().getAchievementShareCompletedCount(), 0);
      expect(find.text('Share 1 Week'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Future<void> _pumpHomeScreen(WidgetTester tester) async {
  await tester.pump();
  // Pump past flutter_animate entrance durations (longest is 800ms on sobriety card)
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _pumpAfterInteraction(WidgetTester tester) async {
  // Each pump flushes microtasks; _shareMilestone has ~5 async steps before
  // reaching fakePlatform.share(), plus post-share DB/prefs writes.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
