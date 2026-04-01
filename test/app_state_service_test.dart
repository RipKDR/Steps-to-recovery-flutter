import 'test_helpers.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await prepareTestState();
    PreferencesService().resetForTest();
    EncryptionService().resetForTest();
    DatabaseService().resetForTest();
    AppStateService.instance.resetForTest();
  });

  tearDown(() {
    AppStateService.instance.resetForTest();
    DatabaseService().resetForTest();
    EncryptionService().resetForTest();
  });

  test('hydrates legacy plaintext recovery prefs on initialize', () async {
    final prefs = await SharedPreferences.getInstance();
    final sobrietyDate = DateTime(2024, 1, 1);

    await prefs.setBool('app_signed_in', true);
    await prefs.setString('app_session_token', 'legacy-session-token');
    await prefs.setString('app_user_id', 'legacy-user');
    await prefs.setString('app_email', 'legacy@example.com');
    await prefs.setString('sobriety_date', sobrietyDate.toIso8601String());
    await prefs.setString('program_type', 'AA');

    await AppStateService.instance.initialize();

    expect(AppStateService.instance.isAuthenticated, isTrue);
    expect(AppStateService.instance.currentUserId, 'legacy-user');
    expect(AppStateService.instance.email, 'legacy@example.com');
    expect(AppStateService.instance.sobrietyDate, sobrietyDate);
    expect(AppStateService.instance.programType, 'AA');
  });
}
