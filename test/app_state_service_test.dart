import 'test_helpers.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/types.dart';

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
    await prefs.reload();

    expect(AppStateService.instance.isAuthenticated, isTrue);
    expect(AppStateService.instance.currentUserId, 'legacy-user');
    expect(AppStateService.instance.email, 'legacy@example.com');
    expect(AppStateService.instance.sobrietyDate, sobrietyDate);
    expect(AppStateService.instance.programType, 'AA');

    final storedSessionToken = prefs.getString('app_session_token');
    expect(storedSessionToken, isNotNull);
    expect(storedSessionToken, isNot(equals('legacy-session-token')));
    expect(storedSessionToken, contains(':'));
    expect(
      EncryptionService().decrypt(storedSessionToken!),
      'legacy-session-token',
    );

    final storedSobrietyDate = prefs.getString('sobriety_date');
    expect(storedSobrietyDate, isNotNull);
    expect(storedSobrietyDate, contains(':'));
    expect(
      EncryptionService().decrypt(storedSobrietyDate!),
      sobrietyDate.toIso8601String(),
    );

    final storedProgramType = prefs.getString('program_type');
    expect(storedProgramType, isNotNull);
    expect(storedProgramType, contains(':'));
    expect(EncryptionService().decrypt(storedProgramType!), 'AA');
  });

  test('hydrates legacy recovery prefs while signed out and migrates them',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final sobrietyDate = DateTime(2024, 3, 10);

    await prefs.setBool('app_signed_in', false);
    await prefs.setString('sobriety_date', sobrietyDate.toIso8601String());
    await prefs.setString('program_type', 'NA');

    await AppStateService.instance.initialize();
    await prefs.reload();

    expect(AppStateService.instance.isAuthenticated, isFalse);
    expect(AppStateService.instance.sobrietyDate, sobrietyDate);
    expect(AppStateService.instance.programType, 'NA');

    final storedSobrietyDate = prefs.getString('sobriety_date');
    expect(storedSobrietyDate, isNotNull);
    expect(storedSobrietyDate, contains(':'));
    expect(
      EncryptionService().decrypt(storedSobrietyDate!),
      sobrietyDate.toIso8601String(),
    );

    final storedProgramType = prefs.getString('program_type');
    expect(storedProgramType, isNotNull);
    expect(storedProgramType, contains(':'));
    expect(EncryptionService().decrypt(storedProgramType!), 'NA');
  });

  test('initialize clears isInitializing when database initialization fails',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesStorePlatform.instance =
        _FailingSharedPreferencesStorePlatform();
    PreferencesService().resetForTest();
    EncryptionService().resetForTest();
    DatabaseService().resetForTest();
    AppStateService.instance.resetForTest();

    await expectLater(
      AppStateService.instance.initialize(),
      throwsA(isA<StateError>()),
    );

    expect(AppStateService.instance.isInitializing, isFalse);
    expect(AppStateService.instance.isReady, isFalse);
  });
}

class _FailingSharedPreferencesStorePlatform
    extends SharedPreferencesStorePlatform {
  @override
  bool get isMock => true;

  @override
  Future<bool> remove(String key) async {
    throw StateError('SharedPreferences store unavailable');
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    throw StateError('SharedPreferences store unavailable');
  }

  @override
  Future<bool> clear() async {
    throw StateError('SharedPreferences store unavailable');
  }

  @override
  Future<Map<String, Object>> getAll() async {
    throw StateError('SharedPreferences store unavailable');
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    throw StateError('SharedPreferences store unavailable');
  }
}
