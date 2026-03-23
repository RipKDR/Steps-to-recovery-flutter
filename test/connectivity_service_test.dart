import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/services/connectivity_service.dart';

class _FakeConnectivity {
  List<ConnectivityResult> _current = [ConnectivityResult.wifi];

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  void emit(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }

  void dispose() => _controller.close();
}

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

    group('initial state', () {
      test('isConnected is true by default before initialize()', () {
        expect(svc.isConnected, isTrue);
      });
    });

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

    group('applyConnectivityResultsForTest', () {
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
        final events = <bool>[];
        svc.connectivityStream.listen(events.add);

        svc.applyConnectivityResultsForTest([ConnectivityResult.wifi]);
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

    group('connectivityStream', () {
      test('emits false when connection is lost', () async {
        await svc.initialize();

        final completer = Completer<bool>();
        svc.connectivityStream.listen(completer.complete);

        fake.emit([ConnectivityResult.none]);
        final value = await completer.future.timeout(
          const Duration(seconds: 1),
        );
        expect(value, isFalse);
      });

      test('emits true when connection is restored', () async {
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

        fake.emit([ConnectivityResult.none]);
        fake.emit([ConnectivityResult.mobile]);
        fake.emit([ConnectivityResult.none]);

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

    group('dispose', () {
      test('dispose does not throw', () {
        expect(() => svc.dispose(), returnsNormally);
      });

      test('dispose cancels platform subscription', () async {
        await svc.initialize();

        svc.dispose();
        expect(() => fake.emit([ConnectivityResult.none]), returnsNormally);
      });
    });
  });
}
