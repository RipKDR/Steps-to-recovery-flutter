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
    _data = next;
    notifyListeners();
    await _store.save(_data);
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
      final remote = await _remote.pull();
      if (remote != null) {
        _data = remote;
        await _store.save(_data);
      }

      await _remote.push(_data);
      _lastSyncMessage = 'Sync successful';
    } catch (e) {
      _lastSyncMessage = 'Sync failed: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }
}
