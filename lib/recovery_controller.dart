import 'package:flutter/foundation.dart';

import 'local_store.dart';
import 'models.dart';
import 'notification_service.dart';

class RecoveryController extends ChangeNotifier {
  RecoveryController({required LocalStore store, required NotificationService notifications})
      : _store = store,
        _notifications = notifications;

  final LocalStore _store;
  final NotificationService _notifications;

  RecoveryData _data = RecoveryData.initial();
  bool _loading = true;

  RecoveryData get data => _data;
  bool get loading => _loading;

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
}
