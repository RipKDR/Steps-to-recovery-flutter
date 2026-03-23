import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/constants/app_constants.dart';
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

    test('journal entry round-trip preserves all fields', () async {
      final database = DatabaseService();
      final userId = database.activeUserId ?? '';
      final createdAt = DateTime(2024, 6, 1, 10, 30);

      await database.saveJournalEntry(
        JournalEntry(
          id: '',
          userId: userId,
          title: 'Full round-trip test',
          content: 'Content with unicode: \u2764\ufe0f',
          mood: 'grateful',
          craving: 'low',
          tags: const <String>['sponsor', 'gratitude', 'step-work'],
          isFavorite: true,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final entries = await database.getJournalEntries();
      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.title, 'Full round-trip test');
      expect(entry.content, 'Content with unicode: \u2764\ufe0f');
      expect(entry.mood, 'grateful');
      expect(entry.craving, 'low');
      expect(entry.tags, containsAll(<String>['sponsor', 'gratitude', 'step-work']));
      expect(entry.isFavorite, isTrue);
    });

    test('safety plan round-trip preserves all five list fields', () async {
      final database = DatabaseService();
      final userId = database.activeUserId ?? '';
      final now = DateTime.now();

      await database.saveSafetyPlan(
        SafetyPlan(
          id: '',
          userId: userId,
          warningSigns: const <String>['Anger', 'Isolation'],
          copingStrategies: const <String>['Call sponsor', 'Meeting'],
          supportContacts: const <String>['Alex', 'Jordan'],
          professionalContacts: const <String>['Dr. Smith'],
          safeEnvironments: const <String>['Home', 'Meeting hall'],
          createdAt: now,
          updatedAt: now,
        ),
      );

      final plan = await database.getSafetyPlan(userId);
      expect(plan, isNotNull);
      expect(plan!.warningSigns, <String>['Anger', 'Isolation']);
      expect(plan.copingStrategies, <String>['Call sponsor', 'Meeting']);
      expect(plan.supportContacts, <String>['Alex', 'Jordan']);
      expect(plan.professionalContacts, <String>['Dr. Smith']);
      expect(plan.safeEnvironments, <String>['Home', 'Meeting hall']);
    });

    test('getCheckIns(limit: N) returns at most N records', () async {
      final database = DatabaseService();
      final userId = database.activeUserId ?? '';

      // Save 5 check-ins on different dates
      for (var i = 0; i < 5; i++) {
        await database.saveCheckIn(
          DailyCheckIn(
            id: '',
            userId: userId,
            checkInType: CheckInType.morning,
            checkInDate: DateTime(2024, 1, i + 1),
            createdAt: DateTime(2024, 1, i + 1),
          ),
        );
      }

      final limited = await database.getCheckIns(limit: 3);
      expect(limited.length, lessThanOrEqualTo(3));
    });

    test('deleteCheckIn removes the entry', () async {
      final database = DatabaseService();
      final userId = database.activeUserId ?? '';
      final now = DateTime.now();

      final saved = await database.saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: userId,
          checkInType: CheckInType.evening,
          checkInDate: now,
          createdAt: now,
        ),
      );

      await database.deleteCheckIn(saved.id);

      final checkIns = await database.getCheckIns();
      expect(checkIns.where((c) => c.id == saved.id), isEmpty);
    });

    test('30 check-ins triggers streak_30d achievement', () async {
      final database = DatabaseService();
      final userId = database.activeUserId ?? '';

      for (var i = 0; i < 30; i++) {
        await database.saveCheckIn(
          DailyCheckIn(
            id: '',
            userId: userId,
            checkInType: CheckInType.morning,
            checkInDate: DateTime(2024, 1, i + 1),
            createdAt: DateTime(2024, 1, i + 1),
          ),
        );
      }

      final achievements = await database.getAchievements();
      final keys = achievements.map((a) => a.achievementKey).toSet();
      expect(keys.contains(AchievementKeys.streak30Days), isTrue);
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
