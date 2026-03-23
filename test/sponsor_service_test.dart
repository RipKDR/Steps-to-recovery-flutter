import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

class FakePathProvider extends PathProviderPlatform {
  final String path;
  FakePathProvider(this.path);
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory tempDir;
  late SponsorService service;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform({});
    tempDir = await Directory.systemTemp.createTemp('sponsor_svc_test_');
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
    await EncryptionService().initialize();
    service = SponsorService.createForTest();
    await service.initialize();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('Identity', () {
    test('hasIdentity is false on fresh init', () {
      expect(service.hasIdentity, isFalse);
    });

    test('setupIdentity sets name and vibe', () async {
      await service.setupIdentity('Rex', SponsorVibe.warm);
      expect(service.hasIdentity, isTrue);
      expect(service.identity!.name, 'Rex');
      expect(service.identity!.vibe, SponsorVibe.warm);
    });

    test('identity persists across re-init', () async {
      await service.setupIdentity('Alex', SponsorVibe.direct);
      final service2 = SponsorService.createForTest();
      await service2.initialize();
      expect(service2.identity?.name, 'Alex');
    });
  });

  group('Stage', () {
    test('stage is new_ on fresh init', () {
      expect(service.stage, SponsorStage.new_);
    });

    test('bumpEngagement increases score', () async {
      await service.bumpEngagement(checkInDays: 3, chatDays: 2, journalDays: 1);
      expect(service.engagementScore, greaterThan(0));
    });

    test('stage advances to building at score 16', () async {
      // 3 chat days × 3 = 9 + 3 check-in × 2 = 6 + 1 journal × 1 = 1 = 16
      await service.bumpEngagement(checkInDays: 3, chatDays: 3, journalDays: 1);
      expect(service.stage, SponsorStage.building);
    });
  });

  group('Memory', () {
    test('session memory is empty on fresh init', () {
      expect(service.sessionMemory, isEmpty);
    });

    test('addSessionMemory adds to session', () async {
      final memory = SponsorMemory(
        id: 'id1',
        category: MemoryCategory.lifeContext,
        summary: 'Works in tech.',
        createdAt: DateTime.now(),
      );
      await service.addSessionMemory(memory);
      expect(service.sessionMemory, hasLength(1));
    });

    test('digestSession clears session and adds to digest', () async {
      final memory = SponsorMemory(
        id: 'id1',
        category: MemoryCategory.lifeContext,
        summary: 'Test memory.',
        createdAt: DateTime.now(),
      );
      await service.addSessionMemory(memory);
      await service.digestSession();
      expect(service.sessionMemory, isEmpty);
      expect(service.digestMemory, hasLength(1));
    });

    test('deleteMemory removes from any tier', () async {
      final memory = SponsorMemory(
        id: 'del1',
        category: MemoryCategory.hardMoment,
        summary: 'Something hard.',
        createdAt: DateTime.now(),
      );
      await service.addSessionMemory(memory);
      await service.deleteMemory('del1');
      expect(service.sessionMemory.any((m) => m.id == 'del1'), isFalse);
    });
  });

  group('respond()', () {
    test('returns offline response when not connected', () async {
      await service.setupIdentity('Rex', SponsorVibe.warm);
      final response = await service.respond(
        message: 'Hello',
        userId: 'user1',
        isOnline: false,
      );
      expect(response, isNotEmpty);
      // Offline response should not contain typical error messages
      expect(response, isNot(contains('Error')));
    });

    test('falls back to generic prompt when no identity', () async {
      // No setupIdentity called
      final response = await service.respond(
        message: 'Hello',
        userId: 'user1',
        isOnline: false,
      );
      expect(response, isNotEmpty);
    });
  });
}
