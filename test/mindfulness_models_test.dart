// test/mindfulness_models_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/features/mindfulness/models/mindfulness_models.dart';

void main() {
  group('MindfulnessTrack', () {
    test('creates with required properties', () {
      final track = const MindfulnessTrack(
        id: 'breathing-101',
        title: 'Deep Breathing',
        description: 'A calming breathing exercise',
        category: 'breathing',
        duration: Duration(minutes: 5),
        audioUrl: 'https://example.com/audio.mp3',
      );

      expect(track.id, 'breathing-101');
      expect(track.title, 'Deep Breathing');
      expect(track.description, 'A calming breathing exercise');
      expect(track.category, 'breathing');
      expect(track.duration, const Duration(minutes: 5));
      expect(track.audioUrl, 'https://example.com/audio.mp3');
      expect(track.localAssetPath, isNull);
      expect(track.mindfulnessCategory, MindfulnessCategory.breathing);
      expect(track.isPremium, false);
    });

    test('creates with optional properties', () {
      final track = const MindfulnessTrack(
        id: 'sleep-101',
        title: 'Sleep Meditation',
        description: 'Drift into sleep',
        category: 'sleep',
        duration: Duration(minutes: 20),
        audioUrl: 'https://example.com/sleep.mp3',
        localAssetPath: 'assets/audio/sleep.mp3',
        mindfulnessCategory: MindfulnessCategory.sleep,
        isPremium: true,
      );

      expect(track.localAssetPath, 'assets/audio/sleep.mp3');
      expect(track.mindfulnessCategory, MindfulnessCategory.sleep);
      expect(track.isPremium, true);
    });

    group('durationFormatted', () {
      test('formats 3 minutes 30 seconds as 3:30', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'breathing',
          duration: Duration(minutes: 3, seconds: 30),
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '3:30');
      });

      test('formats 5 minutes as 5:00', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'breathing',
          duration: Duration(minutes: 5),
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '5:00');
      });

      test('formats 10 minutes 45 seconds as 10:45', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'body_scan',
          duration: Duration(minutes: 10, seconds: 45),
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '10:45');
      });

      test('formats 1 hour as 60:00', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'sleep',
          duration: Duration(hours: 1),
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '60:00');
      });

      test('formats 0 seconds as 0:00', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'breathing',
          duration: Duration.zero,
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '0:00');
      });

      test('pads single digit seconds with zero', () {
        final track = const MindfulnessTrack(
          id: 'test',
          title: 'Test',
          description: 'Test track',
          category: 'breathing',
          duration: Duration(minutes: 2, seconds: 5),
          audioUrl: 'https://example.com/test.mp3',
        );

        expect(track.durationFormatted, '2:05');
      });
    });
  });

  group('MindfulnessCategory', () {
    test('has correct number of values', () {
      expect(MindfulnessCategory.values.length, 8);
    });

    test('breathing has correct display name and icon', () {
      expect(MindfulnessCategory.breathing.displayName, 'Breathing');
      expect(MindfulnessCategory.breathing.icon, Icons.air);
    });

    test('bodyScan has correct display name and icon', () {
      expect(MindfulnessCategory.bodyScan.displayName, 'Body Scan');
      expect(MindfulnessCategory.bodyScan.icon, Icons.accessibility_new);
    });

    test('visualization has correct display name and icon', () {
      expect(MindfulnessCategory.visualization.displayName, 'Visualization');
      expect(MindfulnessCategory.visualization.icon, Icons.image);
    });

    test('grounding has correct display name and icon', () {
      expect(MindfulnessCategory.grounding.displayName, 'Grounding');
      expect(MindfulnessCategory.grounding.icon, Icons.landscape);
    });

    test('lovingKindness has correct display name and icon', () {
      expect(MindfulnessCategory.lovingKindness.displayName, 'Loving-Kindness');
      expect(MindfulnessCategory.lovingKindness.icon, Icons.favorite);
    });

    test('sleep has correct display name and icon', () {
      expect(MindfulnessCategory.sleep.displayName, 'Sleep');
      expect(MindfulnessCategory.sleep.icon, Icons.bedtime);
    });

    test('anxiety has correct display name and icon', () {
      expect(MindfulnessCategory.anxiety.displayName, 'Anxiety Relief');
      expect(MindfulnessCategory.anxiety.icon, Icons.healing);
    });

    test('craving has correct display name and icon', () {
      expect(MindfulnessCategory.craving.displayName, 'Craving Surfing');
      expect(MindfulnessCategory.craving.icon, Icons.waves);
    });

    test('all categories have IconData icons', () {
      for (final category in MindfulnessCategory.values) {
        expect(category.icon, isA<IconData>());
        expect(category.getIcon(), isA<IconData>());
      }
    });

    test('getIcon returns the same as icon property', () {
      for (final category in MindfulnessCategory.values) {
        expect(category.getIcon(), category.icon);
      }
    });
  });

  group('MindfulnessProgress', () {
    test('creates with required properties and defaults', () {
      final now = DateTime(2026, 4, 2);
      final progress = MindfulnessProgress(
        trackId: 'track-123',
        userId: 'user-456',
        lastPlayedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(progress.trackId, 'track-123');
      expect(progress.userId, 'user-456');
      expect(progress.timesCompleted, 0);
      expect(progress.totalListenTime, Duration.zero);
      expect(progress.lastPlayedAt, now);
      expect(progress.createdAt, now);
      expect(progress.updatedAt, now);
    });

    test('creates with custom values', () {
      final now = DateTime(2026, 4, 2);
      final progress = MindfulnessProgress(
        trackId: 'track-123',
        userId: 'user-456',
        timesCompleted: 5,
        totalListenTime: const Duration(minutes: 30),
        lastPlayedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(progress.timesCompleted, 5);
      expect(progress.totalListenTime, const Duration(minutes: 30));
    });

    group('copyWith', () {
      final now = DateTime(2026, 4, 2);
      final later = DateTime(2026, 4, 3);
      
      test('returns same values when no parameters provided', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          timesCompleted: 3,
          totalListenTime: const Duration(minutes: 15),
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith();

        expect(copy.trackId, progress.trackId);
        expect(copy.userId, progress.userId);
        expect(copy.timesCompleted, progress.timesCompleted);
        expect(copy.totalListenTime, progress.totalListenTime);
        expect(copy.lastPlayedAt, progress.lastPlayedAt);
        expect(copy.createdAt, progress.createdAt);
        expect(copy.updatedAt, progress.updatedAt);
      });

      test('updates trackId', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(trackId: 'track-789');

        expect(copy.trackId, 'track-789');
        expect(copy.userId, progress.userId);
        expect(copy.timesCompleted, progress.timesCompleted);
      });

      test('updates userId', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(userId: 'user-789');

        expect(copy.userId, 'user-789');
        expect(copy.trackId, progress.trackId);
      });

      test('updates timesCompleted', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          timesCompleted: 2,
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(timesCompleted: 10);

        expect(copy.timesCompleted, 10);
      });

      test('updates totalListenTime', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          totalListenTime: const Duration(minutes: 10),
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(
          totalListenTime: const Duration(minutes: 25),
        );

        expect(copy.totalListenTime, const Duration(minutes: 25));
      });

      test('updates lastPlayedAt', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(lastPlayedAt: later);

        expect(copy.lastPlayedAt, later);
      });

      test('updates createdAt', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(createdAt: later);

        expect(copy.createdAt, later);
      });

      test('updates updatedAt', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(updatedAt: later);

        expect(copy.updatedAt, later);
      });

      test('can update multiple fields at once', () {
        final progress = MindfulnessProgress(
          trackId: 'track-123',
          userId: 'user-456',
          timesCompleted: 1,
          totalListenTime: const Duration(minutes: 5),
          lastPlayedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final copy = progress.copyWith(
          timesCompleted: 5,
          totalListenTime: const Duration(minutes: 30),
          updatedAt: later,
        );

        expect(copy.timesCompleted, 5);
        expect(copy.totalListenTime, const Duration(minutes: 30));
        expect(copy.updatedAt, later);
        expect(copy.trackId, progress.trackId);
        expect(copy.userId, progress.userId);
        expect(copy.lastPlayedAt, progress.lastPlayedAt);
        expect(copy.createdAt, progress.createdAt);
      });
    });
  });
}
