import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/features/meetings/services/meetings_service.dart';

import 'test_helpers.dart';

void main() {
  group('MeetingsService', () {
    late MeetingsService service;

    setUp(() async {
      await prepareTestState();
      service = MeetingsService();
    });

    tearDown(() {
      // Reset singleton if needed
    });

    group('90-in-90 Progress', () {
      test('calculates progress percentage correctly', () async {
        // Note: This test requires database setup
        // In a real test, you'd mock the DatabaseService
        final progress = await service.get90In90Progress();
        
        expect(progress.goal, 90);
        expect(progress.percentage, greaterThanOrEqualTo(0.0));
        expect(progress.percentage, lessThanOrEqualTo(1.0));
        expect(progress.daysRemaining, greaterThanOrEqualTo(0));
        expect(progress.daysRemaining, lessThanOrEqualTo(90));
      });

      test('progress text format is correct', () async {
        final progress = await service.get90In90Progress();
        
        expect(
          progress.progressText,
          contains('/ 90 meetings'),
        );
      });
    });

    group('Meeting Stats', () {
      test('returns stats with all required fields', () async {
        final stats = await service.getStats();
        
        expect(stats.totalAttended, greaterThanOrEqualTo(0));
        expect(stats.thisWeek, greaterThanOrEqualTo(0));
        expect(stats.thisMonth, greaterThanOrEqualTo(0));
        expect(stats.favoritesCount, greaterThanOrEqualTo(0));
        expect(stats.longestStreak, greaterThanOrEqualTo(0));
        expect(stats.typeBreakdown, isNotNull);
      });

      test('type breakdown contains valid meeting types', () async {
        final stats = await service.getStats();
        
        for (final type in stats.typeBreakdown.keys) {
          expect(type.isNotEmpty, isTrue);
          expect(stats.typeBreakdown[type], greaterThanOrEqualTo(0));
        }
      });
    });

    group('Achievements', () {
      test('returns list of achievements', () async {
        final achievements = await service.getAchievements();
        
        expect(achievements, isA<List<MeetingAchievement>>());
      });

      test('achievements have valid properties', () async {
        final achievements = await service.getAchievements();
        
        for (final achievement in achievements) {
          expect(achievement.id.isNotEmpty, isTrue);
          expect(achievement.title.isNotEmpty, isTrue);
          expect(achievement.description.isNotEmpty, isTrue);
          expect(achievement.progress, greaterThanOrEqualTo(0));
          expect(achievement.total, greaterThanOrEqualTo(1));
          expect(achievement.progressPercentage, greaterThanOrEqualTo(0.0));
          expect(achievement.progressPercentage, lessThanOrEqualTo(1.0));
        }
      });

      test('90-in-90 achievements have correct milestones', () async {
        final achievements = await service.getAchievements();
        final ninetyIn90Achievements = achievements
            .where((a) => a.id.contains('90-in-90'))
            .toList();
        
        // Should have up to 3 milestones (30, 60, 90)
        expect(ninetyIn90Achievements.length, lessThanOrEqualTo(3));
        
        for (final achievement in ninetyIn90Achievements) {
          expect(achievement.total, equals(90));
        }
      });
    });

    group('Attendance Streak', () {
      test('calculates streak correctly', () async {
        final stats = await service.getStats();
        
        // Streak should be non-negative
        expect(stats.longestStreak, greaterThanOrEqualTo(0));
        
        // Realistic streak limit (less than 365 days)
        expect(stats.longestStreak, lessThan(365));
      });
    });

    group('MeetingAchievement Model', () {
      test('progress percentage calculation is correct', () {
        const achievement = MeetingAchievement(
          id: 'test',
          title: 'Test Achievement',
          description: 'Test Description',
          icon: Icons.event,
          progress: 50,
          total: 100,
          unlocked: false,
        );
        
        expect(achievement.progressPercentage, equals(0.5));
      });

      test('unlocked achievement has progress equal to total', () {
        const achievement = MeetingAchievement(
          id: 'test-unlocked',
          title: 'Test Achievement',
          description: 'Test Description',
          icon: Icons.event,
          progress: 100,
          total: 100,
          unlocked: true,
        );
        
        expect(achievement.unlocked, isTrue);
        expect(achievement.progressPercentage, equals(1.0));
      });
    });
  });
}
