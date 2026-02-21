import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'local_store.dart';
import 'models.dart';
import 'notification_service.dart';
import 'sync.dart';

class RecoveryController extends ChangeNotifier {
  RecoveryController({
    required LocalStore store,
    required NotificationService notifications,
    RecoveryRepository? remote,
  })  : _store = store,
        _notifications = notifications,
        _remote = remote;

  final LocalStore _store;
  final NotificationService _notifications;
  final RecoveryRepository? _remote;
  final PendingSyncQueue _queue = PendingSyncQueue();

  RecoveryData _data = RecoveryData.initial();
  bool _loading = true;
  bool _syncing = false;
  String? _lastSyncMessage;

  RecoveryData get data => _data;
  bool get loading => _loading;
  bool get syncing => _syncing;
  String? get lastSyncMessage => _lastSyncMessage;

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    _data = await _store.load();
    await _notifications.initialize();
    await _notifications.scheduleReminders(
      morningEnabled: _data.reminderMorning,
      eveningEnabled: _data.reminderEvening,
    );

    _loading = false;
    notifyListeners();
  }

  Future<void> _set(RecoveryData next) async {
    _data = next.copyWith(updatedAtIso: DateTime.now().toUtc().toIso8601String());
    notifyListeners();
    await _store.save(_data);
    await _queue.enqueue(_data);
  }

  Future<void> toggleMorning() async => _set(_data.copyWith(morningDone: !_data.morningDone));
  Future<void> toggleEvening() async => _set(_data.copyWith(eveningDone: !_data.eveningDone));
  Future<void> incrementStreak() async => _set(_data.copyWith(streakDays: _data.streakDays + 1));
  Future<void> setJournal(String v) async => _set(_data.copyWith(journal: v));

  Future<void> setContacts(List<EmergencyContact> contacts) async => _set(_data.copyWith(contacts: contacts));

  Future<void> setMorningReminder(bool v) async {
    await _set(_data.copyWith(reminderMorning: v));
    await _notifications.requestPermissions();
    await _notifications.scheduleReminders(morningEnabled: _data.reminderMorning, eveningEnabled: _data.reminderEvening);
  }

  Future<void> setEveningReminder(bool v) async {
    await _set(_data.copyWith(reminderEvening: v));
    await _notifications.requestPermissions();
    await _notifications.scheduleReminders(morningEnabled: _data.reminderMorning, eveningEnabled: _data.reminderEvening);
  }

  Future<void> syncNow() async {
    if (_remote == null || _syncing) return;
    _syncing = true;
    _lastSyncMessage = null;
    notifyListeners();

    try {
      final remote = await withRetry(() => _remote.pull());
      if (remote != null && remote.isNewerThan(_data)) {
        _data = remote;
        await _store.save(_data);
      }

      final pendingRaw = await _queue.load();
      for (final raw in pendingRaw) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final pending = RecoveryData.fromJson(map);
        await withRetry(() => _remote.push(pending));
      }

      await withRetry(() => _remote.push(_data));
      await _queue.clear();
      _lastSyncMessage = 'Sync successful';
    } catch (e) {
      _lastSyncMessage = 'Sync failed: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }
}
