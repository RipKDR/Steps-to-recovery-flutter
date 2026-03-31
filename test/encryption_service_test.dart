import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService service;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      PreferencesService().resetForTest();
      EncryptionService().resetForTest();
      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
        <String, String>{},
      );
      service = EncryptionService();
      await service.initialize();
    });

    test('isInitialized returns true after initialize()', () {
      expect(service.isInitialized, isTrue);
    });

    test('encrypt/decrypt round-trip for a simple string', () {
      const plainText = 'Hello, World!';
      final encrypted = service.encrypt(plainText);
      final decrypted = service.decrypt(encrypted);
      expect(decrypted, plainText);
    });

    test('encrypt/decrypt round-trip for unicode/emoji strings', () {
      const plainText = 'Recovery is possible! \u{1F60A}\u{1F4AA}\u{2764}\u{FE0F} - \u00E9\u00E0\u00FC\u00F1';
      final encrypted = service.encrypt(plainText);
      final decrypted = service.decrypt(encrypted);
      expect(decrypted, plainText);
    });

    test('encrypt/decrypt round-trip for empty string', () {
      const plainText = '';
      final encrypted = service.encrypt(plainText);
      final decrypted = service.decrypt(encrypted);
      expect(decrypted, plainText);
    });

    test('encryptList/decryptList round-trip', () {
      final items = ['Step 1', 'Step 2', 'Step 3', 'Gratitude \u{1F64F}'];
      final encrypted = service.encryptList(items);
      expect(encrypted.length, items.length);
      final decrypted = service.decryptList(encrypted);
      expect(decrypted, items);
    });

    test('hash() produces consistent results for same input', () {
      const value = 'test@example.com';
      final hash1 = service.hash(value);
      final hash2 = service.hash(value);
      expect(hash1, hash2);
    });

    test('hash() produces different results for different inputs', () {
      final hash1 = service.hash('input_one');
      final hash2 = service.hash('input_two');
      expect(hash1, isNot(hash2));
    });

    test('deriveKeyFromPassword() returns a Key', () async {
      final key = await service.deriveKeyFromPassword('my_secure_password');
      expect(key.bytes.length, 32);
    });

    test('encrypted output is different from plaintext', () {
      const plainText = 'Sensitive journal entry';
      final encrypted = service.encrypt(plainText);
      expect(encrypted, isNot(plainText));
    });

    test('initialize surfaces secure storage failures explicitly', () async {
      EncryptionService().resetForTest();
      FlutterSecureStoragePlatform.instance = _FailingSecureStoragePlatform();
      final failingService = EncryptionService();

      await expectLater(failingService.initialize(), throwsStateError);

      expect(failingService.isInitialized, isFalse);
      expect(failingService.isSecureStorageAvailable, isFalse);
      expect(
        failingService.initializationError,
        contains('Secure storage is unavailable'),
      );
      expect(
        () => failingService.encrypt('journal entry'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Secure storage is unavailable'),
          ),
        ),
      );
    });
  });
}

class _FailingSecureStoragePlatform extends FlutterSecureStoragePlatform {
  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => false;

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {}

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {}

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    throw StateError('Secure storage read failed');
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    throw StateError('Secure storage write failed');
  }
}
