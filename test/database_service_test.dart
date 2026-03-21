import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/constants/step_prompts.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';

import 'test_helpers.dart';

void main() {
  group('DatabaseService', () {
    setUp(() async {
      await createSignedInUser();
    });

    test('encrypts journal entries at rest and restores them on read', () async {
      final database = DatabaseService();
      const title = 'Honest reflection';
      const content = 'Today I stayed present and called my sponsor.';

      await database.saveJournalEntry(
        JournalEntry(
          id: '',
          userId: database.activeUserId ?? '',
          title: title,
          content: content,
          tags: const <String>['Reflection', 'Sponsor'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final entries = await database.getJournalEntries();
      expect(entries, hasLength(1));
      expect(entries.single.title, title);
      expect(entries.single.content, content);

      final exported = await database.exportData();
      final journalJson =
          ((exported['journalEntries'] as List<dynamic>).single as Map<String, dynamic>);
      expect(journalJson['title'], isNot(title));
      expect(journalJson['content'], isNot(content));
      expect((journalJson['tags'] as List<dynamic>).contains('Reflection'), isFalse);
    });

    test('persists and reloads morning check-ins', () async {
      final database = DatabaseService();
      final now = DateTime.now();

      await database.saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: database.activeUserId ?? '',
          checkInType: CheckInType.morning,
          checkInDate: now,
          intention: 'Stay connected and ask for help early.',
          mood: 4,
          createdAt: now,
        ),
      );

      final todayCheckIn = await database.getTodayCheckIn(CheckInType.morning);
      expect(todayCheckIn, isNotNull);
      expect(todayCheckIn!.intention, 'Stay connected and ask for help early.');
      expect(todayCheckIn.mood, 4);
    });

    test('saves step answers and computes completed progress', () async {
      final database = DatabaseService();
      final prompts = _flattenQuestions(StepPrompts.getStep(1)!);

      for (var index = 0; index < prompts.length; index += 1) {
        await database.saveStepAnswer(
          StepWorkAnswer(
            id: '',
            userId: database.activeUserId ?? '',
            stepNumber: 1,
            questionNumber: index + 1,
            answer: 'Answer ${index + 1}',
            isComplete: true,
            completedAt: DateTime.now(),
            syncStatus: SyncStatus.pending,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      final progress = await database.getStepProgress();
      final stepOne = progress.firstWhere((item) => item.stepNumber == 1);
      final answers = await database.getStepAnswers(stepNumber: 1);

      expect(answers.length, prompts.length);
      expect(stepOne.status, StepStatus.completed);
      expect(stepOne.completionPercentage, 1);
    });
  });
}

List<String> _flattenQuestions(StepPrompt step) {
  return step.sections.expand((section) => section.prompts).toList();
}
