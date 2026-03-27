import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import 'logger_service.dart';

/// Handles runtime permissions for Android 6.0+ and iOS
class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  /// Request microphone permission for voice recording
  Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) return false;

    try {
      final status = await Permission.microphone.request();
      LoggerService().debug('Microphone permission status: $status');
      return status.isGranted;
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to request microphone permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Request speech recognition permission (iOS only)
  Future<bool> requestSpeechRecognitionPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isIOS) return true; // Android handles this differently

    try {
      final status = await Permission.speech.request();
      LoggerService().debug('Speech recognition permission status: $status');
      return status.isGranted;
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to request speech recognition permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Request location permission for meeting geofencing
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) return false;

    try {
      final status = await Permission.locationWhenInUse.request();
      LoggerService().debug('Location permission status: $status');
      return status.isGranted;
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to request location permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Request phone permission for Safe Dial
  Future<bool> requestPhonePermission() async {
    if (kIsWeb) return false;

    try {
      final status = await Permission.phone.request();
      LoggerService().debug('Phone permission status: $status');
      return status.isGranted;
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to request phone permission',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    if (kIsWeb) return false;

    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    if (kIsWeb) return false;

    try {
      final status = await Permission.locationWhenInUse.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings if permissions denied
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to open app settings',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Request all permissions needed for the app
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    results['microphone'] = await requestMicrophonePermission();
    results['location'] = await requestLocationPermission();
    results['phone'] = await requestPhonePermission();

    if (Platform.isIOS) {
      results['speech'] = await requestSpeechRecognitionPermission();
    }

    return results;
  }
}
