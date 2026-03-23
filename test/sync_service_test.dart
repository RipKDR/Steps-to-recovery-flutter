import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/sync_service.dart';

import 'test_helpers.dart';

void main() {
  group('SyncService', () {
    setUp(() async {
      await prepareTestState();
    });

    // ── Availability guard ───────────────────────────────────────

    test('isAvailable is false when Supabase is not configured', () {
      // No --dart-define=SUPABASE_URL in test runs → AppConfig.hasSupabase == false
      expect(SyncService().isAvailable, isFalse);
    });

    test('isSyncing is false initially', () {
      expect(SyncService().isSyncing, isFalse);
    });

    test('lastError is null initially', () {
      expect(SyncService().lastError, isNull);
    });

    test('lastSyncAt is null initially', () {
      expect(SyncService().lastSyncAt, isNull);
    });

    // ── syncAll() no-op guards ───────────────────────────────────

    test('syncAll() completes without error when not available', () async {
      await expectLater(SyncService().syncAll(), completes);
    });

    test('isSyncing is false after syncAll() when not available', () async {
      await SyncService().syncAll();
      expect(SyncService().isSyncing, isFalse);
    });

    test('lastError remains null after no-op syncAll()', () async {
      await SyncService().syncAll();
      expect(SyncService().lastError, isNull);
    });

    // ── Encryption pipeline: critical privacy guarantee ──────────
    //
    // These tests validate that the EncryptionService call used inside
    // _syncCheckIns and _syncJournalEntries produces real ciphertext —
    // not plaintext — before it would be sent to Supabase.

    test('check-in sensitive payload encrypts to non-plaintext', () {
      final payload = jsonEncode({
        'intention': 'Stay sober today',
        'reflection': 'Called my sponsor this morning',
        'mood': 4,
        'craving': 2,
      });

      final ciphertext = EncryptionService().encrypt(payload);

      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(payload)));
      expect(ciphertext.contains('Stay sober today'), isFalse);
      expect(ciphertext.contains('sponsor'), isFalse);
    });

    test('check-in payload decrypts back to original after encryption', () {
      final payload = jsonEncode({
        'intention': 'One day at a time',
        'reflection': 'Gratitude walk helped',
        'mood': 5,
        'craving': 1,
      });

      final ciphertext = EncryptionService().encrypt(payload);
      final decrypted = EncryptionService().decrypt(ciphertext);
      final decoded = jsonDecode(decrypted) as Map<String, dynamic>;

      expect(decoded['intention'], 'One day at a time');
      expect(decoded['reflection'], 'Gratitude walk helped');
      expect(decoded['mood'], 5);
      expect(decoded['craving'], 1);
    });

    test('journal entry sensitive payload encrypts to non-plaintext', () {
      final payload = jsonEncode({
        'title': 'My recovery journal',
        'content': 'Today was hard but I stayed clean.',
        'mood': 'grateful',
        'craving': 'low',
        'tags': ['gratitude', 'sponsor'],
      });

      final ciphertext = EncryptionService().encrypt(payload);

      expect(ciphertext, isNotEmpty);
      expect(ciphertext, isNot(equals(payload)));
      expect(ciphertext.contains('My recovery journal'), isFalse);
      expect(ciphertext.contains('stayed clean'), isFalse);
    });

    test('journal entry payload round-trips through encrypt/decrypt', () {
      final tags = ['gratitude', 'sponsor'];
      final payload = jsonEncode({
        'title': 'Hard day',
        'content': 'Stayed clean through a craving.',
        'mood': 'hopeful',
        'craving': 'moderate',
        'tags': tags,
      });

      final decrypted = EncryptionService().decrypt(
        EncryptionService().encrypt(payload),
      );
      final decoded = jsonDecode(decrypted) as Map<String, dynamic>;

      expect(decoded['title'], 'Hard day');
      expect(decoded['content'], 'Stayed clean through a craving.');
      expect(List<String>.from(decoded['tags'] as List<dynamic>), tags);
    });
  });
}
