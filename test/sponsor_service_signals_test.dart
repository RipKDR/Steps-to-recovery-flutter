// test/sponsor_service_signals_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';
import 'package:steps_recovery_flutter/core/utils/context_assembler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorService._buildSignals', () {
    late SponsorService svc;

    setUp(() {
      svc = SponsorService.createForTest();
    });

    test('returns SponsorSignals with string fields when no data', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.moodTrend, isA<String>());
      expect(signals.cravingVsBaseline, isA<String>());
      expect(signals.checkInStreak, isA<int>());
      expect(signals.daysSinceJournal, isA<int>());
      expect(signals.daysSinceHumanContact, isA<int>());
    });

    test('moodTrend is "no data" when no check-ins exist', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.moodTrend, 'no data');
    });

    test('cravingVsBaseline is "no data" when no check-ins exist', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.cravingVsBaseline, 'no data');
    });

    test('checkInStreak is 0 when no check-ins exist', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.checkInStreak, 0);
    });
  });
}
