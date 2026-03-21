import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/notification_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

Future<void> prepareTestState() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  PreferencesService().resetForTest();
  FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
    <String, String>{},
  );
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
}

class _NoopReminderScheduler implements ReminderScheduler {
  @override
  Future<void> syncDailyCheckInReminders({
    required bool enabled,
    required String morningTime,
    required String eveningTime,
  }) async {}
}
