// test/sponsor_hooks_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorService hooks', () {
    late SponsorService svc;

    setUp(() {
      svc = SponsorService.createForTest();
    });

    test('onReturnFromSilence sets pending message when >3 days', () async {
      await svc.onReturnFromSilence(4);
      expect(svc.hasPendingMessage, isTrue);
      expect(svc.pendingMessagePreview, contains('4 days'));
    });

    test('onReturnFromSilence does NOT set message for <=3 days', () async {
      await svc.onReturnFromSilence(2);
      expect(svc.hasPendingMessage, isFalse);
    });

    test('onMilestoneReached always sets pending message', () async {
      await svc.onMilestoneReached(90);
      expect(svc.hasPendingMessage, isTrue);
      expect(svc.pendingMessagePreview, contains('90 days'));
    });

    test('onChallengeCompleted sets message with challenge name', () async {
      await svc.onChallengeCompleted('30-Day Gratitude');
      expect(svc.hasPendingMessage, isTrue);
      expect(svc.pendingMessagePreview, contains('30-Day Gratitude'));
    });
  });
}
