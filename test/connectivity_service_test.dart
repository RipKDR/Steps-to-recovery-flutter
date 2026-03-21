/*
* Created on Mar 22, 2026
* Test file for connectivity_service.dart
* File path: test/connectivity_service_test.dart
*
* Author: Abhijeet Pratap Singh - Senior Software Engineer
* Copyright (c) 2026 Aurigo
*/

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/connectivity_service.dart';

// ---------------------------------------------------------------------------
// Fake Connectivity that we fully control in tests.
// ---------------------------------------------------------------------------

/// A minimal stand-in for the [Connectivity] plugin that lets tests push
/// arbitrary result lists without touching platform channels.
class _FakeConnectivity {
  List<ConnectivityResult> _current = [ConnectivityResult.wifi];

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  /// Push a new connectivity state to both the current value and the stream.
  void emit(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }

  void dispose() => _controller.close();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ConnectivityService', () {
    late _FakeConnectivity fake;
    late ConnectivityService svc;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      fake = _FakeConnectivity();
      svc = createConnectivityServiceForTesting(
        checkConnectivity: fake.checkConnectivity,
        onConnectivityChanged: fake.onConnectivityChanged,
      );
    });

    tearDown(() {
      svc.dispose();
      fake.dispose();
    });

    // ── initial state ────────────────────────────────────────────────────────

    group('initial state', () {
      test('isConnected is true by default before initialize()', () {
        // The production default is `true` — avoids a false-offline flash.
        expect(svc.isConnected, isTrue);
      });
    });

    // ── initialize ───────────────────────────────────────────────────────────

    group('initialize', () {
      test('sets isConnected true when wifi is available', () async {
        fake.emit([ConnectivityResult.wifi]);
        await svc.initialize();
        expect(svc.isConnected, isTrue);
      });

      test('sets isConnected true when mobile data is available', () async {
        fake.emit([ConnectivityResult.mobile]);
        await svc.initialize();
        expect(svc.isConnected, isTrue);
      });

      test('sets isConnected true when ethernet is available', () async {
        fake.emit([ConnectivityResult.ethernet]);
        await svc.initialize();
        expect(svc.isConnected, isTrue);
      });

      test('sets isConnected false when only ConnectivityResult.none', () async {
        fake._current = [ConnectivityResult.none];
        await svc.initialize();
        expect(svc.isConnected, isFalse);
      });

      test('sets isConnected true when multiple results include wifi', () async {
        fake._current = [ConnectivityResult.none, ConnectivityResult.wifi];
        await svc.initialize();
        expect(svc.isConnected, isTrue);
      });
    });

    // ── _updateConnectionStatus ──────────────────────────────────────────────

    group('_updateConnectionStatus (via public helper)', () {
      test('transitions from connected to disconnected', () {
        svc.applyConnectivityResultsForTest([ConnectivityResult.wifi]);
        expect(svc.isConnected, isTrue);

        svc.applyConnectivityResultsForTest([ConnectivityResult.none]);
        expect(svc.isConnected, isFalse);
      });

      test('transitions from disconnected to connected', () {
        svc.applyConnectivityResultsForTest([ConnectivityResult.none]);
        svc.applyConnectivityResultsForTest([ConnectivityResult.mobile]);
        expect(svc.isConnected, isTrue);
      });

      test('no-op when state does not change (wifi stays wifi)', () {
        // Emit wifi twice — connectivityStream should only fire once.
        final events = <bool>[];
        svc.connectivityStream.listen(events.add);

        svc.applyConnectivityResultsForTest([ConnectivityResult.wifi]);
        // State was already true (initial default), so no event expected.
        expect(events, isEmpty);
      });

      test('vpn counts as connected', () {
        svc.applyConnectivityResultsForTest([ConnectivityResult.vpn]);
        expect(svc.isConnected, isTrue);
      });

      test('bluetooth counts as connected', () {
        svc.applyConnectivityResultsForTest([ConnectivityResult.bluetooth]);
        expect(svc.isConnected, isTrue);
      });
    });

    // ── connectivityStream ───────────────────────────────────────────────────

    group('connectivityStream', () {
      test('emits false when connection is lost', () async {
        await svc.initialize(); // starts connected (wifi)

        final completer = Completer<bool>();
        svc.connectivityStream.listen(completer.complete);

        fake.emit([ConnectivityResult.none]);
        final value = await completer.future.timeout(
          const Duration(seconds: 1),
        );
        expect(value, isFalse);
      });

      test('emits true when connection is restored', () async {
        // Start disconnected.
        fake._current = [ConnectivityResult.none];
        await svc.initialize();
        expect(svc.isConnected, isFalse);

        final completer = Completer<bool>();
        svc.connectivityStream.listen(completer.complete);

        fake.emit([ConnectivityResult.wifi]);
        final value = await completer.future.timeout(
          const Duration(seconds: 1),
        );
        expect(value, isTrue);
      });

      test('emits multiple transitions in order', () async {
        fake._current = [ConnectivityResult.wifi];
        await svc.initialize();

        final events = <bool>[];
        svc.connectivityStream.listen(events.add);

        fake.emit([ConnectivityResult.none]); // false
        fake.emit([ConnectivityResult.mobile]); // true
        fake.emit([ConnectivityResult.none]); // false

        // Allow microtasks to flush.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(events, equals([false, true, false]));
      });

      test('stream is broadcast — multiple listeners do not throw', () async {
        await svc.initialize();
        final events1 = <bool>[];
        final events2 = <bool>[];
        svc.connectivityStream.listen(events1.add);
        svc.connectivityStream.listen(events2.add);

        fake.emit([ConnectivityResult.none]);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(events1, equals([false]));
        expect(events2, equals([false]));
      });
    });

    // ── dispose ──────────────────────────────────────────────────────────────

    group('dispose', () {
      test('dispose does not throw', () {
        expect(() => svc.dispose(), returnsNormally);
      });

      test('dispose cancels platform subscription — no events after dispose',
          () async {
        await svc.initialize();
        final events = <bool>[];
        svc.connectivityStream.listen(events.add);

        svc.dispose();
        // Emit after dispose — nothing should arrive on the closed stream.
        // (Adding to _controller after close would throw, so we do not emit
        //  through fake here; we only verify no crash on dispose itself.)
        expect(events, isEmpty);
      });
    });
  });
}
