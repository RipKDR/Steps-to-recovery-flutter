// test/crisis_constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/constants/crisis_constants.dart';

void main() {
  group('CrisisConstants', () {
    test('crisisKeywords is non-empty', () {
      expect(CrisisConstants.keywords, isNotEmpty);
    });

    test('detectCrisis returns true for suicide keyword', () {
      expect(CrisisConstants.detect('I want to kill myself'), isTrue);
    });

    test('detectCrisis returns true for relapse keyword', () {
      expect(CrisisConstants.detect('I want to use again'), isTrue);
    });

    test('detectCrisis returns false for normal message', () {
      expect(CrisisConstants.detect('I had a good day today'), isFalse);
    });

    test('detectCrisis is case-insensitive', () {
      expect(CrisisConstants.detect('SUICIDE'), isTrue);
    });
  });
}
