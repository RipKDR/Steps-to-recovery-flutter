
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/features/mindfulness/models/mindfulness_models.dart';
import 'package:steps_recovery_flutter/features/mindfulness/services/mindfulness_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    _setupPlatformMocks();
  });

  tearDownAll(() {
    _cleanupPlatformMocks();
  });

  group('MindfulnessAudioService', () {
    late MindfulnessAudioService service;

    setUp(() {
      MindfulnessAudioService.resetInstance();
      service = MindfulnessAudioService();
    });

    tearDown(() {
      MindfulnessAudioService.resetInstance();
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
        expect(service.isPlaying, equals(service.state == MindfulnessPlayerState.playing));
      });

      test('isLoading returns false when idle', () {
        expect(service.isLoading, isFalse);
      });

      test('isLoading returns true when state is loading', () {
        expect(service.isLoading, equals(service.state == MindfulnessPlayerState.loading));
      });

      test('isPlaying getter reflects state changes', () {
        expect(service.isPlaying, isFalse);
        expect(service.isPlaying, equals(service.state == MindfulnessPlayerState.playing));
      });

      test('isLoading getter reflects state changes', () {
        expect(service.isLoading, isFalse);
        expect(service.isLoading, equals(service.state == MindfulnessPlayerState.loading));
      });
    });

    group('ChangeNotifier Behavior', () {
      test('notifies listeners when state changes', () async {
        var notifyCount = 0;
        service.addListener(() {
          notifyCount++;
        });

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
        await service.reset();
        await service.play();
        expect(service.state, equals(MindfulnessPlayerState.idle));
      });

      test('pause updates state to paused', () async {
        await service.pause();
        expect(service.state, equals(MindfulnessPlayerState.paused));
      });

      test('seek does not throw', () async {
        await service.seek(const Duration(seconds: 30));
      });

      test('skipForward does not throw', () async {
        await service.skipForward(15);
      });

      test('skipBackward does not throw', () async {
        await service.skipBackward(15);
      });
    });
  });
}

// ============================================================================
// PLATFORM MOCKING
// ============================================================================

final _mockedJustAudioChannels = <String>{};

/// Sets up comprehensive platform mocks for just_audio and audio_session
void _setupPlatformMocks() {
  final binaryMessenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  
  // Mock the base just_audio channel
  _mockJustAudioChannel(binaryMessenger, 'com.ryanheise.just_audio.methods');
  
  // Pre-mock many potential dynamic channels with various UUID patterns
  // This ensures channels are mocked before they're used
  for (int i = 0; i < 20; i++) {
    final dynamicChannel = 'com.ryanheise.just_audio.methods.player-$i';
    _mockJustAudioChannel(binaryMessenger, dynamicChannel);
  }
  
  // Mock audio_session
  binaryMessenger.setMockMethodCallHandler(
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
}

/// Mocks a just_audio channel with a handler that responds to all methods
void _mockJustAudioChannel(TestDefaultBinaryMessenger binaryMessenger, String channelName) {
  if (_mockedJustAudioChannels.contains(channelName)) return;
  _mockedJustAudioChannels.add(channelName);
  
  binaryMessenger.setMockMessageHandler(channelName, (ByteData? message) async {
    if (message == null) return null;
    
    final methodCall = const StandardMethodCodec().decodeMethodCall(message);
    
    // If this is the base channel and init is called, also mock the dynamic channel
    if (channelName == 'com.ryanheise.just_audio.methods' && methodCall.method == 'init') {
      if (methodCall.arguments is Map && (methodCall.arguments as Map).containsKey('id')) {
        final playerId = (methodCall.arguments as Map)['id'] as String;
        final dynamicChannel = 'com.ryanheise.just_audio.methods.$playerId';
        _mockJustAudioChannel(binaryMessenger, dynamicChannel);
      }
    }
    
    return _createJustAudioResponse(methodCall);
  });
}

/// Creates appropriate responses for just_audio method calls
ByteData? _createJustAudioResponse(MethodCall methodCall) {
  switch (methodCall.method) {
    case 'init':
    case 'dispose':
    case 'disposeAllPlayers':
    case 'play':
    case 'pause':
    case 'stop':
    case 'seek':
    case 'setVolume':
    case 'setSpeed':
    case 'concatenatingAdd':
    case 'concatenatingRemoveAt':
    case 'concatenatingInsertAll':
    case 'concatenatingClear':
    case 'concatenatingMove':
    case 'setShuffleMode':
    case 'setLoopMode':
    case 'setAutomaticallyWaitsToMinimizeStalling':
    case 'audioEffectSetEnabled':
    case 'androidLoudnessEnhancerSetTargetGain':
    case 'setAndroidAudioAttributes':
    case 'setPitch':
    case 'skipSilence':
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    case 'setUrl':
    case 'setAsset':
      return const StandardMethodCodec().encodeSuccessEnvelope({'duration': 60000});
    default:
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
  }
}

/// Cleans up all platform mocks
void _cleanupPlatformMocks() {
  final binaryMessenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  
  for (final channel in _mockedJustAudioChannels) {
    binaryMessenger.setMockMessageHandler(channel, null);
  }
  _mockedJustAudioChannels.clear();
  
  binaryMessenger.setMockMethodCallHandler(
    const MethodChannel('com.ryanheise.audio_session'),
    null,
  );
}
