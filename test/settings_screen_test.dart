import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/features/profile/screens/settings_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('settings screen saves reminder times chosen from time pickers', (
    tester,
  ) async {
    // Set a larger viewport to ensure "Save changes" is fully reachable
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await createSignedInUser();

    final pickedTimes = <TimeOfDay>[
      const TimeOfDay(hour: 7, minute: 15),
      const TimeOfDay(hour: 21, minute: 45),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          pickReminderTime: (context, initialTime) async =>
              pickedTimes.removeAt(0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-morning-reminder')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-evening-reminder')));
    await tester.pumpAndSettle();

    final saveButton = find.text('Save changes');
    await tester.scrollUntilVisible(
      saveButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(AppStateService.instance.morningReminderTime, '07:15');
    expect(AppStateService.instance.eveningReminderTime, '21:45');
  });

  testWidgets(
    'settings screen hides reminder pickers when notifications are off',
    (tester) async {
      await createSignedInUser();
      await AppStateService.instance.setNotificationsEnabled(false);


      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            pickReminderTime: (context, initialTime) async {
              return const TimeOfDay(hour: 6, minute: 30);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In the updated UI, tiles are hidden instead of showing "Enable notifications to edit"
      expect(find.byKey(const Key('settings-morning-reminder')), findsNothing);
      expect(find.byKey(const Key('settings-evening-reminder')), findsNothing);
    },
  );
}
