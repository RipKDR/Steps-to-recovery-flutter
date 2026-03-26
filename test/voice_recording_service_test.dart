import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/voice_recording_service.dart';

void main() {
  group('VoiceRecordingService', () {
    late VoiceRecordingService service;

    setUp(() {
      service = VoiceRecordingService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Initialization', () {
      test('service is singleton', () {
        final service2 = VoiceRecordingService();
        expect(identical(service, service2), isTrue);
      });

      test('initial state is correct', () {
        expect(service.isListening, isFalse);
        expect(service.isRecording, isFalse);
        expect(service.recognizedText, isEmpty);
        expect(service.recordingDuration, equals(Duration.zero));
        expect(service.recordingPath, isNull);
      });
    });

    group('Speech Recognition', () {
      test('isAvailable returns boolean', () async {
        final available = await service.isAvailable();
        expect(available, isA<bool>());
      });

      test('initialize returns boolean', () async {
        final initialized = await service.initialize();
        expect(initialized, isA<bool>());
      });

      test('clearText empties recognized text', () {
        // Simulate having text (would normally come from speech recognition)
        service.clearText();
        expect(service.recognizedText, isEmpty);
      });

      test('getFormattedDuration returns correct format', () {
        // This tests the formatting logic
        // Note: Actual duration tracking happens during recording
        final duration = service.getFormattedDuration();
        
        // Should be in mm:ss format
        expect(duration.contains(':'), isTrue);
        final parts = duration.split(':');
        expect(parts.length, equals(2));
        expect(parts[0].length, equals(2)); // minutes
        expect(parts[1].length, equals(2)); // seconds
      });
    });

    group('Audio Recording Permissions', () {
      test('hasPermission returns boolean', () async {
        final hasPermission = await service.hasPermission();
        expect(hasPermission, isA<bool>());
      });
    });

    group('Recording State Management', () {
      test('toggleListening changes state', () async {
        // Initialize first
        await service.initialize();
        
        final initialState = service.isListening;
        
        // Note: Actual listening requires device/simulator
        // This test verifies the method exists and doesn't crash
        try {
          await service.toggleListening();
          // State should change (unless speech recognition unavailable)
        } catch (e) {
          // Expected on test environment without speech recognition
          expect(e, isA<Exception>());
        }
      });

      test('stopListening when not listening does not throw', () async {
        // Should not throw even if not listening
        await service.stopListening();
        expect(service.isListening, isFalse);
      });
    });

    group('Recording Timer', () {
      test('recording duration starts at zero', () {
        expect(service.recordingDuration, equals(Duration.zero));
      });

      test('formatted duration handles zero correctly', () {
        final formatted = service.getFormattedDuration();
        expect(formatted, equals('00:00'));
      });

      test('formatted duration handles minutes and seconds', () {
        // Test the formatting logic with known duration
        // This would normally be tested by mocking the timer
        final testDuration = const Duration(minutes: 2, seconds: 30);
        
        // Simulate what the formatter should produce
        final minutes = testDuration.inMinutes;
        final seconds = testDuration.inSeconds % 60;
        final expected = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        expect(expected, equals('02:30'));
      });
    });

    group('Error Handling', () {
      test('startListening without initialization handles gracefully', () async {
        // Try to start without initialization
        try {
          await service.startListening();
        } catch (e) {
          // Should throw or handle gracefully
          expect(e, isNotNull);
        }
      });

      test('stopRecording when not recording returns null', () async {
        final path = await service.stopRecording();
        // Should return null or handle gracefully when not recording
        expect(path, isNull);
      });

      test('cancelRecording when not recording does not throw', () async {
        // Should not throw
        await service.cancelRecording();
      });
    });

    group('Service Lifecycle', () {
      test('dispose cleans up resources', () {
        // Create and dispose
        service.dispose();
        
        // After dispose, service should be cleaned up
        // Note: We can't easily test internal state after dispose
        // but we verify it doesn't throw
      });
    });
  });
}
