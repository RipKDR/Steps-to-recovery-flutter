// test/sponsor_intro_screen_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:steps_recovery_flutter/core/services/encryption_service.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';
import 'package:steps_recovery_flutter/features/ai_companion/screens/sponsor_intro_screen.dart';

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
    tempDir = await Directory.systemTemp.createTemp('intro_test_');
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
    await EncryptionService().initialize();
    service = SponsorService.createForTest();
    await service.initialize();
  });

  tearDown(() => tempDir.delete(recursive: true));

  Widget buildScreen({VoidCallback? onComplete}) => MaterialApp(
    home: SponsorIntroScreen(
      sponsorService: service,
      onComplete: onComplete ?? () {},
    ),
  );

  testWidgets('renders headline and subtext', (tester) async {
    await tester.pumpWidget(buildScreen());
    expect(find.text('One more thing.'), findsOneWidget);
    expect(find.textContaining('sponsor waiting'), findsOneWidget);
  });

  testWidgets('CTA button is disabled when name is empty', (tester) async {
    await tester.pumpWidget(buildScreen());
    // Clear the default placeholder to ensure the field is empty
    final nameField = find.byType(TextFormField);
    await tester.tap(nameField);
    await tester.enterText(nameField, '');
    await tester.pump();
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton).first);
    expect(button.onPressed, isNull);
  });

  testWidgets('CTA button text updates when name is entered', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.enterText(find.byType(TextFormField), 'Rex');
    await tester.pump();
    expect(find.textContaining('Rex'), findsWidgets);
  });

  testWidgets('vibe pills are tappable', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.tap(find.text('Direct'));
    await tester.pump();
    // No crash = pass
  });

  testWidgets('skip creates default identity and calls onComplete', (tester) async {
    bool completed = false;
    await tester.pumpWidget(buildScreen(onComplete: () => completed = true));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(service.hasIdentity, isTrue);
    expect(service.identity!.name, 'Alex');
  });

  testWidgets('submit calls setupIdentity and onComplete', (tester) async {
    bool completed = false;
    await tester.pumpWidget(buildScreen(onComplete: () => completed = true));
    await tester.enterText(find.byType(TextFormField), 'Rex');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(service.identity!.name, 'Rex');
  });
}
