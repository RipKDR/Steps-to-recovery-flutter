// test/context_assembler_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/utils/context_assembler.dart';

void main() {
  group('ContextAssembler', () {
    final identity = SponsorIdentity(
      name: 'Rex',
      vibe: SponsorVibe.warm,
      createdAt: DateTime(2026, 3, 1),
    );
    final stageData = SponsorStageData(
      stage: SponsorStage.building,
      engagementScore: 20,
      lastInteraction: DateTime(2026, 3, 22),
    );

    test('prompt contains sponsor name', () {
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'Hello',
        isCrisis: false,
      );
      expect(prompt, contains('Rex'));
    });

    test('prompt contains stage name', () {
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'Hello',
        isCrisis: false,
      );
      expect(prompt.toLowerCase(), contains('building'));
    });

    test('prompt contains sobriety days', () {
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'Hello',
        isCrisis: false,
      );
      expect(prompt, contains('34'));
    });

    test('prompt contains crisis addendum when isCrisis is true', () {
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'I want to die',
        isCrisis: true,
      );
      expect(prompt, contains('CRISIS MODE'));
      expect(prompt, contains('988'));
    });

    test('prompt does not contain crisis addendum when isCrisis is false', () {
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'Good morning',
        isCrisis: false,
      );
      expect(prompt, isNot(contains('CRISIS MODE')));
    });

    test('prompt contains memory summary when memories provided', () {
      final memories = [
        SponsorMemory(
          id: 'id1',
          category: MemoryCategory.recoveryPattern,
          summary: 'Sunday evenings are hard.',
          createdAt: DateTime.now(),
        ),
      ];
      final prompt = ContextAssembler.build(
        identity: identity,
        stageData: stageData,
        sobrietyDays: 34,
        memories: memories,
        signals: SponsorSignals.empty(),
        userMessage: 'Hello',
        isCrisis: false,
      );
      expect(prompt, contains('Sunday evenings are hard.'));
    });

    test('warm vibe guidance appears in prompt', () {
      final prompt = ContextAssembler.build(
        identity: identity, // warm vibe
        stageData: stageData,
        sobrietyDays: 34,
        memories: [],
        signals: SponsorSignals.empty(),
        userMessage: 'Hello',
        isCrisis: false,
      );
      expect(prompt.toLowerCase(), contains('nurturing'));
    });
  });
}
