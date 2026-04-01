import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/models/enums.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/milestone_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PreferencesService().resetForTest();
    EncryptionService().resetForTest();
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
    await EncryptionService().initialize();
  });

  group('MilestoneService.shouldShowCelebration', () {
    Achievement makeAchievement(String key) => Achievement(
          id: key,
          userId: 'u1',
          achievementKey: key,
          type: AchievementType.milestone,
          earnedAt: DateTime.now(),
        );

    test('returns null when list is empty', () async {
      final result = await MilestoneService().shouldShowCelebration([]);
      expect(result, isNull);
    });

    test('returns first achievement when none have been shown', () async {
      final a = makeAchievement('milestone_7');
      final result = await MilestoneService().shouldShowCelebration([a]);
      expect(result, equals(a));
    });

    test('skips achievement that was already shown', () async {
      final prefs = PreferencesService();
      await prefs.initialize();
      await prefs.markMilestoneCelebrationShown('milestone_7');

      final a = makeAchievement('milestone_7');
      final b = makeAchievement('milestone_30');
      final result = await MilestoneService().shouldShowCelebration([a, b]);
      expect(result, equals(b));
    });

    test('returns null when all achievements have been shown', () async {
      final prefs = PreferencesService();
      await prefs.initialize();
      await prefs.markMilestoneCelebrationShown('milestone_7');

      final a = makeAchievement('milestone_7');
      final result = await MilestoneService().shouldShowCelebration([a]);
      expect(result, isNull);
    });
  });
}
