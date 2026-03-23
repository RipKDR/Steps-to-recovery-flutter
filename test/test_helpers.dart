import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/notification_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

/// Returns the SharedPreferences instance used in the current test.
/// Must be called after [prepareTestState].
Future<SharedPreferences> getTestSharedPreferences() =>
    SharedPreferences.getInstance();

Future<void> prepareTestState() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Disable network font fetching so widget tests run offline
  GoogleFonts.config.allowRuntimeFetching = false;
  // Inject no-op plugin into the NotificationService singleton so tests don't
  // hit uninitialised platform channels (e.g. via MilestoneService).
  NotificationService().setPluginForTest(_NoopNotificationsPlugin());
  SharedPreferences.setMockInitialValues(<String, Object>{});
  PreferencesService().resetForTest();
  FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
    <String, String>{},
  );
  PathProviderPlatform.instance = _FakePathProvider();
  await EncryptionService().initialize();
  await DatabaseService().initialize();
  AppStateService.instance.setReminderSchedulerForTest(
    _NoopReminderScheduler(),
  );
  await AppStateService.instance.initialize();
  await AppStateService.instance.resetLocalData();
  await AppStateService.instance.initialize();
}

Future<void> createSignedInUser({
  String email = 'member@example.com',
  String password = 'password123',
  DateTime? sobrietyDate,
  String? programType = 'NA',
}) async {
  await prepareTestState();
  await AppStateService.instance.completeOnboarding();
  await AppStateService.instance.signUp(
    email: email,
    password: password,
    sobrietyDate: sobrietyDate ?? DateTime(2024, 1, 1),
    programType: programType,
  );
  // Router now gates on sponsor identity — set a default so tests reach home.
  await SponsorService.instance.setupIdentity('Alex', SponsorVibe.warm);
}

class _NoopReminderScheduler implements ReminderScheduler {
  @override
  Future<void> syncDailyCheckInReminders({
    required bool enabled,
    required String morningTime,
    required String eveningTime,
  }) async {}
}

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
}

/// No-op notifications plugin for tests. Prevents platform channel access
/// when MilestoneService / NotificationService are exercised indirectly.
class _NoopNotificationsPlugin implements NotificationsPluginWrapper {
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async => true;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {}

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
  }) async {}

  @override
  Future<void> cancel({required int id}) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool?> requestAndroidPermission() async => true;

  @override
  Future<bool?> requestIOSPermission({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async => true;

  @override
  Future<void> createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {}
}
