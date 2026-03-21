import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';

Future<void> prepareTestState() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await EncryptionService().initialize();
  await DatabaseService().initialize();
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
