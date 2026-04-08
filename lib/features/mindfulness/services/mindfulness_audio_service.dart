import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/mindfulness_models.dart';

/// Audio service for mindfulness playback
class MindfulnessAudioService extends ChangeNotifier {
  static MindfulnessAudioService? _instance;
  
  factory MindfulnessAudioService() {
    _instance ??= MindfulnessAudioService._internal();
    return _instance!;
  }
  
  /// Factory constructor for testing that allows injecting a custom player
  factory MindfulnessAudioService.withPlayer(AudioPlayer player) {
    return MindfulnessAudioService._internal(player: player);
  }
  
  /// Resets the singleton instance for testing
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
  
  MindfulnessAudioService._internal({AudioPlayer? player}) : _player = player;

  AudioPlayer? _player;
  AudioPlayer get _playerInstance => _player ??= AudioPlayer();
  
  MindfulnessTrack? _currentTrack;
  MindfulnessPlayerState _state = MindfulnessPlayerState.idle;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  double _speed = 1.0;

  // Getters
  MindfulnessTrack? get currentTrack => _currentTrack;
  MindfulnessPlayerState get state => _state;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  double get speed => _speed;
  
  bool get isPlaying => _state == MindfulnessPlayerState.playing;
  bool get isLoading => _state == MindfulnessPlayerState.loading;

  /// Initialize audio service
  Future<void> initialize() async {
    // Create player instance if needed
    _player ??= AudioPlayer();

    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // Listen to player state changes
    _playerInstance.playerStateStream.listen((state) {
      _updateState(state);
    });

    // Listen to position updates
    _playerInstance.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _playerInstance.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

  }

  void _updateState(PlayerState playerState) {
    if (playerState.playing) {
      _state = MindfulnessPlayerState.playing;
    } else if (playerState.processingState == ProcessingState.loading ||
               playerState.processingState == ProcessingState.buffering) {
      _state = MindfulnessPlayerState.loading;
    } else if (playerState.processingState == ProcessingState.completed) {
      _state = MindfulnessPlayerState.completed;
    } else {
      _state = MindfulnessPlayerState.paused;
    }
    notifyListeners();
  }

  /// Set the current track
  Future<void> setTrack(MindfulnessTrack track) async {
    _currentTrack = track;
    _state = MindfulnessPlayerState.loading;
    notifyListeners();

    try {
      // Use local asset if available, otherwise use URL
      if (track.localAssetPath != null) {
        await _playerInstance.setAsset(track.localAssetPath!);
      } else {
        await _playerInstance.setUrl(track.audioUrl);
      }
      _state = MindfulnessPlayerState.idle;
      notifyListeners();
    } catch (e) {
      _state = MindfulnessPlayerState.error;
      notifyListeners();
      rethrow;
    }
  }

  /// Play current track
  Future<void> play() async {
    if (_currentTrack == null) return;
    
    try {
      await _playerInstance.play();
      _state = MindfulnessPlayerState.playing;
      notifyListeners();
    } catch (e) {
      _state = MindfulnessPlayerState.error;
      notifyListeners();
      rethrow;
    }
  }

  /// Pause current track
  Future<void> pause() async {
    await _playerInstance.pause();
    _state = MindfulnessPlayerState.paused;
    notifyListeners();
  }

  /// Toggle play/pause
  Future<void> playPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    await _playerInstance.stop();
    _state = MindfulnessPlayerState.idle;
    _position = Duration.zero;
    notifyListeners();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _playerInstance.seek(position);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _playerInstance.setVolume(_volume);
    notifyListeners();
  }

  /// Set playback speed (0.5 to 2.0)
  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.5, 2.0);
    await _playerInstance.setSpeed(_speed);
    notifyListeners();
  }

  /// Skip forward by seconds
  Future<void> skipForward([int seconds = 15]) async {
    final newPosition = _position + Duration(seconds: seconds);
    if (newPosition < _duration) {
      await seek(newPosition);
    }
  }

  /// Skip backward by seconds
  Future<void> skipBackward([int seconds = 15]) async {
    final newPosition = _position - Duration(seconds: seconds);
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    }
  }

  /// Reset player
  Future<void> reset() async {
    if (_player != null) {
      await _player!.stop();
      await _player!.dispose();
      _player = null;
    }
    _currentTrack = null;
    _state = MindfulnessPlayerState.idle;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose();
    _player = null;
    super.dispose();
  }
}
