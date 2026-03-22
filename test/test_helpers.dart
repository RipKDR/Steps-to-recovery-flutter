import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/notification_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

Future<void> prepareTestState() async {
  TestWidgetsFlutterBinding.ensureInitialized();
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
