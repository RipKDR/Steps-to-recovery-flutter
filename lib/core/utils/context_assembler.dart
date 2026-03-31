// lib/core/utils/context_assembler.dart
import '../constants/sponsor_soul.dart';
import '../models/sponsor_models.dart';

/// Aggregated signals passed into ContextAssembler.
class SponsorSignals {
  final String moodTrend; // 'improving' | 'stable' | 'declining' | 'no data'
  final String cravingVsBaseline; // 'above' | 'at' | 'below' | 'no data'
  final int checkInStreak;
  final int daysSinceJournal;
  final int daysSinceHumanContact;

  const SponsorSignals({
    required this.moodTrend,
    required this.cravingVsBaseline,
    required this.checkInStreak,
    required this.daysSinceJournal,
    required this.daysSinceHumanContact,
  });

  factory SponsorSignals.empty() => const SponsorSignals(
    moodTrend: 'no data',
    cravingVsBaseline: 'no data',
    checkInStreak: 0,
    daysSinceJournal: 0,
    daysSinceHumanContact: 0,
  );
}

/// Builds the full system prompt for a sponsor chat turn.
class ContextAssembler {
  ContextAssembler._();

  static String build({
    required SponsorIdentity identity,
    required SponsorStageData stageData,
    required int sobrietyDays,
    required List<SponsorMemory> memories,
    required SponsorSignals signals,
    required String userMessage,
    required bool isCrisis,
  }) {
    final stage = stageData.computeStage(sobrietyDays: sobrietyDays);
    final buffer = StringBuffer();

    buffer.writeln(_soulSection());
    buffer.writeln(_identitySection(identity));
    buffer.writeln(_stageSection(stage, sobrietyDays));
    buffer.writeln(_memorySection(memories));
    buffer.writeln(
      _signalsSection(sobrietyDays, signals, stageData.engagementScore),
    );
    buffer.writeln(_contractSection(identity.name, identity.vibe));
    if (isCrisis) buffer.writeln(_crisisAddendum());
    buffer.writeln('[USER MESSAGE]');
    buffer.writeln(userMessage.trim());

    return buffer.toString().trim();
  }

  static String _soulSection() =>
      '''
[SOUL DOCUMENT]
${SponsorSoul.document}
''';

  static String _identitySection(SponsorIdentity identity) {
    final vibeGuidance = switch (identity.vibe) {
      SponsorVibe.warm =>
        'nurturing, patient, draws the user out rather than directing them',
      SponsorVibe.direct =>
        'honest, efficient, no-nonsense — still caring, never cold',
      SponsorVibe.spiritual =>
        'meaning-oriented, values-based, comfortable with mystery and the unknown',
      SponsorVibe.toughLove =>
        'high-expectation, will name avoidance directly, honest even when uncomfortable',
    };
    return '''
[IDENTITY]
Your name is ${identity.name}. Respond in first person as ${identity.name} at all times.
Your vibe: $vibeGuidance.
''';
  }

  static String _stageSection(SponsorStage stage, int sobrietyDays) {
    final stageName = stage == SponsorStage.new_ ? 'New' : stage.name;
    final stageRules = switch (stage) {
      SponsorStage.new_ =>
        'Professional warmth. Max 1 nudge reference per session. Ask up to 3 gentle onboarding questions to learn about this person.',
      SponsorStage.building =>
        'Reference past conversations naturally. Begin recognizing patterns. Slightly more direct.',
      SponsorStage.trusted =>
        'Call out avoidance when you see it. Initiate on drift. Less formal — you know each other.',
      SponsorStage.close =>
        'Deep references. Push gently on growth. Summarize journey arcs when relevant.',
      SponsorStage.deep =>
        'Full journey awareness. Growth-oriented challenges. You have history together — use it.',
    };
    return '''
[RELATIONSHIP STAGE]
Day $sobrietyDays of the user's journey. Stage: $stageName.
$stageRules
''';
  }

  static String _memorySection(List<SponsorMemory> memories) {
    if (memories.isEmpty) {
      return '[MEMORY]\nNo long-term memories yet. This is an early conversation.\n';
    }
    final lines = memories
        .take(8)
        .map((m) {
          final cat = m.category.name
              .replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(0)}',
              )
              .trim();
          return '- $cat: ${m.summary}';
        })
        .join('\n');
    return '''
[MEMORY]
What you know about this person (never reference raw journal text):
$lines
''';
  }

  static String _signalsSection(
    int sobrietyDays,
    SponsorSignals signals,
    int engagementScore,
  ) =>
      '''
[SIGNALS]
- Sobriety days: $sobrietyDays
- Mood trend (last 7 days): ${signals.moodTrend}
- Craving vs personal baseline: ${signals.cravingVsBaseline}
- Check-in streak: ${signals.checkInStreak} days
- Days since last journal: ${signals.daysSinceJournal}
- Days since last human contact: ${signals.daysSinceHumanContact}
- Engagement score: $engagementScore
''';

  static String _contractSection(String name, SponsorVibe vibe) =>
      '''
[RESPONSE CONTRACT]
- Respond as $name, first person, never break character
- Never say "As an AI" or anything that breaks the sponsor persona
- Do not diagnose, prescribe, or claim clinical authority
- Max 200 words unless the user is in clear distress
- End with a question or opening — not a closing statement
''';

  static String _crisisAddendum() => '''
[CRISIS MODE ACTIVE]
Shift immediately. Be direct, grounded, present.
Acknowledge the pain first. Then: one concrete next step.
Always include: "988 is there right now if you need it."
Do not give lists. Do not minimize. Stay with them.
''';
}
