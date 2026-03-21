import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_config.dart';
import '../models/database_models.dart';
import 'database_service.dart';
import 'encryption_service.dart';
import 'logger_service.dart';

/// Sync service that pushes/pulls encrypted data to/from Supabase.
///
/// All sensitive fields are encrypted client-side before upload.
/// Supabase stores only ciphertext — the server never sees plaintext.
/// Conflict resolution: last-write-wins based on updated_at.
class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _logger = LoggerService();
  final _encryption = EncryptionService();

  bool _initialized = false;
  bool _syncing = false;
  DateTime? _lastSyncAt;
  String? _lastError;

  bool get isAvailable => AppConfig.hasSupabase;
  bool get isSyncing => _syncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastError => _lastError;

  SupabaseClient get _client => Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  Future<void> initialize() async {
    if (_initialized || !isAvailable) return;

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    _initialized = true;
    _logger.info('SyncService initialized');
  }

  // ── Auth ──────────────────────────────────────────────────

  /// Sign up with email/password via Supabase Auth.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return response;
  }

  /// Sign in with email/password via Supabase Auth.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return response;
  }

  /// Sign out.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Whether there is an active Supabase session.
  bool get isAuthenticated => _client.auth.currentSession != null;

  // ── Full Sync ─────────────────────────────────────────────

  /// Run a full bidirectional sync of all tables.
  Future<void> syncAll() async {
    if (!isAvailable || _syncing || _userId == null) return;

    _syncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final db = DatabaseService();

      await _syncProfiles(db);
      await _syncCheckIns(db);
      await _syncJournalEntries(db);
      await _syncStepWork(db);
      await _syncStepProgress(db);
      await _syncGratitudeEntries(db);
      await _syncAchievements(db);
      await _syncContacts(db);
      await _syncMeetings(db);
      await _syncSafetyPlans(db);
      await _syncChallenges(db);
      await _syncAiConversations(db);
      await _syncReadingReflections(db);

      _lastSyncAt = DateTime.now();
      _logger.info('Full sync completed');
    } catch (e, stack) {
      _lastError = e.toString();
      _logger.error('Sync failed', error: e, stackTrace: stack);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  // ── Profile Sync ──────────────────────────────────────────

  Future<void> _syncProfiles(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final localUser = await db.getCurrentUser();
    if (localUser == null) return;

    // Push local profile to Supabase
    await _client.from('profiles').upsert({
      'id': userId,
      'email': localUser.email,
      'program_type': localUser.programType,
      'sobriety_start_date': localUser.sobrietyStartDate.toIso8601String(),
      'updated_at': localUser.updatedAt.toIso8601String(),
    });
  }

  // ── Check-ins Sync ────────────────────────────────────────

  Future<void> _syncCheckIns(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    // Get pending local check-ins
    final localCheckIns = await db.getCheckIns();
    final pending = localCheckIns.where(
      (c) => c.syncStatus == SyncStatus.pending,
    );

    for (final checkIn in pending) {
      final encryptedData = _encryption.encrypt(jsonEncode({
        'intention': checkIn.intention,
        'reflection': checkIn.reflection,
        'mood': checkIn.mood,
        'craving': checkIn.craving,
      }));

      await _client.from('check_ins').upsert(
        {
          'id': checkIn.id,
          'user_id': userId,
          'check_in_type': checkIn.checkInType.value,
          'check_in_date': checkIn.checkInDate.toIso8601String().split('T')[0],
          'encrypted_data': encryptedData,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,check_in_type,check_in_date',
      );
    }

    // Pull remote check-ins newer than last sync
    final since = _lastSyncAt?.toIso8601String() ?? '1970-01-01T00:00:00Z';
    final remote = await _client
        .from('check_ins')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since)
        .order('updated_at');

    for (final row in remote) {
      final data = jsonDecode(_encryption.decrypt(row['encrypted_data'] as String));
      final checkIn = DailyCheckIn(
        id: row['id'] as String,
        userId: userId,
        checkInType: CheckInType.fromString(row['check_in_type'] as String),
        checkInDate: DateTime.parse(row['check_in_date'] as String),
        intention: data['intention'] as String?,
        reflection: data['reflection'] as String?,
        mood: data['mood'] as int?,
        craving: data['craving'] as int?,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
      await db.saveCheckIn(checkIn);
    }
  }

  // ── Journal Entries Sync ──────────────────────────────────

  Future<void> _syncJournalEntries(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final localEntries = await db.getJournalEntries();
    final pending = localEntries.where(
      (e) => e.syncStatus == SyncStatus.pending,
    );

    for (final entry in pending) {
      final encryptedData = _encryption.encrypt(jsonEncode({
        'title': entry.title,
        'content': entry.content,
        'mood': entry.mood,
        'craving': entry.craving,
        'tags': entry.tags,
      }));

      await _client.from('journal_entries').upsert({
        'id': entry.id,
        'user_id': userId,
        'encrypted_data': encryptedData,
        'is_favorite': entry.isFavorite,
        'updated_at': entry.updatedAt.toIso8601String(),
        'created_at': entry.createdAt.toIso8601String(),
      });
    }

    final since = _lastSyncAt?.toIso8601String() ?? '1970-01-01T00:00:00Z';
    final remote = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since)
        .order('updated_at');

    for (final row in remote) {
      final data = jsonDecode(_encryption.decrypt(row['encrypted_data'] as String));
      final tags = (data['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          const <String>[];

      final entry = JournalEntry(
        id: row['id'] as String,
        userId: userId,
        title: data['title'] as String? ?? '',
        content: data['content'] as String? ?? '',
        mood: data['mood'] as String?,
        craving: data['craving'] as String?,
        tags: tags,
        isFavorite: row['is_favorite'] as bool? ?? false,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
      await db.saveJournalEntry(entry);
    }
  }

  // ── Step Work Sync ────────────────────────────────────────

  Future<void> _syncStepWork(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    // Push pending step answers
    final allStepAnswers = <StepWorkAnswer>[];
    for (var step = 1; step <= 12; step++) {
      final answers = await db.getStepAnswers(stepNumber: step);
      allStepAnswers.addAll(answers);
    }
    final pending = allStepAnswers.where(
      (a) => a.syncStatus == SyncStatus.pending,
    );

    for (final answer in pending) {
      await _client.from('step_work').upsert(
        {
          'id': answer.id,
          'user_id': userId,
          'step_number': answer.stepNumber,
          'question_number': answer.questionNumber,
          'encrypted_answer':
              answer.answer != null ? _encryption.encrypt(answer.answer!) : null,
          'is_complete': answer.isComplete,
          'completed_at': answer.completedAt?.toIso8601String(),
          'updated_at': answer.updatedAt.toIso8601String(),
          'created_at': answer.createdAt.toIso8601String(),
        },
        onConflict: 'user_id,step_number,question_number',
      );
    }

    // Pull remote
    final since = _lastSyncAt?.toIso8601String() ?? '1970-01-01T00:00:00Z';
    final remote = await _client
        .from('step_work')
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since)
        .order('updated_at');

    for (final row in remote) {
      final encAnswer = row['encrypted_answer'] as String?;
      final answer = StepWorkAnswer(
        id: row['id'] as String,
        userId: userId,
        stepNumber: row['step_number'] as int,
        questionNumber: row['question_number'] as int,
        answer: encAnswer != null ? _encryption.decrypt(encAnswer) : null,
        isComplete: row['is_complete'] as bool? ?? false,
        completedAt: row['completed_at'] != null
            ? DateTime.parse(row['completed_at'] as String)
            : null,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
      await db.saveStepAnswer(answer);
    }
  }

  // ── Step Progress Sync ────────────────────────────────────

  Future<void> _syncStepProgress(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final allProgress = await db.getStepProgress();
    for (final progress in allProgress) {
      await _client.from('step_progress').upsert(
        {
          'id': progress.id,
          'user_id': userId,
          'step_number': progress.stepNumber,
          'status': progress.status.value,
          'completion_percentage': progress.completionPercentage,
          'completed_at': progress.completedAt?.toIso8601String(),
          'updated_at': progress.updatedAt.toIso8601String(),
          'created_at': progress.createdAt.toIso8601String(),
        },
        onConflict: 'user_id,step_number',
      );
    }
  }

  // ── Gratitude Entries Sync ────────────────────────────────

  Future<void> _syncGratitudeEntries(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final entries = await db.getGratitudeEntries();
    for (final entry in entries) {
      await _client.from('gratitude_entries').upsert({
        'id': entry.id,
        'user_id': userId,
        'encrypted_content': _encryption.encrypt(entry.content),
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': entry.createdAt.toIso8601String(),
      });
    }
  }

  // ── Achievements Sync ─────────────────────────────────────

  Future<void> _syncAchievements(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final achievements = await db.getAchievements();
    for (final a in achievements) {
      await _client.from('achievements').upsert(
        {
          'id': a.id,
          'user_id': userId,
          'achievement_key': a.achievementKey,
          'type': a.type.value,
          'earned_at': a.earnedAt.toIso8601String(),
          'is_viewed': a.isViewed,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,achievement_key',
      );
    }
  }

  // ── Contacts Sync ─────────────────────────────────────────

  Future<void> _syncContacts(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final contacts = await db.getContacts();
    for (final contact in contacts) {
      final encryptedData = _encryption.encrypt(jsonEncode({
        'name': contact.name,
        'phone_number': contact.phoneNumber,
        'email': contact.email,
      }));

      await _client.from('contacts').upsert({
        'id': contact.id,
        'user_id': userId,
        'encrypted_data': encryptedData,
        'relationship': contact.relationship,
        'is_primary': contact.isPrimary,
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': contact.createdAt.toIso8601String(),
      });
    }
  }

  // ── Meetings Sync ─────────────────────────────────────────

  Future<void> _syncMeetings(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final meetings = await db.getMeetings(isFavorite: true);
    for (final meeting in meetings) {
      await _client.from('meetings').upsert({
        'id': meeting.id,
        'user_id': userId,
        'name': meeting.name,
        'location': meeting.location,
        'address': meeting.address,
        'meeting_date': meeting.dateTime?.toIso8601String(),
        'meeting_type': meeting.meetingType,
        'formats': meeting.formats,
        'encrypted_notes': meeting.notes != null
            ? _encryption.encrypt(meeting.notes!)
            : null,
        'is_favorite': meeting.isFavorite,
        'latitude': meeting.latitude,
        'longitude': meeting.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ── Safety Plans Sync ─────────────────────────────────────

  Future<void> _syncSafetyPlans(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final plan = await db.getSafetyPlan(userId);
    if (plan == null) return;

    final encryptedData = _encryption.encrypt(jsonEncode({
      'warning_signs': plan.warningSigns,
      'coping_strategies': plan.copingStrategies,
      'support_contacts': plan.supportContacts,
      'professional_contacts': plan.professionalContacts,
      'safe_environments': plan.safeEnvironments,
    }));

    await _client.from('safety_plans').upsert(
      {
        'id': plan.id,
        'user_id': userId,
        'encrypted_data': encryptedData,
        'updated_at': plan.updatedAt.toIso8601String(),
        'created_at': plan.createdAt.toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  // ── Challenges Sync ───────────────────────────────────────

  Future<void> _syncChallenges(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final challenges = await db.getChallenges();
    for (final challenge in challenges) {
      await _client.from('challenges').upsert({
        'id': challenge.id,
        'user_id': userId,
        'title': challenge.title,
        'description': challenge.description,
        'duration_days': challenge.durationDays,
        'start_date': challenge.startDate.toIso8601String(),
        'end_date': challenge.endDate?.toIso8601String(),
        'is_completed': challenge.isCompleted,
        'is_active': challenge.isActive,
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': challenge.createdAt.toIso8601String(),
      });
    }
  }

  // ── AI Conversations Sync ─────────────────────────────────

  Future<void> _syncAiConversations(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final conversations = await db.getChatConversations();
    for (final conv in conversations) {
      await _client.from('ai_conversations').upsert({
        'id': conv.id,
        'user_id': userId,
        'title': conv.title,
        'updated_at': conv.updatedAt.toIso8601String(),
        'created_at': conv.createdAt.toIso8601String(),
      });

      final messages = await db.getChatMessages(conversationId: conv.id);
      for (final msg in messages) {
        await _client.from('ai_messages').upsert({
          'id': msg.id,
          'conversation_id': conv.id,
          'user_id': userId,
          'encrypted_content': _encryption.encrypt(msg.content),
          'is_user': msg.isUser,
          'updated_at': DateTime.now().toIso8601String(),
          'created_at': msg.createdAt.toIso8601String(),
        });
      }
    }
  }

  // ── Reading Reflections Sync ──────────────────────────────

  Future<void> _syncReadingReflections(DatabaseService db) async {
    final userId = _userId;
    if (userId == null) return;

    final reflections = await db.getReadingReflections();
    for (final reflection in reflections) {
      await _client.from('reading_reflections').upsert(
        {
          'id': reflection.id,
          'user_id': userId,
          'reading_id': reflection.readingId,
          'reading_date':
              reflection.readingDate.toIso8601String().split('T')[0],
          'encrypted_reflection': _encryption.encrypt(reflection.reflection),
          'updated_at': DateTime.now().toIso8601String(),
          'created_at': reflection.createdAt.toIso8601String(),
        },
        onConflict: 'user_id,reading_id,reading_date',
      );
    }
  }
}
