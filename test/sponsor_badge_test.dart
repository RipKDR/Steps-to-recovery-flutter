// test/sponsor_badge_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorService badge', () {
    late SponsorService svc;

    setUp(() {
      svc = SponsorService.createForTest();
    });

    test('hasPendingMessage is false by default', () {
      expect(svc.hasPendingMessage, isFalse);
      expect(svc.pendingMessagePreview, isNull);
    });

    test('clearPendingMessage resets badge', () async {
      // Manually set via internal test helper
      svc.setTestPendingMessage('Hello');
      expect(svc.hasPendingMessage, isTrue);
      
      svc.clearPendingMessage();
      expect(svc.hasPendingMessage, isFalse);
      expect(svc.pendingMessagePreview, isNull);
    });

    test('setTestPendingMessage sets badge', () {
      svc.setTestPendingMessage('Test message preview');
      expect(svc.hasPendingMessage, isTrue);
      expect(svc.pendingMessagePreview, 'Test message preview');
    });
  });
}
