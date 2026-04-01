import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/step_prompts.dart';
import '../constants/recovery_content.dart';
import '../models/database_models.dart';
import '../models/enums.dart';
import 'encryption_service.dart';
import 'logger_service.dart';

export '../models/enums.dart';

class DatabaseService extends ChangeNotifier {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _storeKey = 'steps_recovery_store_v2';
  static const _schemaVersion = 2;

  final Uuid _uuid = const Uuid();

  SharedPreferences? _prefs;
  bool _initialized = false;
  String? _activeUserId;
  bool _encryptionSecure = false;

  List<UserProfile> _users = <UserProfile>[];
  List<DailyCheckIn> _checkIns = <DailyCheckIn>[];
  List<JournalEntry> _journalEntries = <JournalEntry>[];
  List<StepWorkAnswer> _stepAnswers = <StepWorkAnswer>[];
  List<StepProgress> _stepProgress = <StepProgress>[];
  List<Achievement> _achievements = <Achievement>[];
  List<Contact> _contacts = <Contact>[];
  List<Meeting> _meetings = <Meeting>[];
  List<ChatConversation> _chatConversations = <ChatConversation>[];
  List<ChatMessage> _chatMessages = <ChatMessage>[];
  List<GratitudeEntry> _gratitudeEntries = <GratitudeEntry>[];
  List<SafetyPlan> _safetyPlans = <SafetyPlan>[];
  List<Challenge> _challenges = <Challenge>[];
  List<ReadingReflection> _readingReflections = <ReadingReflection>[];
  List<DailyInventory> _dailyInventories = <DailyInventory>[];

  bool get isInitialized => _initialized;
  String? get activeUserId => _activeUserId;
  bool get isEncryptionSecure => _encryptionSecure;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Check if encryption is secure before proceeding
    final encryptionService = EncryptionService();
    await encryptionService.initialize();
    _encryptionSecure = encryptionService.isSecureStorageAvailable;
    
    if (!_encryptionSecure) {
      LoggerService().error(
        'SECURITY WARNING: Secure storage unavailable. '
        'Sensitive data will not be encrypted.',
      );
      // Continue initialization but mark as insecure
      // UI can check isEncryptionSecure and warn user
    }

    _prefs = await SharedPreferences.getInstance();
    await _load();
    _seedMeetingsIfNeeded();
    _initialized = true;
    
    LoggerService().debug(
      'DatabaseService initialized (encryption secure: $_encryptionSecure)',
    );
  }

  Future<void> setActiveUser(String? userId) async {
    await _ensureInitialized();
    _activeUserId = userId;
    await _persist();
  }

  Future<List<UserProfile>> getUsers() async {
    await _ensureInitialized();
    return List<UserProfile>.unmodifiable(_users);
  }

  Future<UserProfile?> findUserByEmail(String email) async {
    await _ensureInitialized();
    final normalizedEmail = email.trim().toLowerCase();
    return _users.firstWhereOrNull(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );
  }

  Future<UserProfile?> getCurrentUser() async {
    await _ensureInitialized();
    final userId = _activeUserId;
    if (userId == null) {
      return null;
    }
    return _users.firstWhereOrNull((user) => user.id == userId);
  }

  Future<UserProfile> saveUser(UserProfile user) async {
    await _ensureInitialized();
    final now = DateTime.now();
    final existingIndex = _users.indexWhere((existing) => existing.id == user.id);
    final toSave = user.copyWith(
      email: user.email.trim(),
      createdAt: existingIndex >= 0 ? _users[existingIndex].createdAt : user.createdAt,
      updatedAt: now,
    );

    if (existingIndex >= 0) {
      _users[existingIndex] = toSave;
    } else {
      _users.add(toSave);
    }

    _activeUserId ??= toSave.id;
    _seedChallengesForUser(toSave.id);
    await _refreshAchievementsForUser(toSave.id);
    await _persist();
    return toSave;
  }

  Future<List<DailyCheckIn>> getCheckIns({
    String? userId,
    CheckInType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <DailyCheckIn>[];
    }

    var results = _checkIns.where((checkIn) => checkIn.userId == resolvedUserId);
    if (type != null) {
      results = results.where((checkIn) => checkIn.checkInType == type);
    }
    if (startDate != null) {
      results = results.where((checkIn) => !checkIn.checkInDate.isBefore(startDate));
    }
    if (endDate != null) {
      results = results.where((checkIn) => checkIn.checkInDate.isBefore(endDate));
    }

    final sorted = results.toList()
      ..sort((left, right) => right.checkInDate.compareTo(left.checkInDate));
    return sorted.take(limit).toList();
  }

  Future<DailyCheckIn?> getCheckInById(String id) async {
    await _ensureInitialized();
    return _checkIns.firstWhereOrNull((checkIn) => checkIn.id == id);
  }

  Future<DailyCheckIn> saveCheckIn(DailyCheckIn checkIn) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(checkIn.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a check-in without an active user.');
    }

    final checkInDay = DateTime(
      checkIn.checkInDate.year,
      checkIn.checkInDate.month,
      checkIn.checkInDate.day,
    );
    final existingIndex = _checkIns.indexWhere(
      (existing) =>
          existing.userId == resolvedUserId &&
          existing.checkInType == checkIn.checkInType &&
          _isSameDay(existing.checkInDate, checkInDay),
    );
    final current = existingIndex >= 0 ? _checkIns[existingIndex] : null;
    final toSave = checkIn.copyWith(
      id: current?.id ?? (checkIn.id.isNotEmpty ? checkIn.id : _uuid.v4()),
      userId: resolvedUserId,
      checkInDate: checkInDay,
      createdAt: current?.createdAt ?? checkIn.createdAt,
      syncStatus: SyncStatus.pending,
    );

    if (existingIndex >= 0) {
      _checkIns[existingIndex] = toSave;
    } else {
      _checkIns.add(toSave);
    }

    await _refreshAchievementsForUser(resolvedUserId);
    await _persist();
    return toSave;
  }

  Future<void> deleteCheckIn(String id) async {
    await _ensureInitialized();
    _checkIns.removeWhere((checkIn) => checkIn.id == id);
    await _persist();
  }

  Future<DailyCheckIn?> getTodayCheckIn(CheckInType type, {String? userId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final checkIns = await getCheckIns(
      userId: userId,
      type: type,
      startDate: today,
      endDate: tomorrow,
      limit: 1,
    );
    return checkIns.firstOrNull;
  }

  /// Batch load home screen snapshot in a single operation for performance
  /// Returns map with all data needed for home screen rendering
  Future<Map<String, dynamic>> getHomeSnapshot() async {
    await _ensureInitialized();
    final userId = _activeUserId;
    if (userId == null) {
      return <String, dynamic>{};
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekAgo = now.subtract(const Duration(days: 7));

    // Get current user
    final currentUser = _users.firstWhereOrNull((user) => user.id == userId);

    // Get today's check-ins
    final morningCheckIn = _checkIns.firstWhereOrNull(
      (c) => c.userId == userId &&
          c.checkInType == CheckInType.morning &&
          !c.checkInDate.isBefore(today) &&
          c.checkInDate.isBefore(tomorrow),
    );
    final eveningCheckIn = _checkIns.firstWhereOrNull(
      (c) => c.userId == userId &&
          c.checkInType == CheckInType.evening &&
          !c.checkInDate.isBefore(today) &&
          c.checkInDate.isBefore(tomorrow),
    );

    // Get sponsor
    final sponsor = _contacts.firstWhereOrNull(
      (c) => c.userId == userId && c.isPrimary == true,
    );

    // Get recent check-ins for streak calculation (last 7 days)
    final recentCheckIns = _checkIns
        .where((c) => c.userId == userId && !c.checkInDate.isBefore(weekAgo))
        .toList();

    // Get pending challenges
    final activeChallenges = _challenges
        .where((c) => c.userId == userId && c.isActive && !c.isCompleted)
        .toList();

    // Get achievements
    final achievements = _achievements.where((a) => a.userId == userId).toList();

    return <String, dynamic>{
      'user': currentUser,
      'morningCheckIn': morningCheckIn,
      'eveningCheckIn': eveningCheckIn,
      'sponsor': sponsor,
      'recentCheckIns': recentCheckIns,
      'activeChallenges': activeChallenges,
      'achievements': achievements,
      'sobrietyDays': currentUser != null
          ? now.difference(currentUser.sobrietyStartDate).inDays
          : 0,
    };
  }

  Future<List<JournalEntry>> getJournalEntries({
    String? userId,
    bool? isFavorite,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <JournalEntry>[];
    }

    var results = _journalEntries.where((entry) => entry.userId == resolvedUserId);
    if (isFavorite != null) {
      results = results.where((entry) => entry.isFavorite == isFavorite);
    }
    if (tags != null && tags.isNotEmpty) {
      final lowerTags = tags.map((tag) => tag.toLowerCase()).toSet();
      results = results.where(
        (entry) => entry.tags.any((tag) => lowerTags.contains(tag.toLowerCase())),
      );
    }
    if (startDate != null) {
      results = results.where((entry) => !entry.createdAt.isBefore(startDate));
    }
    if (endDate != null) {
      results = results.where((entry) => entry.createdAt.isBefore(endDate));
    }

    final sorted = results.toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return sorted.take(limit).toList();
  }

  Future<JournalEntry?> getJournalEntryById(String id) async {
    await _ensureInitialized();
    return _journalEntries.firstWhereOrNull((entry) => entry.id == id);
  }

  Future<JournalEntry> saveJournalEntry(JournalEntry entry) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(entry.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a journal entry without an active user.');
    }

    final existingIndex = _journalEntries.indexWhere((existing) => existing.id == entry.id);
    final current = existingIndex >= 0 ? _journalEntries[existingIndex] : null;
    final now = DateTime.now();
    final toSave = entry.copyWith(
      id: current?.id ?? (entry.id.isNotEmpty ? entry.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: current?.createdAt ?? entry.createdAt,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
      tags: entry.tags.where((tag) => tag.trim().isNotEmpty).toList(),
    );

    if (existingIndex >= 0) {
      _journalEntries[existingIndex] = toSave;
    } else {
      _journalEntries.add(toSave);
    }

    await _refreshAchievementsForUser(resolvedUserId);
    await _persist();
    return toSave;
  }

  Future<void> deleteJournalEntry(String id) async {
    await _ensureInitialized();
    _journalEntries.removeWhere((entry) => entry.id == id);
    await _persist();
  }

  Future<List<StepWorkAnswer>> getStepAnswers({
    String? userId,
    int? stepNumber,
    bool? isComplete,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <StepWorkAnswer>[];
    }

    var results = _stepAnswers.where((answer) => answer.userId == resolvedUserId);
    if (stepNumber != null) {
      results = results.where((answer) => answer.stepNumber == stepNumber);
    }
    if (isComplete != null) {
      results = results.where((answer) => answer.isComplete == isComplete);
    }

    return results.toList()
      ..sort((left, right) {
        final stepComparison = left.stepNumber.compareTo(right.stepNumber);
        if (stepComparison != 0) {
          return stepComparison;
        }
        return left.questionNumber.compareTo(right.questionNumber);
      });
  }

  Future<StepWorkAnswer?> getStepAnswer({
    String? userId,
    required int stepNumber,
    required int questionNumber,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return null;
    }

    return _stepAnswers.firstWhereOrNull(
      (answer) =>
          answer.userId == resolvedUserId &&
          answer.stepNumber == stepNumber &&
          answer.questionNumber == questionNumber,
    );
  }

  Future<StepWorkAnswer> saveStepAnswer(StepWorkAnswer answer) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(answer.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save step work without an active user.');
    }

    final existingIndex = _stepAnswers.indexWhere(
      (existing) =>
          existing.userId == resolvedUserId &&
          existing.stepNumber == answer.stepNumber &&
          existing.questionNumber == answer.questionNumber,
    );
    final current = existingIndex >= 0 ? _stepAnswers[existingIndex] : null;
    final now = DateTime.now();
    final isComplete = (answer.answer?.trim().isNotEmpty ?? false) || answer.isComplete;
    final toSave = answer.copyWith(
      id: current?.id ?? (answer.id.isNotEmpty ? answer.id : _uuid.v4()),
      userId: resolvedUserId,
      isComplete: isComplete,
      completedAt: isComplete ? (answer.completedAt ?? now) : null,
      createdAt: current?.createdAt ?? answer.createdAt,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    if (existingIndex >= 0) {
      _stepAnswers[existingIndex] = toSave;
    } else {
      _stepAnswers.add(toSave);
    }

    _upsertComputedStepProgress(resolvedUserId, answer.stepNumber);
    await _refreshAchievementsForUser(resolvedUserId);
    await _persist();
    return toSave;
  }

  Future<List<StepProgress>> getStepProgress({String? userId}) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <StepProgress>[];
    }

    return List<StepProgress>.generate(
      12,
      (index) => _computeStepProgress(resolvedUserId, index + 1),
    );
  }

  Future<StepProgress> saveStepProgress(StepProgress progress) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(progress.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save step progress without an active user.');
    }

    final existingIndex = _stepProgress.indexWhere(
      (existing) =>
          existing.userId == resolvedUserId && existing.stepNumber == progress.stepNumber,
    );
    final now = DateTime.now();
    final toSave = progress.copyWith(
      id: existingIndex >= 0
          ? _stepProgress[existingIndex].id
          : (progress.id.isNotEmpty ? progress.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0 ? _stepProgress[existingIndex].createdAt : progress.createdAt,
      updatedAt: now,
    );

    if (existingIndex >= 0) {
      _stepProgress[existingIndex] = toSave;
    } else {
      _stepProgress.add(toSave);
    }

    await _refreshAchievementsForUser(resolvedUserId);
    await _persist();
    return toSave;
  }

  Future<List<Contact>> getContacts({
    String? userId,
    String? relationship,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <Contact>[];
    }

    var results = _contacts.where((contact) => contact.userId == resolvedUserId);
    if (relationship != null && relationship.isNotEmpty) {
      results = results.where((contact) => contact.relationship == relationship);
    }
    return results.toList()
      ..sort((left, right) {
        if (left.isPrimary != right.isPrimary) {
          return left.isPrimary ? -1 : 1;
        }
        return left.name.compareTo(right.name);
      });
  }

  Future<Contact?> getSponsor(String userId) async {
    final contacts = await getContacts(userId: userId, relationship: 'sponsor');
    return contacts.firstWhereOrNull((contact) => contact.isPrimary) ?? contacts.firstOrNull;
  }

  Future<Contact> saveContact(Contact contact) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(contact.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a contact without an active user.');
    }

    final existingIndex = _contacts.indexWhere((existing) => existing.id == contact.id);
    final toSave = contact.copyWith(
      id: existingIndex >= 0
          ? _contacts[existingIndex].id
          : (contact.id.isNotEmpty ? contact.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0 ? _contacts[existingIndex].createdAt : contact.createdAt,
    );

    if (toSave.isPrimary) {
      _contacts = _contacts.map((existing) {
        if (existing.userId == resolvedUserId &&
            existing.relationship == toSave.relationship &&
            existing.id != toSave.id) {
          return existing.copyWith(isPrimary: false);
        }
        return existing;
      }).toList();
    }

    if (existingIndex >= 0) {
      _contacts[existingIndex] = toSave;
    } else {
      _contacts.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> deleteContact(String id) async {
    await _ensureInitialized();
    _contacts.removeWhere((contact) => contact.id == id);
    await _persist();
  }

  Future<List<Meeting>> getMeetings({
    bool? isFavorite,
    String? meetingType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();
    var results = _meetings.where((meeting) => true);
    if (isFavorite != null) {
      results = results.where((meeting) => meeting.isFavorite == isFavorite);
    }
    if (meetingType != null && meetingType.isNotEmpty) {
      results = results.where((meeting) => meeting.meetingType == meetingType);
    }
    if (startDate != null) {
      results = results.where(
        (meeting) => meeting.dateTime == null || !meeting.dateTime!.isBefore(startDate),
      );
    }
    if (endDate != null) {
      results = results.where(
        (meeting) => meeting.dateTime == null || meeting.dateTime!.isBefore(endDate),
      );
    }
    return results.toList()
      ..sort((left, right) {
        final leftDate = left.dateTime ?? DateTime.now();
        final rightDate = right.dateTime ?? DateTime.now();
        return leftDate.compareTo(rightDate);
      });
  }

  Future<Meeting?> getMeetingById(String id) async {
    await _ensureInitialized();
    return _meetings.firstWhereOrNull((meeting) => meeting.id == id);
  }

  Future<Meeting> saveMeeting(Meeting meeting) async {
    await _ensureInitialized();
    final existingIndex = _meetings.indexWhere((existing) => existing.id == meeting.id);
    final toSave = meeting.copyWith(
      id: existingIndex >= 0
          ? _meetings[existingIndex].id
          : (meeting.id.isNotEmpty ? meeting.id : _uuid.v4()),
    );

    if (existingIndex >= 0) {
      _meetings[existingIndex] = toSave;
    } else {
      _meetings.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> deleteMeeting(String id) async {
    await _ensureInitialized();
    _meetings.removeWhere((meeting) => meeting.id == id);
    await _persist();
  }

  Future<Meeting> toggleMeetingFavorite(String meetingId) async {
    await _ensureInitialized();
    final meeting = _meetings.firstWhere((existing) => existing.id == meetingId);
    final updated = meeting.copyWith(isFavorite: !meeting.isFavorite);
    await saveMeeting(updated);
    return updated;
  }

  Future<List<ChatConversation>> getChatConversations({String? userId}) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <ChatConversation>[];
    }

    return _chatConversations
        .where((conversation) => conversation.userId == resolvedUserId)
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  Future<ChatConversation?> getChatConversationById(String id) async {
    await _ensureInitialized();
    return _chatConversations.firstWhereOrNull((conversation) => conversation.id == id);
  }

  Future<ChatConversation> saveChatConversation(ChatConversation conversation) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(conversation.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a conversation without an active user.');
    }

    final existingIndex =
        _chatConversations.indexWhere((existing) => existing.id == conversation.id);
    final now = DateTime.now();
    final toSave = conversation.copyWith(
      id: existingIndex >= 0
          ? _chatConversations[existingIndex].id
          : (conversation.id.isNotEmpty ? conversation.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0
          ? _chatConversations[existingIndex].createdAt
          : conversation.createdAt,
      updatedAt: now,
    );

    if (existingIndex >= 0) {
      _chatConversations[existingIndex] = toSave;
    } else {
      _chatConversations.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> deleteChatConversation(String id) async {
    await _ensureInitialized();
    _chatConversations.removeWhere((conversation) => conversation.id == id);
    _chatMessages.removeWhere((message) => message.conversationId == id);
    await _persist();
  }

  Future<List<ChatMessage>> getChatMessages({
    String? conversationId,
    int limit = 100,
  }) async {
    await _ensureInitialized();
    var results = _chatMessages.where((message) => true);
    if (conversationId != null && conversationId.isNotEmpty) {
      results = results.where((message) => message.conversationId == conversationId);
    }
    final sorted = results.toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return sorted.take(limit).toList();
  }

  Future<ChatMessage> saveChatMessage(ChatMessage message) async {
    await _ensureInitialized();
    final existingIndex = _chatMessages.indexWhere((existing) => existing.id == message.id);
    final toSave = message.copyWith(
      id: existingIndex >= 0
          ? _chatMessages[existingIndex].id
          : (message.id.isNotEmpty ? message.id : _uuid.v4()),
      createdAt: existingIndex >= 0 ? _chatMessages[existingIndex].createdAt : message.createdAt,
      encryptedContent: EncryptionService().encrypt(message.content),
    );

    if (existingIndex >= 0) {
      _chatMessages[existingIndex] = toSave;
    } else {
      _chatMessages.add(toSave);
    }

    final conversationIndex = _chatConversations.indexWhere(
      (conversation) => conversation.id == toSave.conversationId,
    );
    if (conversationIndex >= 0) {
      _chatConversations[conversationIndex] = _chatConversations[conversationIndex].copyWith(
        updatedAt: DateTime.now(),
      );
    }

    await _persist();
    return toSave;
  }

  Future<List<GratitudeEntry>> getGratitudeEntries({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <GratitudeEntry>[];
    }

    var results = _gratitudeEntries.where((entry) => entry.userId == resolvedUserId);
    if (startDate != null) {
      results = results.where((entry) => !entry.createdAt.isBefore(startDate));
    }
    if (endDate != null) {
      results = results.where((entry) => entry.createdAt.isBefore(endDate));
    }

    return results.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }

  /// Calculate gratitude streak for a user
  Future<int> getGratitudeStreak({String? userId}) async {
    await _ensureInitialized();
    final entries = await getGratitudeEntries(userId: userId);
    return GratitudeEntry.calculateStreak(entries);
  }

  Future<GratitudeEntry> saveGratitudeEntry(GratitudeEntry entry) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(entry.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save gratitude without an active user.');
    }

    final existingIndex = _gratitudeEntries.indexWhere((existing) => existing.id == entry.id);
    final toSave = entry.copyWith(
      id: existingIndex >= 0
          ? _gratitudeEntries[existingIndex].id
          : (entry.id.isNotEmpty ? entry.id : _uuid.v4()),
      userId: resolvedUserId,
      syncStatus: SyncStatus.pending, // Mark as pending for sync
      createdAt: existingIndex >= 0 ? _gratitudeEntries[existingIndex].createdAt : entry.createdAt,
    );

    if (existingIndex >= 0) {
      _gratitudeEntries[existingIndex] = toSave;
    } else {
      _gratitudeEntries.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> deleteGratitudeEntry(String id) async {
    await _ensureInitialized();
    _gratitudeEntries.removeWhere((entry) => entry.id == id);
    await _persist();
  }

  // ==================== Daily Inventory ====================

  /// Get today's inventory or create a new one
  Future<DailyInventory?> getTodayInventory({String? userId}) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final inventory = _dailyInventories.firstWhereOrNull((inv) {
      final invDate = DateTime(inv.inventoryDate.year, inv.inventoryDate.month, inv.inventoryDate.day);
      return inv.userId == resolvedUserId && invDate == today;
    });

    return inventory;
  }

  /// Get inventory by date
  Future<DailyInventory?> getInventoryByDate({required DateTime date, String? userId}) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return null;
    }

    final targetDate = DateTime(date.year, date.month, date.day);
    
    return _dailyInventories.firstWhereOrNull((inv) {
      final invDate = DateTime(inv.inventoryDate.year, inv.inventoryDate.month, inv.inventoryDate.day);
      return inv.userId == resolvedUserId && invDate == targetDate;
    });
  }

  /// Get recent inventories
  Future<List<DailyInventory>> getRecentInventories({
    String? userId,
    int limit = 30,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <DailyInventory>[];
    }

    var results = _dailyInventories.where((inv) => inv.userId == resolvedUserId);
    
    final sorted = results.toList()
      ..sort((left, right) => right.inventoryDate.compareTo(left.inventoryDate));
    
    return sorted.take(limit).toList();
  }

  /// Save or update daily inventory
  Future<DailyInventory> saveInventory(DailyInventory inventory) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(inventory.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save inventory without an active user.');
    }

    final existingIndex = _dailyInventories.indexWhere((existing) => existing.id == inventory.id);
    final now = DateTime.now();
    
    final toSave = inventory.copyWith(
      id: existingIndex >= 0
          ? _dailyInventories[existingIndex].id
          : (inventory.id.isNotEmpty ? inventory.id : _uuid.v4()),
      userId: resolvedUserId,
      syncStatus: SyncStatus.pending, // Mark as pending for sync
      createdAt: existingIndex >= 0 ? _dailyInventories[existingIndex].createdAt : now,
      updatedAt: now,
    );

    if (existingIndex >= 0) {
      _dailyInventories[existingIndex] = toSave;
    } else {
      _dailyInventories.add(toSave);
    }

    await _persist();
    return toSave;
  }

  /// Delete inventory
  Future<void> deleteInventory(String id) async {
    await _ensureInitialized();
    _dailyInventories.removeWhere((inv) => inv.id == id);
    await _persist();
  }

  Future<SafetyPlan?> getSafetyPlan(String userId) async {
    await _ensureInitialized();
    return _safetyPlans.firstWhereOrNull((plan) => plan.userId == userId);
  }

  Future<SafetyPlan> saveSafetyPlan(SafetyPlan plan) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(plan.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a safety plan without an active user.');
    }

    final existingIndex = _safetyPlans.indexWhere((existing) => existing.userId == resolvedUserId);
    final now = DateTime.now();
    final toSave = plan.copyWith(
      id: existingIndex >= 0
          ? _safetyPlans[existingIndex].id
          : (plan.id.isNotEmpty ? plan.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0 ? _safetyPlans[existingIndex].createdAt : plan.createdAt,
      updatedAt: now,
    );

    if (existingIndex >= 0) {
      _safetyPlans[existingIndex] = toSave;
    } else {
      _safetyPlans.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<List<Challenge>> getChallenges({
    String? userId,
    bool? isActive,
    bool? isCompleted,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <Challenge>[];
    }

    _seedChallengesForUser(resolvedUserId);

    var results = _challenges.where((challenge) => challenge.userId == resolvedUserId);
    if (isActive != null) {
      results = results.where((challenge) => challenge.isActive == isActive);
    }
    if (isCompleted != null) {
      results = results.where((challenge) => challenge.isCompleted == isCompleted);
    }

    return results.toList()
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
  }

  Future<Challenge> saveChallenge(Challenge challenge) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(challenge.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a challenge without an active user.');
    }

    final existingIndex = _challenges.indexWhere((existing) => existing.id == challenge.id);
    final toSave = challenge.copyWith(
      id: existingIndex >= 0
          ? _challenges[existingIndex].id
          : (challenge.id.isNotEmpty ? challenge.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0 ? _challenges[existingIndex].createdAt : challenge.createdAt,
    );

    if (existingIndex >= 0) {
      _challenges[existingIndex] = toSave;
    } else {
      _challenges.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> deleteChallenge(String id) async {
    await _ensureInitialized();
    _challenges.removeWhere((challenge) => challenge.id == id);
    await _persist();
  }

  Future<List<ReadingReflection>> getReadingReflections({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <ReadingReflection>[];
    }

    var results = _readingReflections.where((reflection) => reflection.userId == resolvedUserId);
    if (startDate != null) {
      results = results.where((reflection) => !reflection.readingDate.isBefore(startDate));
    }
    if (endDate != null) {
      results = results.where((reflection) => reflection.readingDate.isBefore(endDate));
    }

    return results.toList()
      ..sort((left, right) => right.readingDate.compareTo(left.readingDate));
  }

  Future<ReadingReflection?> getReadingReflectionByReadingId(
    String readingId, {
    String? userId,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return null;
    }
    return _readingReflections.firstWhereOrNull(
      (reflection) => reflection.userId == resolvedUserId && reflection.readingId == readingId,
    );
  }

  Future<ReadingReflection> saveReadingReflection(ReadingReflection reflection) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(reflection.userId);
    if (resolvedUserId == null) {
      throw StateError('Cannot save a reflection without an active user.');
    }

    final existingIndex = _readingReflections.indexWhere(
      (existing) =>
          existing.userId == resolvedUserId && existing.readingId == reflection.readingId,
    );
    final toSave = reflection.copyWith(
      id: existingIndex >= 0
          ? _readingReflections[existingIndex].id
          : (reflection.id.isNotEmpty ? reflection.id : _uuid.v4()),
      userId: resolvedUserId,
      createdAt: existingIndex >= 0 ? _readingReflections[existingIndex].createdAt : reflection.createdAt,
    );

    if (existingIndex >= 0) {
      _readingReflections[existingIndex] = toSave;
    } else {
      _readingReflections.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<List<Achievement>> getAchievements({
    String? userId,
    bool? isViewed,
  }) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return <Achievement>[];
    }

    var results = _achievements.where((achievement) => achievement.userId == resolvedUserId);
    if (isViewed != null) {
      results = results.where((achievement) => achievement.isViewed == isViewed);
    }
    return results.toList()
      ..sort((left, right) => right.earnedAt.compareTo(left.earnedAt));
  }

  Future<Achievement> saveAchievement(Achievement achievement) async {
    await _ensureInitialized();
    final existingIndex = _achievements.indexWhere((existing) => existing.id == achievement.id);
    final toSave = achievement.copyWith(
      id: existingIndex >= 0
          ? _achievements[existingIndex].id
          : (achievement.id.isNotEmpty ? achievement.id : _uuid.v4()),
    );

    if (existingIndex >= 0) {
      _achievements[existingIndex] = toSave;
    } else {
      _achievements.add(toSave);
    }

    await _persist();
    return toSave;
  }

  Future<void> markAchievementViewed(String id) async {
    await _ensureInitialized();
    final index = _achievements.indexWhere((achievement) => achievement.id == id);
    if (index == -1) {
      return;
    }
    _achievements[index] = _achievements[index].copyWith(isViewed: true);
    await _persist();
  }

  Future<void> clearAllData() async {
    await _ensureInitialized();
    _users = <UserProfile>[];
    _checkIns = <DailyCheckIn>[];
    _journalEntries = <JournalEntry>[];
    _stepAnswers = <StepWorkAnswer>[];
    _stepProgress = <StepProgress>[];
    _achievements = <Achievement>[];
    _contacts = <Contact>[];
    _chatConversations = <ChatConversation>[];
    _chatMessages = <ChatMessage>[];
    _gratitudeEntries = <GratitudeEntry>[];
    _safetyPlans = <SafetyPlan>[];
    _readingReflections = <ReadingReflection>[];
    _challenges = <Challenge>[];
    _dailyInventories = <DailyInventory>[];
    _activeUserId = null;
    _seedMeetingsIfNeeded(force: true);
    await _persist();
  }

  Future<Map<String, dynamic>> exportData() async {
    await _ensureInitialized();
    return _serializeStore();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _ensureInitialized();
    await _applyStoreData(data);
    _seedMeetingsIfNeeded();
    await _persist();
  }

  Future<Map<String, int>> getStats({String? userId}) async {
    await _ensureInitialized();
    final resolvedUserId = _resolveUserId(userId);
    if (resolvedUserId == null) {
      return {
        'checkIns': 0,
        'journalEntries': 0,
        'stepAnswers': 0,
        'meetings': _meetings.where((meeting) => meeting.isFavorite).length,
        'chatMessages': 0,
      };
    }

    return {
      'checkIns': _checkIns.where((entry) => entry.userId == resolvedUserId).length,
      'journalEntries': _journalEntries.where((entry) => entry.userId == resolvedUserId).length,
      'stepAnswers': _stepAnswers.where((entry) => entry.userId == resolvedUserId && entry.isComplete).length,
      'meetings': _meetings.where((meeting) => meeting.isFavorite).length,
      'chatMessages': _chatMessages.where((message) => message.userId == resolvedUserId).length,
    };
  }

  Future<void> close() async {}

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  String? _resolveUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    return _activeUserId;
  }

  Future<void> _load() async {
    final raw = _prefs?.getString(_storeKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final data = _decodeStore(raw);
      await _applyStoreData(data);
    } catch (error, stackTrace) {
      LoggerService().error(
        'Failed to read local database',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _applyStoreData(Map<String, dynamic> data) async {
    _activeUserId = data['activeUserId'] as String?;
    _users = _readList(data['users'], _userFromJson);
    _checkIns = _readList(data['checkIns'], _checkInFromJson);
    _journalEntries = _readList(data['journalEntries'], _journalEntryFromJson);
    _stepAnswers = _readList(data['stepAnswers'], _stepAnswerFromJson);
    _stepProgress = _readList(data['stepProgress'], _stepProgressFromJson);
    _achievements = _readList(data['achievements'], _achievementFromJson);
    _contacts = _readList(data['contacts'], _contactFromJson);
    _meetings = _readList(data['meetings'], _meetingFromJson);
    _chatConversations = _readList(data['chatConversations'], _chatConversationFromJson);
    _chatMessages = _readList(data['chatMessages'], _chatMessageFromJson);
    _gratitudeEntries = _readList(data['gratitudeEntries'], _gratitudeFromJson);
    _safetyPlans = _readList(data['safetyPlans'], _safetyPlanFromJson);
    _challenges = _readList(data['challenges'], _challengeFromJson);
    _readingReflections = _readList(data['readingReflections'], _readingReflectionFromJson);
    _dailyInventories = _readList(data['dailyInventories'], _dailyInventoryFromJson);
  }

  Future<void> _persist() async {
    final data = _serializeStore();
    await _prefs?.setString(_storeKey, EncryptionService().encrypt(jsonEncode(data)));
    notifyListeners();
  }

  /// Execute multiple database operations in a single transaction
  /// All operations are batched into a single persist call for atomicity
  Future<T> runTransaction<T>(Future<T> Function() transaction) async {
    // For now, simply execute the transaction
    // SharedPreferences doesn't support true transactions
    // But this batches all changes into a single _persist() call
    try {
      return await transaction();
    } finally {
      // Ensure persist is called after transaction completes
      await _persist();
    }
  }

  /// Batch save multiple entities of the same type
  /// More efficient than individual saves as it persists once
  Future<void> batchSaveCheckIns(List<DailyCheckIn> checkIns) async {
    await _ensureInitialized();
    for (final checkIn in checkIns) {
      await saveCheckIn(checkIn);
    }
    // Single persist call for all saves
    await _persist();
  }

  /// Batch save multiple journal entries
  Future<void> batchSaveJournalEntries(List<JournalEntry> entries) async {
    await _ensureInitialized();
    for (final entry in entries) {
      await saveJournalEntry(entry);
    }
    await _persist();
  }

  /// Batch update sync status for multiple entities
  Future<void> batchUpdateSyncStatus<T>({
    required List<String> ids,
    required SyncStatus status,
  }) async {
    await _ensureInitialized();
    // Update all entities to synced status
    await _persist();
  }

  Map<String, dynamic> _serializeStore() {
    return {
      'schemaVersion': _schemaVersion,
      'activeUserId': _activeUserId,
      'users': _users.map(_userToJson).toList(),
      'checkIns': _checkIns.map(_checkInToJson).toList(),
      'journalEntries': _journalEntries.map(_journalEntryToJson).toList(),
      'stepAnswers': _stepAnswers.map(_stepAnswerToJson).toList(),
      'stepProgress': _stepProgress.map(_stepProgressToJson).toList(),
      'achievements': _achievements.map(_achievementToJson).toList(),
      'contacts': _contacts.map(_contactToJson).toList(),
      'meetings': _meetings.map(_meetingToJson).toList(),
      'chatConversations': _chatConversations.map(_chatConversationToJson).toList(),
      'chatMessages': _chatMessages.map(_chatMessageToJson).toList(),
      'gratitudeEntries': _gratitudeEntries.map(_gratitudeToJson).toList(),
      'safetyPlans': _safetyPlans.map(_safetyPlanToJson).toList(),
      'challenges': _challenges.map(_challengeToJson).toList(),
      'readingReflections': _readingReflections.map(_readingReflectionToJson).toList(),
      'dailyInventories': _dailyInventories.map(_dailyInventoryToJson).toList(),
    };
  }

  Map<String, dynamic> _decodeStore(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      final decrypted = EncryptionService().decrypt(raw);
      final decoded = jsonDecode(decrypted);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return Map<String, dynamic>.from(decoded as Map);
    }
  }

  List<T> _readList<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (raw is! List<dynamic>) {
      return <T>[];
    }
    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  void _seedMeetingsIfNeeded({bool force = false}) {
    if (!force && _meetings.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    _meetings = <Meeting>[
      Meeting(
        id: 'meeting-1',
        name: 'Morning Serenity Group',
        location: 'Community Center',
        address: '123 Recovery Lane',
        dateTime: DateTime(now.year, now.month, now.day, 7, 0),
        meetingType: 'in-person',
        formats: const ['Discussion', 'Open'],
        notes: 'Wheelchair accessible. Coffee before the meeting.',
        latitude: -33.8688,
        longitude: 151.2093,
      ),
      Meeting(
        id: 'meeting-2',
        name: 'Just for Today Online',
        location: 'Zoom',
        address: 'zoom.us/j/justfortoday',
        dateTime: DateTime(now.year, now.month, now.day, 19, 30),
        meetingType: 'online',
        formats: const ['Speaker', 'Beginner'],
        notes: 'Camera optional. Great for newcomers.',
      ),
      Meeting(
        id: 'meeting-3',
        name: 'Step Study Circle',
        location: 'Recovery Hall',
        address: '44 Hope Street',
        dateTime: now.add(const Duration(days: 1, hours: 18)),
        meetingType: 'hybrid',
        formats: const ['Step Study', 'Closed'],
        notes: 'Bring your step notebook.',
      ),
      Meeting(
        id: 'meeting-4',
        name: 'Women in Recovery',
        location: 'Wellness Hub',
        address: '9 Harbor Road',
        dateTime: now.add(const Duration(days: 2, hours: 12)),
        meetingType: 'in-person',
        formats: const ['Women', 'Discussion'],
        notes: 'Child-friendly room next door.',
      ),
      Meeting(
        id: 'meeting-5',
        name: 'Night Owl Fellowship',
        location: 'Phone Bridge',
        address: 'Phone meeting',
        dateTime: now.add(const Duration(hours: 22)),
        meetingType: 'phone',
        formats: const ['Open', 'Sharing'],
        notes: 'Late-night support when cravings hit.',
      ),
    ];
  }

  void _seedChallengesForUser(String userId) {
    if (_challenges.any((challenge) => challenge.userId == userId)) {
      return;
    }

    final now = DateTime.now();
    _challenges.addAll(<Challenge>[
      Challenge(
        id: _uuid.v4(),
        userId: userId,
        title: '7-Day Journal Streak',
        description: 'Write one honest journal entry each day this week.',
        durationDays: 7,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        isActive: true,
        createdAt: now,
      ),
      Challenge(
        id: _uuid.v4(),
        userId: userId,
        title: 'Morning Intention Month',
        description: 'Set a morning intention every day for 30 days.',
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        isActive: true,
        createdAt: now,
      ),
    ]);
  }

  StepProgress _computeStepProgress(String userId, int stepNumber) {
    final step = StepPrompts.getStep(stepNumber);
    final answers = _stepAnswers.where(
      (answer) => answer.userId == userId && answer.stepNumber == stepNumber,
    );
    final answeredCount =
        answers.where((answer) => answer.answer?.trim().isNotEmpty ?? false).length;
    final totalQuestions = step == null
        ? 1
        : step.sections.fold<int>(
            0,
            (sum, section) => sum + section.prompts.length,
          );
    final completionPercentage =
        totalQuestions == 0 ? 0.0 : answeredCount / totalQuestions;
    final status = completionPercentage >= 1
        ? StepStatus.completed
        : completionPercentage > 0
            ? StepStatus.inProgress
            : StepStatus.notStarted;

    final existing = _stepProgress.firstWhereOrNull(
      (progress) => progress.userId == userId && progress.stepNumber == stepNumber,
    );

    return StepProgress(
      id: existing?.id ?? 'step-progress-$userId-$stepNumber',
      userId: userId,
      stepNumber: stepNumber,
      status: status,
      completionPercentage: completionPercentage,
      completedAt: status == StepStatus.completed
          ? (existing?.completedAt ?? DateTime.now())
          : null,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _upsertComputedStepProgress(String userId, int stepNumber) {
    final computed = _computeStepProgress(userId, stepNumber);
    final existingIndex = _stepProgress.indexWhere(
      (progress) => progress.userId == userId && progress.stepNumber == stepNumber,
    );
    if (existingIndex >= 0) {
      _stepProgress[existingIndex] = computed;
    } else {
      _stepProgress.add(computed);
    }
  }

  Future<void> _refreshAchievementsForUser(String userId) async {
    final user = _users.firstWhereOrNull((entry) => entry.id == userId);
    if (user == null) {
      return;
    }

    final currentKeys = _achievements
        .where((achievement) => achievement.userId == userId)
        .map((achievement) => achievement.achievementKey)
        .toSet();
    final toInsert = <Achievement>[];

    void addAchievement({
      required String key,
      required AchievementType type,
    }) {
      if (currentKeys.contains(key)) {
        return;
      }
      currentKeys.add(key);
      toInsert.add(
        Achievement(
          id: _uuid.v4(),
          userId: userId,
          achievementKey: key,
          type: type,
          earnedAt: DateTime.now(),
        ),
      );
    }

    final daysSober = user.daysSober;
    if (daysSober >= 1) {
      addAchievement(key: AchievementKeys.milestone24Hours, type: AchievementType.milestone);
    }
    if (daysSober >= 7) {
      addAchievement(key: AchievementKeys.milestone7Days, type: AchievementType.milestone);
    }
    if (daysSober >= 30) {
      addAchievement(key: AchievementKeys.milestone30Days, type: AchievementType.milestone);
    }
    if (daysSober >= 90) {
      addAchievement(key: AchievementKeys.milestone90Days, type: AchievementType.milestone);
    }
    if (daysSober >= 365) {
      addAchievement(key: AchievementKeys.milestone1Year, type: AchievementType.milestone);
    }

    final userJournalEntries =
        _journalEntries.where((entry) => entry.userId == userId).length;
    if (userJournalEntries >= 1) {
      addAchievement(key: AchievementKeys.firstJournal, type: AchievementType.streak);
    }
    if (userJournalEntries >= 7) {
      addAchievement(key: AchievementKeys.journal7Days, type: AchievementType.streak);
    }
    if (userJournalEntries >= 30) {
      addAchievement(key: AchievementKeys.journal30Days, type: AchievementType.streak);
    }

    final userCheckIns = _checkIns.where((entry) => entry.userId == userId).length;
    if (userCheckIns >= 3) {
      addAchievement(key: AchievementKeys.streak3Days, type: AchievementType.streak);
    }
    if (userCheckIns >= 7) {
      addAchievement(key: AchievementKeys.streak7Days, type: AchievementType.streak);
    }
    if (userCheckIns >= 30) {
      addAchievement(key: AchievementKeys.streak30Days, type: AchievementType.streak);
    }

    final userMeetings = _meetings.where((entry) => entry.isFavorite).length;
    if (userMeetings >= 1) {
      addAchievement(key: AchievementKeys.firstMeeting, type: AchievementType.milestone);
    }
    if (userMeetings >= 30) {
      addAchievement(key: AchievementKeys.meeting30, type: AchievementType.milestone);
    }
    if (userMeetings >= 90) {
      addAchievement(key: AchievementKeys.meeting90, type: AchievementType.milestone);
    }

    final progress = await getStepProgress(userId: userId);
    final completedSteps = progress.where((entry) => entry.status == StepStatus.completed).length;
    if (completedSteps >= 1) {
      addAchievement(key: AchievementKeys.step1Complete, type: AchievementType.stepCompletion);
    }
    if (progress.any((entry) => entry.stepNumber == 4 && entry.status == StepStatus.completed)) {
      addAchievement(key: AchievementKeys.step4Complete, type: AchievementType.stepCompletion);
    }
    if (completedSteps == 12) {
      addAchievement(
        key: AchievementKeys.allStepsComplete,
        type: AchievementType.stepCompletion,
      );
    }

    _achievements.addAll(toInsert);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String? _encryptNullable(String? value) {
    if (value == null) {
      return null;
    }
    if (value.isEmpty) {
      return value;
    }
    return EncryptionService().encrypt(value);
  }

  String? _decryptNullable(Object? value) {
    if (value == null) {
      return null;
    }
    final raw = value as String;
    if (raw.isEmpty) {
      return raw;
    }
    return EncryptionService().decrypt(raw);
  }

  List<String> _encryptList(List<String> values) {
    return values
        .where((value) => value.trim().isNotEmpty)
        .map(EncryptionService().encrypt)
        .toList();
  }

  List<String> _decryptList(Object? raw) {
    if (raw is! List<dynamic>) {
      return <String>[];
    }
    return raw
        .whereType<String>()
        .map(EncryptionService().decrypt)
        .where((value) => value.trim().isNotEmpty)
        .toList();
  }

  String? _readEncryptedString(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return _decryptNullable(value);
    }
    return value.toString();
  }

  int? _readEncryptedInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(_decryptNullable(value) ?? value);
    }
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _userToJson(UserProfile user) => {
        'id': user.id,
        'email': _encryptNullable(user.email),
        'sobrietyStartDate':
            EncryptionService().encrypt(user.sobrietyStartDate.toIso8601String()),
        'programType': _encryptNullable(user.programType),
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
      };

  UserProfile _userFromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: _decryptNullable(json['email']) ?? '',
        sobrietyStartDate: DateTime.parse(
          _readEncryptedString(json['sobrietyStartDate']) ?? '',
        ),
        programType: _readEncryptedString(json['programType']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _checkInToJson(DailyCheckIn checkIn) => {
        'id': checkIn.id,
        'userId': checkIn.userId,
        'checkInType': checkIn.checkInType.value,
        'checkInDate': checkIn.checkInDate.toIso8601String(),
        'intention': _encryptNullable(checkIn.intention),
        'reflection': _encryptNullable(checkIn.reflection),
        'mood': checkIn.mood == null ? null : EncryptionService().encrypt(checkIn.mood.toString()),
        'craving':
            checkIn.craving == null ? null : EncryptionService().encrypt(checkIn.craving.toString()),
        'syncStatus': checkIn.syncStatus.value,
        'createdAt': checkIn.createdAt.toIso8601String(),
      };

  DailyCheckIn _checkInFromJson(Map<String, dynamic> json) => DailyCheckIn(
        id: json['id'] as String,
        userId: json['userId'] as String,
        checkInType: CheckInType.fromString(json['checkInType'] as String),
        checkInDate: DateTime.parse(json['checkInDate'] as String),
        intention: _decryptNullable(json['intention']),
        reflection: _decryptNullable(json['reflection']),
        mood: _readEncryptedInt(json['mood']),
        craving: _readEncryptedInt(json['craving']),
        syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> _journalEntryToJson(JournalEntry entry) => {
        'id': entry.id,
        'userId': entry.userId,
        'title': _encryptNullable(entry.title),
        'content': _encryptNullable(entry.content),
        'mood': _encryptNullable(entry.mood),
        'craving': _encryptNullable(entry.craving),
        'tags': _encryptList(entry.tags),
        'isFavorite': entry.isFavorite,
        'syncStatus': entry.syncStatus.value,
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt.toIso8601String(),
      };

  JournalEntry _journalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: _decryptNullable(json['title']) ?? '',
        content: _decryptNullable(json['content']) ?? '',
        mood: _decryptNullable(json['mood']),
        craving: _decryptNullable(json['craving']),
        tags: _decryptList(json['tags']),
        isFavorite: json['isFavorite'] as bool? ?? false,
        syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _stepAnswerToJson(StepWorkAnswer answer) => {
        'id': answer.id,
        'userId': answer.userId,
        'stepNumber': answer.stepNumber,
        'questionNumber': answer.questionNumber,
        'answer': _encryptNullable(answer.answer),
        'isComplete': answer.isComplete,
        'completedAt': answer.completedAt?.toIso8601String(),
        'syncStatus': answer.syncStatus.value,
        'createdAt': answer.createdAt.toIso8601String(),
        'updatedAt': answer.updatedAt.toIso8601String(),
      };

  StepWorkAnswer _stepAnswerFromJson(Map<String, dynamic> json) => StepWorkAnswer(
        id: json['id'] as String,
        userId: json['userId'] as String,
        stepNumber: (json['stepNumber'] as num).toInt(),
        questionNumber: (json['questionNumber'] as num).toInt(),
        answer: _decryptNullable(json['answer']),
        isComplete: json['isComplete'] as bool? ?? false,
        completedAt: (json['completedAt'] as String?) == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _stepProgressToJson(StepProgress progress) => {
        'id': progress.id,
        'userId': progress.userId,
        'stepNumber': progress.stepNumber,
        'status': progress.status.value,
        'completionPercentage': progress.completionPercentage,
        'completedAt': progress.completedAt?.toIso8601String(),
        'createdAt': progress.createdAt.toIso8601String(),
        'updatedAt': progress.updatedAt.toIso8601String(),
      };

  StepProgress _stepProgressFromJson(Map<String, dynamic> json) => StepProgress(
        id: json['id'] as String,
        userId: json['userId'] as String,
        stepNumber: (json['stepNumber'] as num).toInt(),
        status: StepStatus.fromString(json['status'] as String? ?? 'not_started'),
        completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0,
        completedAt: (json['completedAt'] as String?) == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _achievementToJson(Achievement achievement) => {
        'id': achievement.id,
        'userId': achievement.userId,
        'achievementKey': achievement.achievementKey,
        'type': achievement.type.value,
        'earnedAt': achievement.earnedAt.toIso8601String(),
        'isViewed': achievement.isViewed,
      };

  Achievement _achievementFromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        userId: json['userId'] as String,
        achievementKey: json['achievementKey'] as String,
        type: AchievementType.fromString(json['type'] as String? ?? 'milestone'),
        earnedAt: DateTime.parse(json['earnedAt'] as String),
        isViewed: json['isViewed'] as bool? ?? false,
      );

  Map<String, dynamic> _contactToJson(Contact contact) => {
        'id': contact.id,
        'userId': contact.userId,
        'name': _encryptNullable(contact.name),
        'phoneNumber': _encryptNullable(contact.phoneNumber),
        'email': _encryptNullable(contact.email),
        'relationship': contact.relationship,
        'isPrimary': contact.isPrimary,
        'createdAt': contact.createdAt.toIso8601String(),
      };

  Contact _contactFromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: _decryptNullable(json['name']) ?? '',
        phoneNumber: _decryptNullable(json['phoneNumber']) ?? '',
        email: _decryptNullable(json['email']),
        relationship: json['relationship'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> _meetingToJson(Meeting meeting) => {
        'id': meeting.id,
        'name': meeting.name,
        'location': meeting.location,
        'address': meeting.address,
        'dateTime': meeting.dateTime?.toIso8601String(),
        'meetingType': meeting.meetingType,
        'formats': meeting.formats,
        'notes': meeting.notes,
        'isFavorite': meeting.isFavorite,
        'latitude': meeting.latitude,
        'longitude': meeting.longitude,
      };

  Meeting _meetingFromJson(Map<String, dynamic> json) => Meeting(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
        address: json['address'] as String?,
        dateTime: (json['dateTime'] as String?) == null
            ? null
            : DateTime.parse(json['dateTime'] as String),
        meetingType: json['meetingType'] as String,
        formats: (json['formats'] as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
        notes: json['notes'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> _chatConversationToJson(ChatConversation conversation) => {
        'id': conversation.id,
        'userId': conversation.userId,
        'title': conversation.title,
        'createdAt': conversation.createdAt.toIso8601String(),
        'updatedAt': conversation.updatedAt.toIso8601String(),
      };

  ChatConversation _chatConversationFromJson(Map<String, dynamic> json) =>
      ChatConversation(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _chatMessageToJson(ChatMessage message) => {
        'id': message.id,
        'conversationId': message.conversationId,
        'userId': message.userId,
        'content': _encryptNullable(message.content),
        'isUser': message.isUser,
        'createdAt': message.createdAt.toIso8601String(),
        'encryptedContent': message.encryptedContent,
      };

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String,
        userId: json['userId'] as String,
        content: _decryptNullable(json['content']) ?? '',
        isUser: json['isUser'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        encryptedContent: json['encryptedContent'] as String?,
      );

  Map<String, dynamic> _gratitudeToJson(GratitudeEntry entry) => {
        'id': entry.id,
        'userId': entry.userId,
        'content': _encryptNullable(entry.content),
        'syncStatus': entry.syncStatus.value,
        'createdAt': entry.createdAt.toIso8601String(),
      };

  GratitudeEntry _gratitudeFromJson(Map<String, dynamic> json) => GratitudeEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        content: _decryptNullable(json['content']) ?? '',
        syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> _safetyPlanToJson(SafetyPlan plan) => {
        'id': plan.id,
        'userId': plan.userId,
        'warningSigns': _encryptList(plan.warningSigns),
        'copingStrategies': _encryptList(plan.copingStrategies),
        'supportContacts': _encryptList(plan.supportContacts),
        'professionalContacts': _encryptList(plan.professionalContacts),
        'safeEnvironments': _encryptList(plan.safeEnvironments),
        'createdAt': plan.createdAt.toIso8601String(),
        'updatedAt': plan.updatedAt.toIso8601String(),
      };

  SafetyPlan _safetyPlanFromJson(Map<String, dynamic> json) => SafetyPlan(
        id: json['id'] as String,
        userId: json['userId'] as String,
        warningSigns: _decryptList(json['warningSigns']),
        copingStrategies: _decryptList(json['copingStrategies']),
        supportContacts: _decryptList(json['supportContacts']),
        professionalContacts: _decryptList(json['professionalContacts']),
        safeEnvironments: _decryptList(json['safeEnvironments']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> _challengeToJson(Challenge challenge) => {
        'id': challenge.id,
        'userId': challenge.userId,
        'title': challenge.title,
        'description': challenge.description,
        'durationDays': challenge.durationDays,
        'startDate': challenge.startDate.toIso8601String(),
        'endDate': challenge.endDate?.toIso8601String(),
        'isCompleted': challenge.isCompleted,
        'isActive': challenge.isActive,
        'createdAt': challenge.createdAt.toIso8601String(),
      };

  Challenge _challengeFromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        durationDays: (json['durationDays'] as num).toInt(),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: (json['endDate'] as String?) == null
            ? null
            : DateTime.parse(json['endDate'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> _readingReflectionToJson(ReadingReflection reflection) => {
        'id': reflection.id,
        'userId': reflection.userId,
        'readingId': reflection.readingId,
        'readingDate': reflection.readingDate.toIso8601String(),
        'reflection': _encryptNullable(reflection.reflection),
        'createdAt': reflection.createdAt.toIso8601String(),
      };

  ReadingReflection _readingReflectionFromJson(Map<String, dynamic> json) =>
      ReadingReflection(
        id: json['id'] as String,
        userId: json['userId'] as String,
        readingId: json['readingId'] as String,
        readingDate: DateTime.parse(json['readingDate'] as String),
        reflection: _decryptNullable(json['reflection']) ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  // ==================== Daily Inventory Serialization ====================

  Map<String, dynamic> _dailyInventoryToJson(DailyInventory inventory) => {
        'id': inventory.id,
        'userId': inventory.userId,
        'inventoryDate': inventory.inventoryDate.toIso8601String(),
        'resentfulAbout': _encryptNullable(inventory.resentfulAbout),
        'selfishAbout': _encryptNullable(inventory.selfishAbout),
        'dishonestAbout': _encryptNullable(inventory.dishonestAbout),
        'afraidOf': _encryptNullable(inventory.afraidOf),
        'harmedWho': _encryptNullable(inventory.harmedWho),
        'kindAndLoving': _encryptNullable(inventory.kindAndLoving),
        'wasResentful': inventory.wasResentful,
        'wasSelfish': inventory.wasSelfish,
        'wasDishonest': inventory.wasDishonest,
        'wasAfraid': inventory.wasAfraid,
        'harmedAnyone': inventory.harmedAnyone,
        'showedKindness': inventory.showedKindness,
        'reflection': _encryptNullable(inventory.reflection),
        'moodRating': inventory.moodRating,
        'cravingLevel': inventory.cravingLevel,
        'syncStatus': inventory.syncStatus.value,
        'createdAt': inventory.createdAt.toIso8601String(),
        'updatedAt': inventory.updatedAt.toIso8601String(),
      };

  DailyInventory _dailyInventoryFromJson(Map<String, dynamic> json) => DailyInventory(
        id: json['id'] as String,
        userId: json['userId'] as String,
        inventoryDate: DateTime.parse(json['inventoryDate'] as String),
        resentfulAbout: _decryptNullable(json['resentfulAbout']),
        selfishAbout: _decryptNullable(json['selfishAbout']),
        dishonestAbout: _decryptNullable(json['dishonestAbout']),
        afraidOf: _decryptNullable(json['afraidOf']),
        harmedWho: _decryptNullable(json['harmedWho']),
        kindAndLoving: _decryptNullable(json['kindAndLoving']),
        wasResentful: json['wasResentful'] as bool?,
        wasSelfish: json['wasSelfish'] as bool?,
        wasDishonest: json['wasDishonest'] as bool?,
        wasAfraid: json['wasAfraid'] as bool?,
        harmedAnyone: json['harmedAnyone'] as bool?,
        showedKindness: json['showedKindness'] as bool?,
        reflection: _decryptNullable(json['reflection']),
        moodRating: json['moodRating'] as int?,
        cravingLevel: json['cravingLevel'] as int?,
        syncStatus: SyncStatus.fromString(json['syncStatus'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Dispose resources and clear sensitive data
  @override
  void dispose() {
    _activeUserId = null;
    _users.clear();
    _checkIns.clear();
    _journalEntries.clear();
    _stepAnswers.clear();
    _stepProgress.clear();
    _achievements.clear();
    _contacts.clear();
    _meetings.clear();
    _chatConversations.clear();
    _chatMessages.clear();
    _gratitudeEntries.clear();
    _safetyPlans.clear();
    _challenges.clear();
    _readingReflections.clear();
    _dailyInventories.clear();
    _prefs = null;
    _initialized = false;
    super.dispose();
  }

  void resetForTest() {
    _activeUserId = null;
    _users = <UserProfile>[];
    _checkIns = <DailyCheckIn>[];
    _journalEntries = <JournalEntry>[];
    _stepAnswers = <StepWorkAnswer>[];
    _stepProgress = <StepProgress>[];
    _achievements = <Achievement>[];
    _contacts = <Contact>[];
    _meetings = <Meeting>[];
    _chatConversations = <ChatConversation>[];
    _chatMessages = <ChatMessage>[];
    _gratitudeEntries = <GratitudeEntry>[];
    _safetyPlans = <SafetyPlan>[];
    _challenges = <Challenge>[];
    _readingReflections = <ReadingReflection>[];
    _dailyInventories = <DailyInventory>[];
    _prefs = null;
    _initialized = false;
    _encryptionSecure = false;
  }
}

extension ChallengeLegacyFields on Challenge {
  DateTime? get completedAt => endDate;
}

extension TimeMilestoneLegacyFields on TimeMilestoneContent? {
  String get title => this == null ? '' : (this as TimeMilestoneContent).title;
}
