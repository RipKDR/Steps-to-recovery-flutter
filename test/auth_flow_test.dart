import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';

import 'test_helpers.dart';

void main() {
  group('AppStateService auth flow', () {
    setUp(() async {
      await prepareTestState();
      await AppStateService.instance.completeOnboarding();
    });

    // ── signUp ────────────────────────────────────────────────────

    test('signUp sets isAuthenticated and currentUserId', () async {
      await AppStateService.instance.signUp(
        email: 'alice@example.com',
        password: 'password123',
        sobrietyDate: DateTime(2024, 1, 1),
      );

      expect(AppStateService.instance.isAuthenticated, isTrue);
      expect(AppStateService.instance.currentUserId, isNotNull);
      expect(AppStateService.instance.email, 'alice@example.com');
    });

    test('signUp stores password hash, not plaintext', () async {
      const password = 'hunter2secret';

      await AppStateService.instance.signUp(
        email: 'bob@example.com',
        password: password,
      );

      // The accounts blob stored in SharedPreferences is AES-encrypted.
      // The raw prefs value should contain neither the plaintext password
      // nor any recognisable fragment of it.
      final prefs = await getTestSharedPreferences();
      final raw = prefs.getString('app_accounts_v1') ?? '';

      // Verify stored value is encrypted (non-empty ciphertext)
      expect(raw, isNotEmpty);
      expect(raw.contains(password), isFalse);

      // Decrypt and confirm the password hash is a SHA-256 hex string, not
      // the original password.
      final decrypted = EncryptionService().decrypt(raw);
      expect(decrypted.contains(password), isFalse);
      // SHA-256 produces 64-char hex — a rough sanity-check
      expect(
        RegExp(r'[a-f0-9]{64}').hasMatch(decrypted),
        isTrue,
        reason: 'Expected a SHA-256 hash in the stored account blob',
      );
    });

    test('signUp duplicate email throws StateError', () async {
      await AppStateService.instance.signUp(
        email: 'carol@example.com',
        password: 'password123',
      );

      await expectLater(
        AppStateService.instance.signUp(
          email: 'carol@example.com',
          password: 'different456',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('signUp with short password throws ArgumentError', () async {
      await expectLater(
        AppStateService.instance.signUp(
          email: 'dave@example.com',
          password: 'short',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    // ── signIn ────────────────────────────────────────────────────

    test('signIn with correct credentials authenticates user', () async {
      await AppStateService.instance.signUp(
        email: 'eve@example.com',
        password: 'password123',
        sobrietyDate: DateTime(2023, 6, 15),
      );
      await AppStateService.instance.signOut();

      await AppStateService.instance.signIn(
        email: 'eve@example.com',
        password: 'password123',
      );

      expect(AppStateService.instance.isAuthenticated, isTrue);
      expect(AppStateService.instance.currentUserId, isNotNull);
      expect(AppStateService.instance.email, 'eve@example.com');
    });

    test('signIn with wrong password throws StateError', () async {
      await AppStateService.instance.signUp(
        email: 'frank@example.com',
        password: 'correcthorse',
      );
      await AppStateService.instance.signOut();

      await expectLater(
        AppStateService.instance.signIn(
          email: 'frank@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<StateError>()),
      );

      expect(AppStateService.instance.isAuthenticated, isFalse);
    });

    test('signIn with unknown email throws StateError', () async {
      await expectLater(
        AppStateService.instance.signIn(
          email: 'nobody@example.com',
          password: 'password123',
        ),
        throwsA(isA<StateError>()),
      );
    });

    // ── signOut ───────────────────────────────────────────────────

    test('signOut clears authentication state', () async {
      await AppStateService.instance.signUp(
        email: 'grace@example.com',
        password: 'password123',
      );
      expect(AppStateService.instance.isAuthenticated, isTrue);

      await AppStateService.instance.signOut();

      expect(AppStateService.instance.isAuthenticated, isFalse);
      expect(AppStateService.instance.currentUserId, isNull);
      expect(AppStateService.instance.email, isNull);
    });

    test('signOut clears session token and preserves recovery metadata', () async {
      await AppStateService.instance.signUp(
        email: 'grace@example.com',
        password: 'password123',
        sobrietyDate: DateTime(2024, 1, 1),
        programType: 'AA',
      );

      final prefs = await getTestSharedPreferences();
      final encryptedSessionToken = prefs.getString('app_session_token');
      final encryptedSobrietyDate = prefs.getString('sobriety_date');
      final encryptedProgramType = prefs.getString('program_type');

      expect(encryptedSessionToken, isNotNull);
      expect(encryptedSobrietyDate, isNotNull);
      expect(encryptedProgramType, isNotNull);
      expect(encryptedSessionToken, contains(':'));
      expect(encryptedSobrietyDate, contains(':'));
      expect(encryptedProgramType, contains(':'));
      expect(EncryptionService().decrypt(encryptedSessionToken!), isNotEmpty);
      expect(
        EncryptionService().decrypt(encryptedSobrietyDate!),
        startsWith('2024-01-01'),
      );
      expect(EncryptionService().decrypt(encryptedProgramType!), 'AA');

      await AppStateService.instance.signOut();

      await prefs.reload();
      expect(prefs.getString('app_session_token'), isNull);

      final storedSobrietyDate = prefs.getString('sobriety_date');
      final storedProgramType = prefs.getString('program_type');
      expect(storedSobrietyDate, isNotNull);
      expect(storedProgramType, isNotNull);
      expect(EncryptionService().decrypt(storedSobrietyDate!), startsWith('2024-01-01'));
      expect(EncryptionService().decrypt(storedProgramType!), 'AA');
    });

    // ── resetLocalData ────────────────────────────────────────────

    test('resetLocalData clears onboardingComplete', () async {
      expect(AppStateService.instance.onboardingComplete, isTrue);

      await AppStateService.instance.resetLocalData();

      expect(AppStateService.instance.onboardingComplete, isFalse);
      expect(AppStateService.instance.isAuthenticated, isFalse);
    });

    // ── sobrietyDays ──────────────────────────────────────────────

    test('sobrietyDays computes correct count for a known date', () async {
      final sobrietyDate = DateTime.now().subtract(const Duration(days: 30));

      await AppStateService.instance.signUp(
        email: 'henry@example.com',
        password: 'password123',
        sobrietyDate: sobrietyDate,
      );

      expect(AppStateService.instance.sobrietyDays, 30);
    });

    test('sobrietyDays returns 0 when sobriety date is not set', () async {
      await AppStateService.instance.signUp(
        email: 'iris@example.com',
        password: 'password123',
      );

      // signUp without sobrietyDate → _sobrietyDate is null
      expect(AppStateService.instance.sobrietyDays, 0);
    });
  });
}
