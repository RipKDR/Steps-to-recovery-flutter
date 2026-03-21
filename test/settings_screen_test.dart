import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/features/profile/screens/settings_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('settings screen saves reminder times chosen from time pickers', (
    tester,
  ) async {
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

    await tester.scrollUntilVisible(
      find.text('Save changes'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(AppStateService.instance.morningReminderTime, '07:15');
    expect(AppStateService.instance.eveningReminderTime, '21:45');
  });

  testWidgets(
    'settings screen disables reminder pickers when notifications are off',
    (tester) async {
      await createSignedInUser();
      await AppStateService.instance.setNotificationsEnabled(false);

      var pickerCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            pickReminderTime: (_, __) async {
              pickerCalls += 1;
              return const TimeOfDay(hour: 6, minute: 30);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enable notifications to edit'), findsNWidgets(2));

      await tester.tap(find.byKey(const Key('settings-morning-reminder')));
      await tester.pumpAndSettle();

      expect(pickerCalls, 0);
    },
  );
}
