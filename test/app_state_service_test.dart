import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/database_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';
import 'package:steps_recovery_flutter/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PreferencesService().resetForTest();
    EncryptionService().resetForTest();
    DatabaseService().resetForTest();
    AppStateService.instance.resetForTest();
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
  });

  tearDown(() {
    AppStateService.instance.resetForTest();
    DatabaseService().resetForTest();
    EncryptionService().resetForTest();
  });

  test('initialize clears initializing flag and can retry after a failure', () async {
    var attempts = 0;
    AppStateService.instance.setDatabaseInitializerForTest(() async {
      attempts += 1;
      throw StateError('database unavailable');
    });

    await AppStateService.instance.initialize();

    expect(AppStateService.instance.isInitializing, isFalse);
    expect(AppStateService.instance.isReady, isFalse);
    expect(AppStateService.instance.initializationError, isNotNull);
    expect(
      AppStateService.instance.initializationError,
      contains('database unavailable'),
    );

    AppStateService.instance.setDatabaseInitializerForTest(() async {
      attempts += 1;
      await DatabaseService().initialize();
    });

    await AppStateService.instance.initialize();

    expect(attempts, 2);
    expect(AppStateService.instance.isInitializing, isFalse);
    expect(AppStateService.instance.isReady, isTrue);
    expect(AppStateService.instance.initializationError, isNull);
  });

  testWidgets('bootstrap renders a retryable error state after init failure', (
    tester,
  ) async {
    AppStateService.instance.setDatabaseInitializerForTest(() async {
      throw StateError('database unavailable');
    });

    await tester.pumpWidget(const StepsToRecoveryApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Unable to start Steps to Recovery'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining('database unavailable'), findsOneWidget);
  });
}
