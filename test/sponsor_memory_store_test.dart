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
    SharedPreferences.setMockInitialValues({});
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
    // Fill digest with 60 entries manually via repeated digest calls
    for (var i = 0; i < 60; i++) {
      await store.addToSession(SponsorMemory(
        id: 'lt$i',
        category: MemoryCategory.whatWorks,
        summary: 'Longterm $i',
        createdAt: DateTime.now(),
      ));
    }
    // Force digest to have many entries by directly manipulating (use distill loop)
    for (var i = 0; i < 20; i++) {
      await store.digestSession();
    }
    await store.distillToLongTerm();
    expect(store.longterm.length, lessThanOrEqualTo(50));
  });

  test('distillToLongTerm sets distilledAt on promoted entries', () async {
    await store.addToSession(SponsorMemory(
      id: 'dt1',
      category: MemoryCategory.whatWorks,
      summary: 'Something that helped.',
      createdAt: DateTime.now(),
    ));
    await store.digestSession();
    await store.distillToLongTerm();
    expect(store.longterm, hasLength(1));
    expect(store.longterm.first.distilledAt, isNotNull);
  });

  test('deleteMemory removes from digest and longterm tiers', () async {
    // Add to session, digest it, distill to longterm
    await store.addToSession(SponsorMemory(
      id: 'tier_test',
      category: MemoryCategory.recoveryPattern,
      summary: 'A pattern.',
      createdAt: DateTime.now(),
    ));
    await store.digestSession();
    // Now in digest — delete from digest
    await store.deleteMemory('tier_test');
    expect(store.digest.any((m) => m.id == 'tier_test'), isFalse);

    // Add another, distill to longterm, then delete
    await store.addToSession(SponsorMemory(
      id: 'lt_test',
      category: MemoryCategory.hardMoment,
      summary: 'Hard moment.',
      createdAt: DateTime.now(),
    ));
    await store.digestSession();
    await store.distillToLongTerm();
    await store.deleteMemory('lt_test');
    expect(store.longterm.any((m) => m.id == 'lt_test'), isFalse);
  });
}
