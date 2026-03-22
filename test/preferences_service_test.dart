/*
* Created on Mar 22, 2026
* Test file for preferences_service.dart
* File path: test/preferences_service_test.dart
*
* Author: Abhijeet Pratap Singh - Senior Software Engineer
* Copyright (c) 2026 Aurigo
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

/// Helper: reset singleton + mock prefs before every test.
Future<PreferencesService> _freshService() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final svc = PreferencesService()..resetForTest();
  await svc.initialize();
  return svc;
}

void main() {
  group('PreferencesService', () {
    // ── initialize ──────────────────────────────────────────────────────────

    group('initialize', () {
      test('completes without error on first call', () async {
        final svc = await _freshService();
        // No assertion needed — if initialize throws the test fails.
        expect(svc, isNotNull);
      });

      test('is idempotent — second call is a no-op', () async {
        final svc = await _freshService();
        // Call a second time; must not throw.
        await svc.initialize();
        expect(svc, isNotNull);
      });
    });

    // ── onboarding ──────────────────────────────────────────────────────────

    group('onboarding', () {
      test('isOnboardingComplete defaults to false', () async {
        final svc = await _freshService();
        expect(svc.isOnboardingComplete, isFalse);
      });

      test('setOnboardingComplete persists true', () async {
        final svc = await _freshService();
        await svc.setOnboardingComplete();
        expect(svc.isOnboardingComplete, isTrue);
      });

      test('isOnboardingComplete reflects stored value after reinitialize',
          () async {
        final svc = await _freshService();
        await svc.setOnboardingComplete();

        // Simulate app restart: new instance re-reads same mock prefs.
        svc.resetForTest();
        await svc.initialize();
        expect(svc.isOnboardingComplete, isTrue);
      });
    });

    // ── dark mode ────────────────────────────────────────────────────────────

    group('darkMode', () {
      test('isDarkMode defaults to true', () async {
        final svc = await _freshService();
        expect(svc.isDarkMode, isTrue);
      });

      test('setDarkMode(false) persists false', () async {
        final svc = await _freshService();
        await svc.setDarkMode(false);
        expect(svc.isDarkMode, isFalse);
      });

      test('setDarkMode(true) persists true', () async {
        final svc = await _freshService();
        await svc.setDarkMode(false);
        await svc.setDarkMode(true);
        expect(svc.isDarkMode, isTrue);
      });
    });

    // ── notifications ────────────────────────────────────────────────────────

    group('notifications', () {
      test('notificationsEnabled defaults to true', () async {
        final svc = await _freshService();
        expect(svc.notificationsEnabled, isTrue);
      });

      test('setNotificationsEnabled(false) persists false', () async {
        final svc = await _freshService();
        await svc.setNotificationsEnabled(false);
        expect(svc.notificationsEnabled, isFalse);
      });

      test('setNotificationsEnabled(true) re-enables', () async {
        final svc = await _freshService();
        await svc.setNotificationsEnabled(false);
        await svc.setNotificationsEnabled(true);
        expect(svc.notificationsEnabled, isTrue);
      });
    });

    // ── biometric ────────────────────────────────────────────────────────────

    group('biometric', () {
      test('biometricEnabled defaults to false', () async {
        final svc = await _freshService();
        expect(svc.biometricEnabled, isFalse);
      });

      test('setBiometricEnabled(true) persists true', () async {
        final svc = await _freshService();
        await svc.setBiometricEnabled(true);
        expect(svc.biometricEnabled, isTrue);
      });

      test('setBiometricEnabled(false) reverts to false', () async {
        final svc = await _freshService();
        await svc.setBiometricEnabled(true);
        await svc.setBiometricEnabled(false);
        expect(svc.biometricEnabled, isFalse);
      });
    });

    // ── sobriety date ────────────────────────────────────────────────────────

    group('sobrietyDate', () {
      test('sobrietyDate defaults to null', () async {
        final svc = await _freshService();
        expect(svc.sobrietyDate, isNull);
      });

      test('setSobrietyDate stores and retrieves the date', () async {
        final svc = await _freshService();
        final date = DateTime(2023, 6, 15);
        await svc.setSobrietyDate(date);
        expect(svc.sobrietyDate, equals(date));
      });

      test('sobrietyDate preserves date precision to the millisecond',
          () async {
        final svc = await _freshService();
        final date = DateTime(2022, 1, 1, 12, 30, 45);
        await svc.setSobrietyDate(date);
        // DateTime.parse on ISO-8601 must round-trip.
        expect(svc.sobrietyDate!.year, date.year);
        expect(svc.sobrietyDate!.month, date.month);
        expect(svc.sobrietyDate!.day, date.day);
      });

      test('setting a new sobriety date overwrites the previous one', () async {
        final svc = await _freshService();
        final first = DateTime(2020, 3, 1);
        final second = DateTime(2021, 9, 10);
        await svc.setSobrietyDate(first);
        await svc.setSobrietyDate(second);
        expect(svc.sobrietyDate, equals(second));
      });
    });

    // ── program type ─────────────────────────────────────────────────────────

    group('programType', () {
      test('programType defaults to null', () async {
        final svc = await _freshService();
        expect(svc.programType, isNull);
      });

      test('setProgramType stores and retrieves the value', () async {
        final svc = await _freshService();
        await svc.setProgramType('AA');
        expect(svc.programType, equals('AA'));
      });

      test('setProgramType can be overwritten', () async {
        final svc = await _freshService();
        await svc.setProgramType('AA');
        await svc.setProgramType('NA');
        expect(svc.programType, equals('NA'));
      });
    });

    // ── AI proxy ─────────────────────────────────────────────────────────────

    group('aiProxy', () {
      test('aiProxyEnabled defaults to false', () async {
        final svc = await _freshService();
        expect(svc.aiProxyEnabled, isFalse);
      });

      test('setAiProxyEnabled(true) persists true', () async {
        final svc = await _freshService();
        await svc.setAiProxyEnabled(true);
        expect(svc.aiProxyEnabled, isTrue);
      });

      test('setAiProxyEnabled(false) reverts to false', () async {
        final svc = await _freshService();
        await svc.setAiProxyEnabled(true);
        await svc.setAiProxyEnabled(false);
        expect(svc.aiProxyEnabled, isFalse);
      });
    });

    // ── reminder times ────────────────────────────────────────────────────────

    group('reminderTimes', () {
      test('morningReminderTime defaults to 08:00', () async {
        final svc = await _freshService();
        expect(svc.morningReminderTime, equals('08:00'));
      });

      test('eveningReminderTime defaults to 20:00', () async {
        final svc = await _freshService();
        expect(svc.eveningReminderTime, equals('20:00'));
      });

      test('setMorningReminderTime persists custom time', () async {
        final svc = await _freshService();
        await svc.setMorningReminderTime('07:30');
        expect(svc.morningReminderTime, equals('07:30'));
      });

      test('setEveningReminderTime persists custom time', () async {
        final svc = await _freshService();
        await svc.setEveningReminderTime('21:15');
        expect(svc.eveningReminderTime, equals('21:15'));
      });

      test('morning and evening reminder times are independent', () async {
        final svc = await _freshService();
        await svc.setMorningReminderTime('06:45');
        await svc.setEveningReminderTime('22:00');
        expect(svc.morningReminderTime, equals('06:45'));
        expect(svc.eveningReminderTime, equals('22:00'));
      });
    });

    // ── metric counters ───────────────────────────────────────────────────────

    group('achievementShareMetrics', () {
      test('getAchievementShareTappedCount returns 0 on fresh prefs', () async {
        final svc = await _freshService();
        expect(await svc.getAchievementShareTappedCount(), equals(0));
      });

      test('getAchievementShareCompletedCount returns 0 on fresh prefs',
          () async {
        final svc = await _freshService();
        expect(await svc.getAchievementShareCompletedCount(), equals(0));
      });

      test('incrementAchievementShareTapped increments from 0 to 1', () async {
        final svc = await _freshService();
        final result = await svc.incrementAchievementShareTapped();
        expect(result, equals(1));
        expect(await svc.getAchievementShareTappedCount(), equals(1));
      });

      test('incrementAchievementShareTapped accumulates across calls', () async {
        final svc = await _freshService();
        await svc.incrementAchievementShareTapped();
        await svc.incrementAchievementShareTapped();
        final result = await svc.incrementAchievementShareTapped();
        expect(result, equals(3));
        expect(await svc.getAchievementShareTappedCount(), equals(3));
      });

      test('incrementAchievementShareCompleted increments from 0 to 1',
          () async {
        final svc = await _freshService();
        final result = await svc.incrementAchievementShareCompleted();
        expect(result, equals(1));
        expect(await svc.getAchievementShareCompletedCount(), equals(1));
      });

      test('tapped and completed counters are independent', () async {
        final svc = await _freshService();
        await svc.incrementAchievementShareTapped();
        await svc.incrementAchievementShareTapped();
        await svc.incrementAchievementShareCompleted();
        expect(await svc.getAchievementShareTappedCount(), equals(2));
        expect(await svc.getAchievementShareCompletedCount(), equals(1));
      });
    });

    // ── clear ─────────────────────────────────────────────────────────────────

    group('clear', () {
      test('clear removes all stored preferences', () async {
        final svc = await _freshService();
        await svc.setOnboardingComplete();
        await svc.setDarkMode(false);
        await svc.setBiometricEnabled(true);
        await svc.setProgramType('NA');
        await svc.setSobrietyDate(DateTime(2021, 5, 1));

        await svc.clear();

        expect(svc.isOnboardingComplete, isFalse);
        expect(svc.isDarkMode, isTrue); // back to default
        expect(svc.biometricEnabled, isFalse);
        expect(svc.programType, isNull);
        expect(svc.sobrietyDate, isNull);
      });

      test('counters reset to 0 after clear', () async {
        final svc = await _freshService();
        await svc.incrementAchievementShareTapped();
        await svc.incrementAchievementShareCompleted();

        await svc.clear();

        expect(await svc.getAchievementShareTappedCount(), equals(0));
        expect(await svc.getAchievementShareCompletedCount(), equals(0));
      });
    });

    // ── milestone celebration gate ──────────────────────────────────────────

    group('milestone celebration gate', () {
      test('hasMilestoneCelebrationShown returns false by default', () async {
        final svc = await _freshService();
        final shown = await svc.hasMilestoneCelebrationShown('milestone_7');
        expect(shown, isFalse);
      });

      test('markMilestoneCelebrationShown persists across reads', () async {
        final svc = await _freshService();
        await svc.markMilestoneCelebrationShown('milestone_7');
        expect(await svc.hasMilestoneCelebrationShown('milestone_7'), isTrue);
      });

      test('different keys are independent', () async {
        final svc = await _freshService();
        await svc.markMilestoneCelebrationShown('milestone_7');
        expect(await svc.hasMilestoneCelebrationShown('milestone_30'), isFalse);
      });
    });
  });
}
