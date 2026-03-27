import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../constants/app_constants.dart';
import 'logger_service.dart';

abstract class ReminderScheduler {
  Future<void> syncDailyCheckInReminders({
    required bool enabled,
    required String morningTime,
    required String eveningTime,
  });
}

/// Thin wrapper around [FlutterLocalNotificationsPlugin] so that
/// [NotificationService] can be unit-tested without platform channels.
abstract class NotificationsPluginWrapper {
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  });

  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  });

  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  });

  Future<void> cancel({required int id});

  Future<void> cancelAll();

  Future<bool?> requestAndroidPermission();

  Future<bool?> requestIOSPermission({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  });

  Future<void> createAndroidNotificationChannel(
      AndroidNotificationChannel channel);
}

/// Default implementation that delegates to the real plugin singleton.
class _RealNotificationsPluginWrapper implements NotificationsPluginWrapper {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) {
    return _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
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
  }) {
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: androidScheduleMode,
      title: title,
      body: body,
      payload: payload,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel({required int id}) {
    return _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }

  @override
  Future<bool?> requestAndroidPermission() {
    return _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        Future.value(null);
  }

  @override
  Future<bool?> requestIOSPermission({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) {
    return _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: alert,
              badge: badge,
              sound: sound,
            ) ??
        Future.value(null);
  }

  @override
  Future<void> createAndroidNotificationChannel(
      AndroidNotificationChannel channel) async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

/// Notification service for local notifications
class NotificationService implements ReminderScheduler {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal()
      : _notifications = _RealNotificationsPluginWrapper();

  /// Constructor exposed for unit testing with a mock plugin wrapper.
  @visibleForTesting
  NotificationService.forTesting(NotificationsPluginWrapper plugin)
      : _notifications = plugin;

  /// Replaces the plugin on the singleton for testing.
  /// Call in test setup to prevent real platform channel access.
  @visibleForTesting
  void setPluginForTest(NotificationsPluginWrapper plugin) {
    _notifications = plugin;
  }

  NotificationsPluginWrapper _notifications;
  bool _isInitialized = false;

  /// Expose [_parseTimeOfDay] for unit testing.
  @visibleForTesting
  TimeOfDay parseTimeOfDay(String value, {required TimeOfDay fallback}) =>
      _parseTimeOfDay(value, fallback: fallback);

  static const int morningCheckInReminderId = 1001;
  static const int eveningCheckInReminderId = 1002;
  static const int milestoneReminder1Id = NotificationIds.milestoneApproachBase + 1;
  static const int milestoneReminder2Id = NotificationIds.milestoneApproachBase + 2;
  static const int milestoneReminder3Id = NotificationIds.milestoneApproachBase + 3;
  static const int milestoneReminder4Id = NotificationIds.milestoneApproachBase + 4;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createChannels();

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    LoggerService().debug('Notification tapped: ${response.payload}');
  }

  Future<void> _createChannels() async {
    const List<AndroidNotificationChannel> channels = [
      AndroidNotificationChannel(
        'check_ins',
        'Check-in Reminders',
        description: 'Morning and evening check-in reminders',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'achievements',
        'Achievements',
        description: 'Milestone and achievement notifications',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'reminders',
        'General Reminders',
        description: 'General app reminders',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _notifications.createAndroidNotificationChannel(channel);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications.requestAndroidPermission();

    final iosGranted = await _notifications.requestIOSPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'reminders',
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'General Reminders',
      channelDescription: 'General app reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'reminders',
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'General Reminders',
      channelDescription: 'General app reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule daily check-in reminders
  Future<void> scheduleDailyCheckIn({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    if (!_isInitialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'check_ins',
      'Check-in Reminders',
      channelDescription: 'Morning and evening check-in reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> syncDailyCheckInReminders({
    required bool enabled,
    required String morningTime,
    required String eveningTime,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    await cancelNotification(morningCheckInReminderId);
    await cancelNotification(eveningCheckInReminderId);

    if (!enabled) {
      return;
    }

    final permissionsGranted = await requestPermissions();
    if (!permissionsGranted) {
      return;
    }

    await scheduleDailyCheckIn(
      id: morningCheckInReminderId,
      title: 'Morning intention',
      body: 'Start the day with a quick recovery check-in.',
      time: _parseTimeOfDay(
        morningTime,
        fallback: const TimeOfDay(hour: 8, minute: 0),
      ),
    );
    await scheduleDailyCheckIn(
      id: eveningCheckInReminderId,
      title: 'Evening pulse',
      body: 'Take a minute to reflect before the day ends.',
      time: _parseTimeOfDay(
        eveningTime,
        fallback: const TimeOfDay(hour: 20, minute: 0),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String value, {required TimeOfDay fallback}) {
    final parts = value.trim().split(':');
    if (parts.length != 2) {
      return fallback;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return fallback;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return fallback;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Schedule a "approaching milestone" reminder.
  ///
  /// Schedules a notification to fire [daysWarning] days before [milestoneDate].
  /// If the trigger date is already in the past, no-ops silently.
  ///
  /// Typical usage: Schedule a "5 days to your 30-day milestone" notification.
  Future<void> scheduleMilestoneApproachReminder({
    required int id,
    required String milestoneTitle,
    required DateTime milestoneDate,
    int daysWarning = 5,
  }) async {
    final triggerDate = milestoneDate.subtract(Duration(days: daysWarning));

    // Skip if trigger date is in the past
    if (triggerDate.isBefore(DateTime.now())) {
      return;
    }

    await scheduleNotification(
      id: id,
      title: '$daysWarning days to your $milestoneTitle milestone!',
      body: "Keep going. You're almost there.",
      scheduledDate: triggerDate,
    );
  }

  /// Cancel all milestone approach reminder notifications.
  ///
  /// Cancels the four standard milestone reminder IDs (2001–2004).
  Future<void> cancelMilestoneApproachReminders() async {
    await _notifications.cancel(id: milestoneReminder1Id);
    await _notifications.cancel(id: milestoneReminder2Id);
    await _notifications.cancel(id: milestoneReminder3Id);
    await _notifications.cancel(id: milestoneReminder4Id);
  }
}
