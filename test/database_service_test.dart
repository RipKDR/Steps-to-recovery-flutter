// ignore_for_file: always_declare_return_types, strict_top_level_inference

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/core/constants/app_constants.dart';
import 'package:steps_recovery_flutter/core/constants/step_prompts.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

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

    test('persists encrypted store and sensitive fields at rest', () async {
      final database = DatabaseService();
      final userId = database.activeUserId;
      expect(userId, isNotNull);
      final currentUser = await database.getCurrentUser();
      expect(currentUser, isNotNull);
      final now = DateTime(2024, 2, 3, 10, 15);

      await database.saveUser(currentUser!);

      await database.saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: userId!,
          checkInType: CheckInType.morning,
          checkInDate: now,
          intention: 'Stay honest and ask for help.',
          reflection: 'Call sponsor before the day gets away from me.',
          mood: 4,
          craving: 7,
          createdAt: now,
        ),
      );

      final users = await database.getUsers();
      final checkIns = await database.getCheckIns();
      expect(users.any((entry) => entry.id == userId), isTrue);
      expect(checkIns, hasLength(1));
      expect(checkIns.single.mood, 4);
      expect(checkIns.single.craving, 7);

      final prefs = await getTestSharedPreferences();
      final rawStore = prefs.getString('steps_recovery_store_v2');
      expect(rawStore, isNotNull);
      expect(rawStore, isNot(startsWith('{')));
      expect(() => jsonDecode(rawStore!), throwsFormatException);

      final decryptedStore = EncryptionService().decrypt(rawStore!);
      expect(jsonDecode(decryptedStore), isA<Map<String, dynamic>>());
      expect(decryptedStore, isNot(contains('2024-01-01T00:00:00.000')));
      expect(decryptedStore, isNot(contains('"programType":"NA"')));
      expect(decryptedStore, isNot(contains('"mood":4')));
      expect(decryptedStore, isNot(contains('"craving":7')));
    });

    test('loads legacy plaintext store and rewrites it encrypted on save', () async {
      final prefs = await getTestSharedPreferences();
      final createdAt = DateTime(2024, 1, 1, 9, 0);
      final legacyStore = <String, dynamic>{
        'schemaVersion': 2,
        'activeUserId': 'legacy-user',
        'users': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'legacy-user',
            'email': 'legacy@example.com',
            'sobrietyStartDate': createdAt.toIso8601String(),
            'programType': 'AA',
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': createdAt.toIso8601String(),
          },
        ],
        'checkIns': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'legacy-checkin',
            'userId': 'legacy-user',
            'checkInType': CheckInType.morning.value,
            'checkInDate': createdAt.toIso8601String(),
            'intention': 'Stay sober today.',
            'reflection': 'Keep it simple.',
            'mood': 4,
            'craving': 7,
            'syncStatus': SyncStatus.synced.value,
            'createdAt': createdAt.toIso8601String(),
          },
        ],
      };
      await prefs.setString('steps_recovery_store_v2', jsonEncode(legacyStore));

      DatabaseService().resetForTest();
      await DatabaseService().initialize();
      final database = DatabaseService();

      final users = await database.getUsers();
      final checkIns = await database.getCheckIns();

      expect(users, hasLength(1));
      expect(users.single.sobrietyStartDate, createdAt);
      expect(users.single.programType, 'AA');
      expect(checkIns, hasLength(1));
      expect(checkIns.single.mood, 4);
      expect(checkIns.single.craving, 7);

      await database.setActiveUser('legacy-user');

      final rawStore = prefs.getString('steps_recovery_store_v2');
      expect(rawStore, isNotNull);
      expect(() => jsonDecode(rawStore!), throwsFormatException);
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

    test('falls back to insecure mode when secure storage initialization fails', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      PreferencesService().resetForTest();
      await EncryptionService().dispose();
      DatabaseService().resetForTest();
      FlutterSecureStoragePlatform.instance = _FailingSecureStoragePlatform();
      final database = DatabaseService();

      await database.initialize();

      expect(database.isInitialized, isTrue);
      expect(database.isEncryptionSecure, isFalse);
    });
  });
}

List<String> _flattenQuestions(StepPrompt step) {
  return step.sections.expand((section) => section.prompts).toList();
}

class _FailingSecureStoragePlatform extends FlutterSecureStoragePlatform {
  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => false;

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {}

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {}

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    throw StateError('Secure storage read failed');
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    throw StateError('Secure storage write failed');
  }
}
