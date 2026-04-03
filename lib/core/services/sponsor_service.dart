// lib/core/services/sponsor_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/crisis_constants.dart';
import '../constants/sponsor_soul.dart';
import '../models/database_models.dart';
export '../models/database_models.dart' show ChatMessage;
import '../models/sponsor_models.dart';
import '../services/app_state_service.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/logger_service.dart';
import '../services/sponsor_memory_store.dart';
import '../utils/context_assembler.dart';
import '../../app_config.dart';

/// Abstract interface for testing SponsorChatScreen in isolation.
abstract class SponsorResponder {
  SponsorIdentity? get identity;
  bool get hasIdentity;
  SponsorStage get stage;
  bool get isCloudAvailable;
  List<SponsorMemory> get longTermMemory;
  
  // Badge system (Phase 7)
  bool get hasPendingMessage;
  String? get pendingMessagePreview;
  void clearPendingMessage();
  
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
    bool? isOnline,
  });
  Future<void> digestSession();
  Future<void> bumpEngagement({int checkInDays, int chatDays, int journalDays});
  Future<void> addSessionMemory(SponsorMemory memory);
  
  // Feature hooks (Phase 7)
  Future<void> onCheckInCompleted({required int mood, required int craving});
  Future<void> onJournalSaved({required int wordCount});
  Future<void> onMilestoneReached(int days);
  Future<void> onChallengeCompleted(String challengeName);
  Future<void> onReturnFromSilence(int daysSilent);
  
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

class SponsorService extends ChangeNotifier implements SponsorResponder {
  SponsorService._internal();
  static final SponsorService instance = SponsorService._internal();

  /// Test constructor — creates a fresh instance not shared as singleton.
  @visibleForTesting
  static SponsorService createForTest() => SponsorService._internal();

  static const String _identityKey = 'sponsor_identity';
  static const String _stageKey = 'sponsor_stage';

  SponsorIdentity? _identity;
  SponsorStageData _stageData = SponsorStageData(
    stage: SponsorStage.new_,
    engagementScore: 0,
    lastInteraction: DateTime.fromMillisecondsSinceEpoch(0),
  );
  final SponsorMemoryStore _memoryStore = SponsorMemoryStore();
  bool _initialized = false;

  // ── Badge system (Phase 7: Nervous System) ────────────────────────────────
  bool _hasPendingMessage = false;
  String? _pendingMessagePreview;

  @override
  bool get hasPendingMessage => _hasPendingMessage;

  @override
  String? get pendingMessagePreview => _pendingMessagePreview;

  @override
  void clearPendingMessage() {
    _hasPendingMessage = false;
    _pendingMessagePreview = null;
    notifyListeners();
  }

  void _setPendingMessage(String preview) {
    _hasPendingMessage = true;
    _pendingMessagePreview = preview;
    notifyListeners();
  }

  // ── Public getters ────────────────────────────────────────────────────────

  @override
  SponsorIdentity? get identity => _identity;
  @override
  bool get hasIdentity => _identity != null;

  @override
  SponsorStage get stage => _stageData.stage;
  int get engagementScore => _stageData.engagementScore;

  List<SponsorMemory> get sessionMemory => _memoryStore.session;
  List<SponsorMemory> get digestMemory => _memoryStore.digest;
  @override
  List<SponsorMemory> get longTermMemory => _memoryStore.longterm;

  @override
  bool get isCloudAvailable => ConnectivityService().isConnected;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _memoryStore.initialize();
    await _loadIdentity();
    await _loadStage();
  }

  // ── Identity ──────────────────────────────────────────────────────────────

  Future<void> setupIdentity(String name, SponsorVibe vibe) async {
    _identity = SponsorIdentity(
      name: name.trim(),
      vibe: vibe,
      createdAt: DateTime.now(),
    );
    await _saveIdentity();
    notifyListeners();
  }

  // ── Memory ────────────────────────────────────────────────────────────────

  @override
  Future<void> addSessionMemory(SponsorMemory memory) async {
    await _memoryStore.addToSession(memory);
    notifyListeners();
  }

  @override
  Future<void> digestSession() async {
    await _memoryStore.digestSession();
    notifyListeners();
  }

  Future<void> distillToLongTerm() async {
    await _memoryStore.distillToLongTerm();
    notifyListeners();
  }

  Future<void> deleteMemory(String id) async {
    await _memoryStore.deleteMemory(id);
    notifyListeners();
  }

  // ── Relationship ──────────────────────────────────────────────────────────

  @override
  Future<void> bumpEngagement({
    int checkInDays = 0,
    int chatDays = 0,
    int journalDays = 0,
  }) async {
    final delta = (checkInDays * 2) + (chatDays * 3) + (journalDays * 1);
    if (delta == 0) return;
    final newScore = _stageData.engagementScore + delta;
    final now = DateTime.now();
    final sobrietyDays = AppStateService.instance.sobrietyDays;
    final newStage = _stageData
        .copyWith(engagementScore: newScore, lastInteraction: now)
        .computeStage(sobrietyDays: sobrietyDays);
    _stageData = SponsorStageData(
      stage: newStage,
      engagementScore: newScore,
      lastInteraction: now,
    );
    await _saveStage();
    notifyListeners();
  }

  Future<void> recalculateEngagement() async {
    // Resets score to 0 and re-bumps — caller supplies actuals from DatabaseService
    _stageData = SponsorStageData(
      stage: SponsorStage.new_,
      engagementScore: 0,
      lastInteraction: DateTime.now(),
    );
    await _saveStage();
    notifyListeners();
  }

  // ── Feature Hooks (Phase 7: Nervous System) ───────────────────────────────

  /// Call after morning or evening check-in is saved.
  @override
  Future<void> onCheckInCompleted({required int mood, required int craving}) async {
    await bumpEngagement(checkInDays: 1);
    // High craving or very low mood — sponsor notices
    if (craving >= 8 || mood == 1) {
      final name = _identity?.name ?? 'Your sponsor';
      _setPendingMessage('$name noticed your check-in. They\'re here.');
    }
  }

  /// Call after a journal entry is saved.
  @override
  Future<void> onJournalSaved({required int wordCount}) async {
    await bumpEngagement(journalDays: 1);
    // Returning after long silence
    final signals = await _buildSignals();
    if (signals.daysSinceJournal >= 5) {
      final name = _identity?.name ?? 'Your sponsor';
      _setPendingMessage('$name noticed you journaled. Good to see you back.');
    }
  }

  /// Call when a time milestone is reached. Always generates a message.
  @override
  Future<void> onMilestoneReached(int days) async {
    final name = _identity?.name ?? 'Your sponsor';
    _setPendingMessage('$name has something to say about $days days. Open when ready.');
  }

  /// Call after a challenge is marked complete.
  @override
  Future<void> onChallengeCompleted(String challengeName) async {
    final name = _identity?.name ?? 'Your sponsor';
    _setPendingMessage('$name saw you finish "$challengeName". That matters.');
  }

  /// Call on app resume if last sponsor interaction was >3 days ago.
  @override
  Future<void> onReturnFromSilence(int daysSilent) async {
    if (daysSilent <= 3) return;
    final name = _identity?.name ?? 'Your sponsor';
    _setPendingMessage('$name hasn\'t heard from you in $daysSilent days. No pressure.');
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  /// [isOnline] is injectable for testing. Defaults to ConnectivityService.
  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
    bool? isOnline,
  }) async {
    final online = isOnline ?? ConnectivityService().isConnected;
    final isCrisis = CrisisConstants.detect(message);

    if (!online) {
      return _offlineResponse(isCrisis);
    }

    if (_identity == null) {
      return _genericFallbackResponse(message);
    }

    // Build signals from real behavioral data
    final signals = await _buildSignals();

    final systemPrompt = ContextAssembler.build(
      identity: _identity!,
      stageData: _stageData,
      sobrietyDays: AppStateService.instance.sobrietyDays,
      memories: [..._memoryStore.longterm, ..._memoryStore.digest],
      signals: signals,
      userMessage: message,
      isCrisis: isCrisis,
    );

    return await _callEdgeFunction(
      systemPrompt: systemPrompt,
      message: message,
      conversationHistory: conversationHistory,
    );
  }

  // ── Signal Building (Phase 7: Nervous System) ────────────────────────────

  /// Builds real behavioral signals from DatabaseService.
  Future<SponsorSignals> _buildSignals() async {
    try {
      final db = DatabaseService();
      final userId = AppStateService.instance.currentUserId;
      if (userId == null) return SponsorSignals.empty();

      // Last 14 check-ins for trend analysis
      final checkIns = await db.getCheckIns(userId: userId, limit: 14);
      final journals = await db.getJournalEntries(limit: 1);

      // Mood trend: compare avg of last 7 vs prior 7
      final moodTrend = _computeMoodTrend(checkIns);

      // Craving vs baseline: same logic
      final cravingVsBaseline = _computeCravingTrend(checkIns);

      // Check-in streak: consecutive days ending today
      final checkInStreak = _computeStreak(checkIns);

      // Days since last journal
      final daysSinceJournal = journals.isEmpty
          ? 0
          : DateTime.now().difference(journals.first.updatedAt).inDays;

      // Days since last sponsor chat (proxy: last interaction timestamp)
      final daysSinceHumanContact =
          DateTime.now().difference(_stageData.lastInteraction).inDays;

      return SponsorSignals(
        moodTrend: moodTrend,
        cravingVsBaseline: cravingVsBaseline,
        checkInStreak: checkInStreak,
        daysSinceJournal: daysSinceJournal,
        daysSinceHumanContact: daysSinceHumanContact,
      );
    } catch (e, st) {
      LoggerService().error('_buildSignals failed', error: e, stackTrace: st);
      return SponsorSignals.empty();
    }
  }

  String _computeMoodTrend(List<DailyCheckIn> checkIns) {
    final moods = checkIns
        .where((c) => c.mood != null)
        .map((c) => c.mood!)
        .toList();
    if (moods.length < 4) return 'no data';
    final half = moods.length ~/ 2;
    final recent = moods.take(half).fold(0, (a, b) => a + b) / half;
    final prior = moods.skip(half).fold(0, (a, b) => a + b) / (moods.length - half);
    if (recent > prior + 0.5) return 'improving';
    if (recent < prior - 0.5) return 'declining';
    return 'stable';
  }

  String _computeCravingTrend(List<DailyCheckIn> checkIns) {
    final cravings = checkIns
        .where((c) => c.craving != null)
        .map((c) => c.craving!)
        .toList();
    if (cravings.length < 4) return 'no data';
    final half = cravings.length ~/ 2;
    final recent = cravings.take(half).fold(0, (a, b) => a + b) / half;
    final prior = cravings.skip(half).fold(0, (a, b) => a + b) / (cravings.length - half);
    if (recent > prior + 1.0) return 'above';
    if (recent < prior - 1.0) return 'below';
    return 'at';
  }

  int _computeStreak(List<DailyCheckIn> checkIns) {
    if (checkIns.isEmpty) return 0;
    final sorted = checkIns.toList()
      ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
    int streak = 0;
    DateTime expected = DateTime.now();
    for (final c in sorted) {
      final diff = expected.difference(c.checkInDate).inDays;
      if (diff <= 1) {
        streak++;
        expected = c.checkInDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Test-visible wrapper for _buildSignals.
  @visibleForTesting
  Future<SponsorSignals> buildSignalsForTest() => _buildSignals();

  // ── Private ───────────────────────────────────────────────────────────────

  String _offlineResponse(bool isCrisis) {
    final opener = SponsorSoul.offlineOpeners[
      Random().nextInt(SponsorSoul.offlineOpeners.length)
    ];
    if (isCrisis) {
      return "$opener\n\nIf you're in crisis right now — 988 is there. Real people, right now.";
    }
    final relevantMemories = _memoryStore.longterm
        .where((m) => m.category == MemoryCategory.whatWorks)
        .take(1)
        .toList();
    if (relevantMemories.isNotEmpty) {
      return "$opener\n\nLast time we talked about this, you mentioned: '${relevantMemories.first.summary}'. Still true?";
    }
    return opener;
  }

  String _genericFallbackResponse(String message) =>
      "I'm here for you. Tell me more about how you're feeling.";

  Future<String> _callEdgeFunction({
    required String systemPrompt,
    required String message,
    List<ChatMessage>? conversationHistory,
  }) async {
    final edgeFunctionUrl = AppConfig.aiChatEdgeFunctionUrl;
    if (edgeFunctionUrl.isEmpty) {
      return _genericFallbackResponse(message);
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    } catch (e, stackTrace) {
      LoggerService().error('Failed to get auth token for sponsor chat', error: e, stackTrace: stackTrace);
    }

    final history = conversationHistory
        ?.map((m) => {'role': m.isUser ? 'User' : 'Assistant', 'content': m.content})
        .toList() ?? [];

    try {
      final response = await http.post(
        Uri.parse(edgeFunctionUrl),
        headers: headers,
        body: jsonEncode({
          'message': message.trim(),
          'systemPrompt': systemPrompt,
          'conversationHistory': history,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] as String? ??
            "I'm here for you. Tell me more about how you're feeling.";
      }
    } catch (e, stackTrace) {
      LoggerService().error('SponsorService edge function error', error: e, stackTrace: stackTrace);
    }
    return "I'm having trouble connecting right now. I'm still here for you when I'm back.";
  }

  Future<void> _loadIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_identityKey);
    if (raw == null) return;
    try {
      final decrypted = EncryptionService().decrypt(raw);
      _identity = SponsorIdentity.fromJsonString(decrypted);
    } catch (e, stackTrace) {
      LoggerService().error('Failed to load sponsor identity', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _saveIdentity() async {
    if (_identity == null) return;
    final prefs = await SharedPreferences.getInstance();
    final encrypted = EncryptionService().encrypt(_identity!.toJsonString());
    await prefs.setString(_identityKey, encrypted);
  }

  Future<void> _loadStage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stageKey);
    if (raw == null) return;
    try {
      final decrypted = EncryptionService().decrypt(raw);
      _stageData = SponsorStageData.fromJsonString(decrypted);
    } catch (e, stackTrace) {
      LoggerService().error('Failed to load sponsor stage data', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _saveStage() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = EncryptionService().encrypt(_stageData.toJsonString());
    await prefs.setString(_stageKey, encrypted);
  }

  /// Test-only — allows tests to set badge state directly.
  @visibleForTesting
  void setTestPendingMessage(String preview) {
    _hasPendingMessage = true;
    _pendingMessagePreview = preview;
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
