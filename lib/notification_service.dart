import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminders({
    required bool morningEnabled,
    required bool eveningEnabled,
  }) async {
    await initialize();
    await cancelReminderNotifications();

    if (morningEnabled) {
      await _scheduleDaily(
        id: 1001,
        title: 'Morning intention',
        body: 'Take a minute to set your direction for today.',
        hour: 8,
        minute: 0,
      );
    }

    if (eveningEnabled) {
      await _scheduleDaily(
        id: 1002,
        title: 'Evening pulse',
        body: 'Close out your day with a quick check-in.',
        hour: 20,
        minute: 0,
      );
    }
  }

  Future<void> cancelReminderNotifications() async {
    await _plugin.cancel(1001);
    await _plugin.cancel(1002);
  }

  Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      1099,
      'Recovery companion',
      'This is a test reminder. You are doing better than you think.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recovery_test',
          'Recovery test notifications',
          channelDescription: 'Manual test notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recovery_reminders',
          'Recovery reminders',
          channelDescription: 'Morning and evening recovery reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
