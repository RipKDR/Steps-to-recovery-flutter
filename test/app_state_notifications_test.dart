import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/notification_service.dart';

import 'test_helpers.dart';

void main() {
  test(
    'reminder preference changes sync the scheduler with the latest settings',
    () async {
      await prepareTestState();
      final scheduler = _FakeReminderScheduler();
      AppStateService.instance.setReminderSchedulerForTest(scheduler);

      await AppStateService.instance.initialize();
      await AppStateService.instance.setMorningReminderTime('07:15');
      await AppStateService.instance.setEveningReminderTime('21:45');
      await AppStateService.instance.setNotificationsEnabled(false);

      expect(scheduler.calls, hasLength(3));
      expect(
        scheduler.calls[0],
        const _ReminderSyncCall(
          enabled: true,
          morningTime: '07:15',
          eveningTime: '20:00',
        ),
      );
      expect(
        scheduler.calls[1],
        const _ReminderSyncCall(
          enabled: true,
          morningTime: '07:15',
          eveningTime: '21:45',
        ),
      );
      expect(
        scheduler.calls[2],
        const _ReminderSyncCall(
          enabled: false,
          morningTime: '07:15',
          eveningTime: '21:45',
        ),
      );
    },
  );
}

class _FakeReminderScheduler implements ReminderScheduler {
  final List<_ReminderSyncCall> calls = <_ReminderSyncCall>[];

  @override
  Future<void> syncDailyCheckInReminders({
    required bool enabled,
    required String morningTime,
    required String eveningTime,
  }) async {
    calls.add(
      _ReminderSyncCall(
        enabled: enabled,
        morningTime: morningTime,
        eveningTime: eveningTime,
      ),
    );
  }
}

class _ReminderSyncCall {
  const _ReminderSyncCall({
    required this.enabled,
    required this.morningTime,
    required this.eveningTime,
  });

  final bool enabled;
  final String morningTime;
  final String eveningTime;

  @override
  bool operator ==(Object other) {
    return other is _ReminderSyncCall &&
        other.enabled == enabled &&
        other.morningTime == morningTime &&
        other.eveningTime == eveningTime;
  }

  @override
  int get hashCode => Object.hash(enabled, morningTime, eveningTime);
}
