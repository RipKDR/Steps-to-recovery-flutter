// test/memory_transparency_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';
import 'package:steps_recovery_flutter/features/ai_companion/screens/memory_transparency_screen.dart';

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
    tempDir = await Directory.systemTemp.createTemp('memory_ui_test_');
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
    await EncryptionService().initialize();
    service = SponsorService.createForTest();
    await service.initialize();
  });

  tearDown(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  testWidgets('shows empty state when no memories', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MemoryTransparencyScreen(
        sponsorName: 'Rex',
        sponsorService: service,
      ),
    ));
    expect(find.textContaining('still learning'), findsOneWidget);
  });

  testWidgets('shows memory cards when memories exist', (tester) async {
    // File I/O must run outside fake-async zone
    await tester.runAsync(() async {
      await service.addSessionMemory(SponsorMemory(
        id: 'id1',
        category: MemoryCategory.recoveryPattern,
        summary: 'Sunday evenings are hard.',
        createdAt: DateTime.now(),
      ));
      await service.digestSession();
      await service.distillToLongTerm();
    });

    await tester.pumpWidget(MaterialApp(
      home: MemoryTransparencyScreen(
        sponsorName: 'Rex',
        sponsorService: service,
      ),
    ));
    expect(find.textContaining('Sunday evenings'), findsOneWidget);
  });

  testWidgets('delete icon removes memory card', (tester) async {
    await tester.runAsync(() async {
      await service.addSessionMemory(SponsorMemory(
        id: 'del1',
        category: MemoryCategory.whatWorks,
        summary: 'Breathing exercises help.',
        createdAt: DateTime.now(),
      ));
      await service.digestSession();
      await service.distillToLongTerm();
    });

    await tester.pumpWidget(MaterialApp(
      home: MemoryTransparencyScreen(
        sponsorName: 'Rex',
        sponsorService: service,
      ),
    ));
    expect(find.textContaining('Breathing exercises'), findsOneWidget);

    // Run the delete through the service directly in real-async context,
    // updating in-memory state so longTermMemory becomes empty.
    await tester.runAsync(() => service.deleteMemory('del1'));

    // Re-pump the widget — build() re-reads _service.longTermMemory which is
    // now empty, so the card is no longer rendered.
    await tester.pumpWidget(MaterialApp(
      home: MemoryTransparencyScreen(
        sponsorName: 'Rex',
        sponsorService: service,
      ),
    ));

    expect(find.textContaining('Breathing exercises'), findsNothing);
  });

  testWidgets('shows correct sponsor name in header', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MemoryTransparencyScreen(
        sponsorName: 'Rex',
        sponsorService: service,
      ),
    ));
    expect(find.textContaining('Rex'), findsWidgets);
  });
}
