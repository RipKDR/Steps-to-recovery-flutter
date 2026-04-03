// test/sponsor_memory_store_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_memory_store.dart';

import 'test_helpers.dart';

// Fake path provider that returns a temp dir
class FakePathProvider extends PathProviderPlatform {
  final String path;
  FakePathProvider(this.path);
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory tempDir;
  late SponsorMemoryStore store;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform({});
    tempDir = await Directory.systemTemp.createTemp('sponsor_test_');
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
    await EncryptionService().initialize();
    store = SponsorMemoryStore();
    await store.initialize();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('starts empty', () async {
    expect(store.session, isEmpty);
    expect(store.digest, isEmpty);
    expect(store.longterm, isEmpty);
  });

  test('addToSession persists across re-init', () async {
    final memory = SponsorMemory(
      id: 'id1',
      category: MemoryCategory.lifeContext,
      summary: 'Works in software.',
      createdAt: DateTime.now(),
    );
    await store.addToSession(memory);

    final store2 = SponsorMemoryStore();
    await store2.initialize();
    expect(store2.session, hasLength(1));
    expect(store2.session.first.summary, 'Works in software.');
  });

  test('digestSession extracts up to 3 entries and clears session', () async {
    for (var i = 0; i < 5; i++) {
      await store.addToSession(SponsorMemory(
        id: 'id$i',
        category: MemoryCategory.recoveryPattern,
        summary: 'Memory $i',
        createdAt: DateTime.now(),
      ));
    }
    await store.digestSession();
    expect(store.session, isEmpty);
    expect(store.digest.length, lessThanOrEqualTo(3));
  });

  test('digest is capped at 20 entries', () async {
    for (var i = 0; i < 25; i++) {
      await store.addToSession(SponsorMemory(
        id: 'id$i',
        category: MemoryCategory.whatWorks,
        summary: 'Entry $i',
        createdAt: DateTime.now(),
      ));
      await store.digestSession();
    }
    expect(store.digest.length, lessThanOrEqualTo(20));
  });

  test('deleteMemory removes from any tier', () async {
    final memory = SponsorMemory(
      id: 'del1',
      category: MemoryCategory.hardMoment,
      summary: 'A hard moment.',
      createdAt: DateTime.now(),
    );
    await store.addToSession(memory);
    await store.deleteMemory('del1');
    expect(store.session.any((m) => m.id == 'del1'), isFalse);
  });

  test('longterm is capped at 50 entries after distillToLongTerm', () async {
    // Fill digest with many entries
    for (var i = 0; i < 30; i++) {
      await store.addToSession(SponsorMemory(
        id: 'lt$i',
        category: MemoryCategory.whatWorks,
        summary: 'Longterm $i',
        createdAt: DateTime.now(),
      ));
    }
    // Digest multiple times to fill digest
    for (var i = 0; i < 10; i++) {
      await store.digestSession();
    }
    await store.distillToLongTerm();
    
    // Add more and distill again
    for (var i = 30; i < 60; i++) {
      await store.addToSession(SponsorMemory(
        id: 'lt$i',
        category: MemoryCategory.whatWorks,
        summary: 'Longterm $i',
        createdAt: DateTime.now(),
      ));
    }
    for (var i = 0; i < 10; i++) {
      await store.digestSession();
    }
    await store.distillToLongTerm();
    
    expect(store.longterm.length, lessThanOrEqualTo(50));
  });

  test('getContextMemories returns all tiers combined', () async {
    // Add to session
    await store.addToSession(SponsorMemory(
      id: 's1',
      category: MemoryCategory.lifeContext,
      summary: 'Session memory',
      createdAt: DateTime.now(),
    ));
    
    // Move to digest
    await store.digestSession();
    
    // Add more to session
    await store.addToSession(SponsorMemory(
      id: 's2',
      category: MemoryCategory.recoveryPattern,
      summary: 'Another session',
      createdAt: DateTime.now(),
    ));
    
    final context = store.getContextMemories();
    expect(context.length, 2); // 1 in digest + 1 in session
  });

  test('distillToLongTerm marks distilledAt', () async {
    await store.addToSession(SponsorMemory(
      id: 'toDistill',
      category: MemoryCategory.whatWorks,
      summary: 'Will be distilled',
      createdAt: DateTime.now(),
    ));
    await store.digestSession();
    
    final before = store.digest.first.distilledAt;
    expect(before, isNull);
    
    await store.distillToLongTerm();
    
    final after = store.longterm.first.distilledAt;
    expect(after, isNotNull);
  });
}
