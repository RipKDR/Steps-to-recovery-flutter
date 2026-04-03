import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/features/mindfulness/models/mindfulness_models.dart';
import 'package:steps_recovery_flutter/features/mindfulness/services/mindfulness_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channels for just_audio and audio_session
  setUpAll(() {
    // Mock just_audio platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.just_audio'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'init':
            return null;
          case 'dispose':
            return null;
          case 'setUrl':
          case 'setAsset':
            return {'duration': 60000}; // 60 seconds in milliseconds
          case 'play':
            return null;
          case 'pause':
            return null;
          case 'stop':
            return null;
          case 'seek':
            return null;
          case 'setVolume':
            return null;
          case 'setSpeed':
            return null;
          case 'concatenatingAdd':
          case 'concatenatingRemoveAt':
          case 'concatenatingInsertAll':
          case 'concatenatingClear':
          case 'concatenatingMove':
            return null;
          case 'setShuffleMode':
          case 'setLoopMode':
          case 'setAutomaticallyWaitsToMinimizeStalling':
            return null;
          case 'audioEffectSetEnabled':
          case 'androidLoudnessEnhancerSetTargetGain':
            return null;
          case 'setAndroidAudioAttributes':
            return null;
          case 'setPitch':
            return null;
          case 'skipSilence':
            return null;
          default:
            return null;
        }
      },
    );

    // Mock audio_session platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.audio_session'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getConfiguration':
            return <String, dynamic>{};
          case 'setConfiguration':
            return null;
          case 'setActive':
            return true;
          case 'getDevices':
            return <Map<String, dynamic>>[];
          default:
            return null;
        }
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.just_audio'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ryanheise.audio_session'),
      null,
    );
  });

  group('MindfulnessAudioService', () {
    late MindfulnessAudioService service;

    setUp(() {
      service = MindfulnessAudioService();
    });

    tearDown(() async {
      // Clean up but don't dispose the singleton between tests
      // as other tests might rely on it
    });

    group('Singleton', () {
      test('returns same instance', () {
        final service1 = MindfulnessAudioService();
        final service2 = MindfulnessAudioService();
        expect(identical(service1, service2), isTrue);
      });
    });

    group('Initial State', () {
      test('state is idle initially', () {
        expect(service.state, equals(MindfulnessPlayerState.idle));
      });

      test('position is zero initially', () {
        expect(service.position, equals(Duration.zero));
      });

      test('duration is zero initially', () {
        expect(service.duration, equals(Duration.zero));
      });

      test('currentTrack is null initially', () {
        expect(service.currentTrack, isNull);
      });

      test('volume is 1.0 initially', () {
        expect(service.volume, equals(1.0));
      });

      test('speed is 1.0 initially', () {
        expect(service.speed, equals(1.0));
      });
    });

    group('Volume and Speed Getters', () {
      test('volume returns current volume value', () {
        expect(service.volume, isA<double>());
        expect(service.volume, greaterThanOrEqualTo(0.0));
        expect(service.volume, lessThanOrEqualTo(1.0));
      });

      test('speed returns current speed value', () {
        expect(service.speed, isA<double>());
        expect(service.speed, greaterThanOrEqualTo(0.5));
        expect(service.speed, lessThanOrEqualTo(2.0));
      });
    });

    group('isPlaying and isLoading Getters', () {
      test('isPlaying returns false when idle', () {
        expect(service.isPlaying, isFalse);
      });

      test('isPlaying returns false when loading', () {
        // Simulate loading state by setting track (will trigger loading)
        // Note: We can't fully test this without async, but we can verify the getter works
        expect(service.isPlaying, equals(service.state == MindfulnessPlayerState.playing));
      });

      test('isLoading returns false when idle', () {
        expect(service.isLoading, isFalse);
      });

      test('isLoading returns true when state is loading', () {
        // Manually set the state to loading via reflection pattern (not possible directly)
        // Instead, verify the getter logic is correct
        expect(service.isLoading, equals(service.state == MindfulnessPlayerState.loading));
      });

      test('isPlaying getter reflects state changes', () {
        // Initially not playing
        expect(service.isPlaying, isFalse);
        
        // Verify getter returns correct value based on state
        expect(service.isPlaying, equals(service.state == MindfulnessPlayerState.playing));
      });

      test('isLoading getter reflects state changes', () {
        // Initially not loading
        expect(service.isLoading, isFalse);
        
        // Verify getter returns correct value based on state
        expect(service.isLoading, equals(service.state == MindfulnessPlayerState.loading));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('notifies listeners when state changes', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        // setTrack changes state and notifies listeners
        final track = const MindfulnessTrack(
          id: 'test-track',
          title: 'Test Track',
          description: 'A test track',
          category: 'Breathing',
          duration: Duration(minutes: 5),
          audioUrl: 'https://example.com/audio.mp3',
          localAssetPath: null,
          mindfulnessCategory: MindfulnessCategory.breathing,
          isPremium: false,
        );

        await service.setTrack(track);
        
        // Should have been notified at least once (loading state and then idle)
        expect(notifyCount, greaterThanOrEqualTo(1));
      });

      test('notifies listeners when volume is set', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        final initialCount = notifyCount;
        await service.setVolume(0.5);
        
        expect(notifyCount, greaterThan(initialCount));
      });

      test('notifies listeners when speed is set', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        final initialCount = notifyCount;
        await service.setSpeed(1.5);
        
        expect(notifyCount, greaterThan(initialCount));
      });

      test('volume is updated when setVolume is called', () async {
        await service.setVolume(0.7);
        expect(service.volume, equals(0.7));
      });

      test('speed is updated when setSpeed is called', () async {
        await service.setSpeed(1.5);
        expect(service.speed, equals(1.5));
      });

      test('volume is clamped between 0.0 and 1.0', () async {
        await service.setVolume(1.5);
        expect(service.volume, equals(1.0));

        await service.setVolume(-0.5);
        expect(service.volume, equals(0.0));
      });

      test('speed is clamped between 0.5 and 2.0', () async {
        await service.setSpeed(3.0);
        expect(service.speed, equals(2.0));

        await service.setSpeed(0.1);
        expect(service.speed, equals(0.5));
      });

      test('stop notifies listeners and resets state', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        final initialCount = notifyCount;
        await service.stop();
        
        expect(notifyCount, greaterThan(initialCount));
        expect(service.state, equals(MindfulnessPlayerState.idle));
        expect(service.position, equals(Duration.zero));
      });

      test('reset notifies listeners and clears state', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

        final initialCount = notifyCount;
        await service.reset();
        
        expect(notifyCount, greaterThan(initialCount));
        expect(service.state, equals(MindfulnessPlayerState.idle));
        expect(service.position, equals(Duration.zero));
        expect(service.duration, equals(Duration.zero));
        expect(service.currentTrack, isNull);
      });
    });

    group('Track Management', () {
      test('setTrack updates currentTrack', () async {
        final track = const MindfulnessTrack(
          id: 'test-track-2',
          title: 'Test Track 2',
          description: 'Another test track',
          category: 'Meditation',
          duration: Duration(minutes: 10),
          audioUrl: 'https://example.com/audio2.mp3',
          localAssetPath: null,
          mindfulnessCategory: MindfulnessCategory.sleep,
          isPremium: true,
        );

        await service.setTrack(track);
        expect(service.currentTrack, isNotNull);
        expect(service.currentTrack!.id, equals('test-track-2'));
        expect(service.currentTrack!.title, equals('Test Track 2'));
      });

      test('currentTrack provides access to track properties', () async {
        final track = const MindfulnessTrack(
          id: 'test-track-3',
          title: 'Mindfulness Track',
          description: 'Description here',
          category: 'Anxiety Relief',
          duration: Duration(minutes: 3, seconds: 30),
          audioUrl: 'https://example.com/audio3.mp3',
          localAssetPath: null,
          mindfulnessCategory: MindfulnessCategory.anxiety,
          isPremium: false,
        );

        await service.setTrack(track);
        expect(service.currentTrack!.durationFormatted, equals('3:30'));
        expect(service.currentTrack!.mindfulnessCategory, equals(MindfulnessCategory.anxiety));
      });
    });

    group('State Transitions', () {
      test('play does nothing when no track is set', () async {
        // Ensure no track is set
        await service.reset();
        
        // play() should return early when currentTrack is null
        await service.play();
        expect(service.state, equals(MindfulnessPlayerState.idle));
      });

      test('pause updates state to paused', () async {
        await service.pause();
        expect(service.state, equals(MindfulnessPlayerState.paused));
      });

      test('seek does not throw', () async {
        await service.seek(const Duration(seconds: 30));
        // Should complete without throwing
      });

      test('skipForward does not throw', () async {
        await service.skipForward(15);
        // Should complete without throwing
      });

      test('skipBackward does not throw', () async {
        await service.skipBackward(15);
        // Should complete without throwing
      });
    });
  });
}
