// test/sponsor_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';

void main() {
  group('SponsorIdentity', () {
    test('toJson / fromJson roundtrip', () {
      final identity = SponsorIdentity(
        name: 'Rex',
        vibe: SponsorVibe.warm,
        createdAt: DateTime(2026, 3, 22),
      );
      final json = identity.toJson();
      final restored = SponsorIdentity.fromJson(json);
      expect(restored.name, 'Rex');
      expect(restored.vibe, SponsorVibe.warm);
      expect(restored.createdAt, DateTime(2026, 3, 22));
    });

    test('equality works correctly', () {
      final a = SponsorIdentity(
        name: 'Rex',
        vibe: SponsorVibe.warm,
        createdAt: DateTime(2026, 3, 22),
      );
      final b = SponsorIdentity(
        name: 'Rex',
        vibe: SponsorVibe.warm,
        createdAt: DateTime(2026, 3, 22),
      );
      expect(a, equals(b));
    });
  });

  group('SponsorStageData', () {
    test('toJson / fromJson roundtrip', () {
      final data = SponsorStageData(
        stage: SponsorStage.building,
        engagementScore: 25,
        lastInteraction: DateTime(2026, 3, 22),
      );
      final json = data.toJson();
      final restored = SponsorStageData.fromJson(json);
      expect(restored.stage, SponsorStage.building);
      expect(restored.engagementScore, 25);
    });

    test('computeStage returns new_ for score 0 and 0 sobriety days', () {
      final data = SponsorStageData(
        stage: SponsorStage.new_,
        engagementScore: 0,
        lastInteraction: DateTime.now(),
      );
      expect(data.computeStage(sobrietyDays: 0), SponsorStage.new_);
    });

    test('computeStage returns building for score 20', () {
      final data = SponsorStageData(
        stage: SponsorStage.new_,
        engagementScore: 20,
        lastInteraction: DateTime.now(),
      );
      expect(data.computeStage(sobrietyDays: 0), SponsorStage.building);
    });

    test('computeStage uses higher of score-based or days-based', () {
      final data = SponsorStageData(
        stage: SponsorStage.new_,
        engagementScore: 5, // score says new_
        lastInteraction: DateTime.now(),
      );
      // 15 sobriety days → building (days-based wins)
      expect(data.computeStage(sobrietyDays: 15), SponsorStage.building);
    });

    test('stage never goes backward', () {
      final data = SponsorStageData(
        stage: SponsorStage.trusted, // already trusted
        engagementScore: 5,          // score says new_
        lastInteraction: DateTime.now(),
      );
      // computeStage should not go below current stage
      expect(
        data.computeStage(sobrietyDays: 0).index,
        greaterThanOrEqualTo(SponsorStage.trusted.index),
      );
    });

    test('sobriety days mapping works correctly', () {
      final data = SponsorStageData(
        stage: SponsorStage.new_,
        engagementScore: 0,
        lastInteraction: DateTime.now(),
      );
      
      expect(data.computeStage(sobrietyDays: 7), SponsorStage.new_);
      expect(data.computeStage(sobrietyDays: 8), SponsorStage.building);
      expect(data.computeStage(sobrietyDays: 31), SponsorStage.trusted);
      expect(data.computeStage(sobrietyDays: 91), SponsorStage.close);
      expect(data.computeStage(sobrietyDays: 365), SponsorStage.deep);
    });
  });

  group('SponsorMemory', () {
    test('toJson / fromJson roundtrip', () {
      final memory = SponsorMemory(
        id: 'abc123',
        category: MemoryCategory.recoveryPattern,
        summary: 'Sunday evenings are hard.',
        createdAt: DateTime(2026, 3, 22),
      );
      final json = memory.toJson();
      final restored = SponsorMemory.fromJson(json);
      expect(restored.id, 'abc123');
      expect(restored.category, MemoryCategory.recoveryPattern);
      expect(restored.summary, 'Sunday evenings are hard.');
      expect(restored.distilledAt, isNull);
    });

    test('summary is truncated to 500 chars on construction', () {
      final long = 'x' * 600;
      final memory = SponsorMemory(
        id: 'id',
        category: MemoryCategory.lifeContext,
        summary: long,
        createdAt: DateTime.now(),
      );
      expect(memory.summary.length, lessThanOrEqualTo(500));
    });

    test('distilledAt is preserved when set', () {
      final distilledDate = DateTime(2026, 4, 1);
      final memory = SponsorMemory(
        id: 'id',
        category: MemoryCategory.whatWorks,
        summary: 'Test',
        createdAt: DateTime(2026, 3, 22),
        distilledAt: distilledDate,
      );
      expect(memory.distilledAt, distilledDate);
    });
  });

  group('SponsorMemoryFile', () {
    test('empty factory creates empty lists', () {
      final file = SponsorMemoryFile.empty();
      expect(file.session, isEmpty);
      expect(file.digest, isEmpty);
      expect(file.longterm, isEmpty);
    });

    test('toJson / fromJson roundtrip', () {
      final file = SponsorMemoryFile(
        session: [
          SponsorMemory(
            id: 's1',
            category: MemoryCategory.lifeContext,
            summary: 'Session memory',
            createdAt: DateTime.now(),
          ),
        ],
        digest: [
          SponsorMemory(
            id: 'd1',
            category: MemoryCategory.recoveryPattern,
            summary: 'Digest memory',
            createdAt: DateTime.now(),
          ),
        ],
        longterm: [
          SponsorMemory(
            id: 'l1',
            category: MemoryCategory.whatWorks,
            summary: 'Longterm memory',
            createdAt: DateTime.now(),
          ),
        ],
      );
      
      final json = file.toJson();
      final restored = SponsorMemoryFile.fromJson(json);
      
      expect(restored.session.length, 1);
      expect(restored.digest.length, 1);
      expect(restored.longterm.length, 1);
      expect(restored.session.first.summary, 'Session memory');
    });

    test('copyWith works correctly', () {
      final file = SponsorMemoryFile.empty();
      final newMemory = SponsorMemory(
        id: 'new',
        category: MemoryCategory.hardMoment,
        summary: 'New memory',
        createdAt: DateTime.now(),
      );
      
      final updated = file.copyWith(session: [newMemory]);
      
      expect(updated.session.length, 1);
      expect(updated.digest, isEmpty);
      expect(updated.longterm, isEmpty);
    });
  });
}
