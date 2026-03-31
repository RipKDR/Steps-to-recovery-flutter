// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('web authDomain uses firebaseapp.com', () {
      expect(
        DefaultFirebaseOptions.web.authDomain,
        'flutter-step-build.firebaseapp.com',
      );
    });

    test('currentPlatform throws on unsupported desktop targets', () {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = previousPlatform;
      });

      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
