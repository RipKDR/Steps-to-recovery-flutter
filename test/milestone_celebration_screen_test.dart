import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/models/enums.dart';
import 'package:steps_recovery_flutter/features/milestone/screens/milestone_celebration_screen.dart';

import 'test_helpers.dart';

Achievement _makeAchievement(String key) => Achievement(
      id: key,
      userId: 'u1',
      achievementKey: key,
      type: AchievementType.milestone,
      earnedAt: DateTime.now(),
    );

void main() {
  setUp(() async {
    await prepareTestState();
  });

  testWidgets('shows milestone title and continue button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MilestoneCelebrationScreen(
        achievement: _makeAchievement('milestone_7'),
      ),
    ));
    await tester.pump();

    expect(find.textContaining('1 Week'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('continue button dismisses the dialog', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () async {
            await showGeneralDialog(
              context: ctx,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              pageBuilder: (c, _, __) => MilestoneCelebrationScreen(
                achievement: _makeAchievement('milestone_7'),
              ),
            );
            dismissed = true;
          },
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });

  testWidgets('shows fallback UI for unknown milestone key', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MilestoneCelebrationScreen(
        achievement: _makeAchievement('milestone_9999'),
      ),
    ));
    await tester.pump();

    // Should still render with fallback content
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('share button is present', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MilestoneCelebrationScreen(
        achievement: _makeAchievement('milestone_30'),
      ),
    ));
    await tester.pump();

    expect(find.text('Share'), findsOneWidget);
  });
}
