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
  });
}
