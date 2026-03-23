import 'package:local_auth/local_auth.dart' show LocalAuthentication;
import 'logger_service.dart' show LoggerService;

/// Result of a biometric authentication attempt.
enum BiometricResult {
  /// Authentication succeeded.
  success,

  /// Hardware is present but no biometrics are enrolled.
  notEnrolled,

  /// Device has no biometric hardware or does not support biometrics.
  unavailable,

  /// User cancelled or failed authentication.
  failed,

  /// Platform error or unexpected exception.
  error,
}

/// Thin singleton wrapper around [LocalAuthentication].
///
/// Call [isAvailable] before enabling the biometric lock toggle.
/// Call [authenticate] to prompt the user before showing sensitive content.
class BiometricService {
  static final BiometricService _instance = BiometricService._();

  factory BiometricService() => _instance;

  BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device supports biometrics and the user has them enrolled.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;

      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e, st) {
      LoggerService().error(
        'BiometricService.isAvailable',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Prompts biometric authentication with [reason].
  ///
  /// Returns:
  /// - [BiometricResult.success] on success
  /// - [BiometricResult.notEnrolled] if supported but no biometrics are enrolled
  /// - [BiometricResult.unavailable] if the device does not support biometrics
  /// - [BiometricResult.failed] if the user cancels or auth fails
  /// - [BiometricResult.error] on unexpected exceptions
  Future<BiometricResult> authenticate({
    String reason = 'Authenticate to access your recovery data',
  }) async {
    try {
      final canCheck = await _auth.canCheckBiometrics;

      if (!canCheck) {
        final isDeviceSupported = await _auth.isDeviceSupported();
        return isDeviceSupported
            ? BiometricResult.notEnrolled
            : BiometricResult.unavailable;
      }

      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        return BiometricResult.notEnrolled;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // Allows PIN/passcode fallback
        persistAcrossBackgrounding: true,
      );

      return authenticated
          ? BiometricResult.success
          : BiometricResult.failed;
    } catch (e, st) {
      LoggerService().error(
        'BiometricService.authenticate',
        error: e,
        stackTrace: st,
      );
      return BiometricResult.error;
    }
  }
}