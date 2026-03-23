// lib/core/constants/crisis_constants.dart

/// Shared crisis keyword detection. Used by AiService and SponsorService.
class CrisisConstants {
  CrisisConstants._();

  static const List<String> keywords = [
    'suicide', 'kill myself', 'end it all', 'give up',
    "can't go on", 'want to die', 'use again', 'relapse',
    'overdose', 'hurt myself', 'self harm',
  ];

  /// Returns true if [message] contains any crisis keyword (case-insensitive).
  static bool detect(String message) {
    final lower = message.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }
}
