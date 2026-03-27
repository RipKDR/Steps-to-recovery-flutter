import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'permissions_service.dart';
import 'logger_service.dart';

/// Voice recording service for journal dictation
class VoiceRecordingService extends ChangeNotifier {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();
  final _logger = LoggerService();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isListening = false;
  bool _isRecording = false;
  String _recognizedText = '';
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;

  // Getters
  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  String get recognizedText => _recognizedText;
  Duration get recordingDuration => _recordingDuration;
  String? get recordingPath => _recordingPath;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      // Request microphone permission first
      final permissionsService = PermissionsService();
      final hasPermission = await permissionsService.hasMicrophonePermission();

      if (!hasPermission) {
        final granted = await permissionsService.requestMicrophonePermission();
        if (!granted) {
          _logger.warning('Microphone permission denied');
          return false;
        }
      }

      bool available = await _speech.initialize(
        onError: (error) => _logger.error('Speech recognition error', error: error),
        onStatus: (status) {
          _logger.debug('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      return available;
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize speech recognition', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    try {
      return _speech.isAvailable;
    } catch (e) {
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening({void Function(String)? onResult}) async {
    if (_isListening) return;

    try {
      _isListening = true;
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          notifyListeners();
          if (onResult != null) {
            onResult(_recognizedText);
          }
        },
        localeId: 'en_US',
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to start listening', error: e, stackTrace: stackTrace);
      _isListening = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to stop listening', error: e, stackTrace: stackTrace);
    }
  }

  /// Toggle listening
  Future<void> toggleListening({void Function(String)? onResult}) async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening(onResult: onResult);
    }
  }

  /// Clear recognized text
  void clearText() {
    _recognizedText = '';
    notifyListeners();
  }

  // Audio Recording Methods

  /// Check if audio recording is available
  Future<bool> hasPermission() async {
    try {
      final permissionsService = PermissionsService();
      final hasPermission = await permissionsService.hasMicrophonePermission();

      if (!hasPermission) {
        // Request permission
        return await permissionsService.requestMicrophonePermission();
      }

      return hasPermission;
    } catch (e, stackTrace) {
      _logger.error('Permission check failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Start audio recording
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      notifyListeners();

      // Start timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        notifyListeners();
      });

      // Start recording
      const path = 'journal_recording';
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '$path.m4a',
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to start recording', error: e, stackTrace: stackTrace);
      _isRecording = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Stop audio recording and return file path
  Future<String?> stopRecording() async {
    try {
      _recordingTimer?.cancel();
      _isRecording = false;
      notifyListeners();

      final path = await _audioRecorder.stop();
      _recordingPath = path;
      return path;
    } catch (e, stackTrace) {
      _logger.error('Failed to stop recording', error: e, stackTrace: stackTrace);
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _audioRecorder.stop();
      _isRecording = false;
      _recordingPath = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.error('Failed to cancel recording', error: e, stackTrace: stackTrace);
    }
  }

  /// Get recording duration formatted as mm:ss
  String getFormattedDuration() {
    final minutes = _recordingDuration.inMinutes;
    final seconds = _recordingDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _speech.stop();
    _audioRecorder.dispose();
    super.dispose();
  }
}
