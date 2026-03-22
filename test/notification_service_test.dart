import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:steps_recovery_flutter/core/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Fake wrapper that records every call for assertion.
// ---------------------------------------------------------------------------
class FakeNotificationsPlugin implements NotificationsPluginWrapper {
  int initializeCallCount = 0;
  final List<ShowCall> showCalls = [];
  final List<ZonedScheduleCall> zonedScheduleCalls = [];
  final List<int> cancelledIds = [];
  bool cancelAllCalled = false;

  bool androidPermissionRequested = false;
  bool iosPermissionRequested = false;
  final List<String> createdChannelIds = [];

  /// Controls the value returned by [requestAndroidPermission].
  bool? androidPermissionResult;

  /// Controls the value returned by [requestIOSPermission].
  bool? iosPermissionResult;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    initializeCallCount++;
    return true;
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    showCalls.add(ShowCall(
      id: id,
      title: title,
      body: body,
      payload: payload,
    ));
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    zonedScheduleCalls.add(ZonedScheduleCall(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      matchDateTimeComponents: matchDateTimeComponents,
    ));
  }

  @override
  Future<void> cancel({required int id}) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCalled = true;
  }

  @override
  Future<bool?> requestAndroidPermission() async {
    androidPermissionRequested = true;
    return androidPermissionResult;
  }

  @override
  Future<bool?> requestIOSPermission({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    iosPermissionRequested = true;
    return iosPermissionResult;
  }

  @override
  Future<void> createAndroidNotificationChannel(
      AndroidNotificationChannel channel) async {
    createdChannelIds.add(channel.id);
  }
}

class ShowCall {
  ShowCall({required this.id, this.title, this.body, this.payload});
  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class ZonedScheduleCall {
  ZonedScheduleCall({
    required this.id,
    this.title,
    this.body,
    this.scheduledDate,
    this.matchDateTimeComponents,
  });
  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime? scheduledDate;
  final DateTimeComponents? matchDateTimeComponents;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  late FakeNotificationsPlugin fakePlugin;
  late NotificationService service;

  setUp(() {
    fakePlugin = FakeNotificationsPlugin();
    service = NotificationService.forTesting(fakePlugin);
  });

  // 1. initialize() can be called multiple times safely (idempotent)
  test('initialize() can be called multiple times safely', () async {
    await service.initialize();
    await service.initialize();
    await service.initialize();

    // The plugin's initialize should only be called once because the service
    // short-circuits after the first successful initialization.
    expect(fakePlugin.initializeCallCount, 1);
  });

  // 2. requestPermissions() calls platform-specific implementations
  test('requestPermissions() calls platform-specific implementations',
      () async {
    await service.initialize();

    final result = await service.requestPermissions();

    expect(fakePlugin.androidPermissionRequested, isTrue);
    expect(fakePlugin.iosPermissionRequested, isTrue);
    // Both return null by default, so result should be false.
    expect(result, isFalse);
  });

  test('requestPermissions() returns true when Android grants permission',
      () async {
    await service.initialize();
    fakePlugin.androidPermissionResult = true;

    final result = await service.requestPermissions();
    expect(result, isTrue);
  });

  test('requestPermissions() returns true when iOS grants permission',
      () async {
    await service.initialize();
    fakePlugin.iosPermissionResult = true;

    final result = await service.requestPermissions();
    expect(result, isTrue);
  });

  // 3. showNotification() calls plugin.show with correct named parameters
  test('showNotification() calls plugin.show with correct parameters',
      () async {
    await service.initialize();

    await service.showNotification(
      id: 42,
      title: 'Test Title',
      body: 'Test Body',
      payload: 'test-payload',
    );

    expect(fakePlugin.showCalls, hasLength(1));
    final call = fakePlugin.showCalls.first;
    expect(call.id, 42);
    expect(call.title, 'Test Title');
    expect(call.body, 'Test Body');
    expect(call.payload, 'test-payload');
  });

  test('showNotification() auto-initializes if not already initialized',
      () async {
    // Do NOT call initialize() first.
    await service.showNotification(
      id: 1,
      title: 'Auto',
      body: 'Init',
    );

    expect(fakePlugin.initializeCallCount, 1);
    expect(fakePlugin.showCalls, hasLength(1));
  });

  // 4. scheduleDailyCheckIn() schedules with correct time
  test('scheduleDailyCheckIn() schedules with correct time and repeats daily',
      () async {
    await service.initialize();

    await service.scheduleDailyCheckIn(
      id: 99,
      title: 'Check In',
      body: 'Time to check in',
      time: const TimeOfDay(hour: 9, minute: 30),
    );

    expect(fakePlugin.zonedScheduleCalls, hasLength(1));
    final call = fakePlugin.zonedScheduleCalls.first;
    expect(call.id, 99);
    expect(call.title, 'Check In');
    expect(call.body, 'Time to check in');
    expect(call.matchDateTimeComponents, DateTimeComponents.time);
    // The scheduled date should have hour=9, minute=30.
    expect(call.scheduledDate!.hour, 9);
    expect(call.scheduledDate!.minute, 30);
  });

  // 5. cancelNotification() calls plugin.cancel with correct id
  test('cancelNotification() calls plugin.cancel with correct id', () async {
    await service.cancelNotification(55);

    expect(fakePlugin.cancelledIds, [55]);
  });

  // 6. cancelAllNotifications() calls plugin.cancelAll
  test('cancelAllNotifications() calls plugin.cancelAll', () async {
    await service.cancelAllNotifications();

    expect(fakePlugin.cancelAllCalled, isTrue);
  });

  // 7. syncDailyCheckInReminders with enabled=false cancels both reminders
  test(
      'syncDailyCheckInReminders with enabled=false cancels both reminders '
      'and does not schedule', () async {
    await service.syncDailyCheckInReminders(
      enabled: false,
      morningTime: '08:00',
      eveningTime: '20:00',
    );

    // Both reminder ids should have been cancelled.
    expect(
      fakePlugin.cancelledIds,
      containsAll([
        NotificationService.morningCheckInReminderId,
        NotificationService.eveningCheckInReminderId,
      ]),
    );

    // No notifications should have been scheduled.
    expect(fakePlugin.zonedScheduleCalls, isEmpty);
  });

  // 8. syncDailyCheckInReminders with enabled=true schedules both reminders
  test(
      'syncDailyCheckInReminders with enabled=true and permissions granted '
      'schedules both reminders', () async {
    fakePlugin.androidPermissionResult = true;

    await service.syncDailyCheckInReminders(
      enabled: true,
      morningTime: '07:00',
      eveningTime: '21:00',
    );

    // Both cancels should happen first.
    expect(
      fakePlugin.cancelledIds,
      containsAll([
        NotificationService.morningCheckInReminderId,
        NotificationService.eveningCheckInReminderId,
      ]),
    );

    // Two scheduled notifications (morning + evening).
    expect(fakePlugin.zonedScheduleCalls, hasLength(2));
    expect(fakePlugin.zonedScheduleCalls[0].id,
        NotificationService.morningCheckInReminderId);
    expect(fakePlugin.zonedScheduleCalls[0].title, 'Morning intention');
    expect(fakePlugin.zonedScheduleCalls[1].id,
        NotificationService.eveningCheckInReminderId);
    expect(fakePlugin.zonedScheduleCalls[1].title, 'Evening pulse');
  });

  test(
      'syncDailyCheckInReminders with enabled=true but no permissions '
      'does not schedule', () async {
    // Both permission results are null (default) -> returns false.
    await service.syncDailyCheckInReminders(
      enabled: true,
      morningTime: '07:00',
      eveningTime: '21:00',
    );

    // Cancels still happen.
    expect(fakePlugin.cancelledIds, hasLength(2));
    // No scheduling because permissions were not granted.
    expect(fakePlugin.zonedScheduleCalls, isEmpty);
  });

  // 9. _parseTimeOfDay returns fallback for invalid input
  group('parseTimeOfDay', () {
    test('returns correct TimeOfDay for valid input', () {
      final result = service.parseTimeOfDay(
        '14:30',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 14, minute: 30));
    });

    test('returns fallback for empty string', () {
      final result = service.parseTimeOfDay(
        '',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for non-numeric input', () {
      final result = service.parseTimeOfDay(
        'ab:cd',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for out-of-range hour', () {
      final result = service.parseTimeOfDay(
        '25:00',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for out-of-range minute', () {
      final result = service.parseTimeOfDay(
        '12:60',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for negative values', () {
      final result = service.parseTimeOfDay(
        '-1:30',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for missing colon', () {
      final result = service.parseTimeOfDay(
        '1430',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });

    test('returns fallback for too many segments', () {
      final result = service.parseTimeOfDay(
        '14:30:00',
        fallback: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(result, const TimeOfDay(hour: 8, minute: 0));
    });
  });

  group('scheduleMilestoneApproachReminder', () {
    test('schedules notification when trigger date is in the future', () async {
      await service.initialize();
      final future = DateTime.now().add(const Duration(days: 5));
      final milestoneDate = future.add(const Duration(days: 5));

      await service.scheduleMilestoneApproachReminder(
        id: 2001,
        milestoneTitle: '1 Week',
        milestoneDate: milestoneDate,
      );

      expect(fakePlugin.zonedScheduleCalls, hasLength(1));
      final call = fakePlugin.zonedScheduleCalls.first;
      expect(call.id, 2001);
      expect(call.title, contains('5 days'));
      expect(call.title, contains('1 Week'));
    });

    test('skips scheduling when trigger date is in the past', () async {
      await service.initialize();
      final past = DateTime.now().subtract(const Duration(days: 10));

      await service.scheduleMilestoneApproachReminder(
        id: 2001,
        milestoneTitle: '1 Week',
        milestoneDate: past,
      );

      expect(fakePlugin.zonedScheduleCalls, isEmpty);
    });
  });

  group('cancelMilestoneApproachReminders', () {
    test('cancels IDs 2001 through 2004', () async {
      await service.initialize();
      await service.cancelMilestoneApproachReminders();

      expect(fakePlugin.cancelledIds, containsAll([2001, 2002, 2003, 2004]));
    });
  });
}
