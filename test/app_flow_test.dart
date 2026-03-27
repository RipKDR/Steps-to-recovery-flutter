import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/features/crisis/screens/before_you_use_screen.dart';
import 'package:steps_recovery_flutter/features/journal/screens/journal_editor_screen.dart';
import 'package:steps_recovery_flutter/features/meetings/screens/meeting_detail_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('journal editor saves an entry to the local database', (tester) async {
    await createSignedInUser();

    await tester.pumpWidget(
      const MaterialApp(
        home: JournalEditorScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.widgetWithText(TextField, 'Entry title'), 'Evening check-in');
    await tester.enterText(find.widgetWithText(TextField, 'Write your thoughts...'), 'I stayed clean today.');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final entries = await DatabaseService().getJournalEntries();
    expect(entries, hasLength(1));
    expect(entries.single.title, 'Evening check-in');
  });

  testWidgets('meeting detail loads a locally stored meeting', (tester) async {
    await createSignedInUser();
    final meeting = (await DatabaseService().getMeetings()).first;

    await tester.pumpWidget(
      MaterialApp(
        home: MeetingDetailScreen(meetingId: meeting.id),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(meeting.name), findsOneWidget);
    expect(find.textContaining('Directions'), findsOneWidget);
  });

  testWidgets('before you use timer runs offline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: BeforeYouUseScreen(),
      ),
    );

    expect(find.text('Before You Use'), findsOneWidget);
    expect(find.text('Start Timer'), findsOneWidget);

    await tester.tap(find.text('Start Timer'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Breathe slowly and deeply'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
