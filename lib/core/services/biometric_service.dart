import 'package:local_auth/local_auth.dart';
import 'logger_service.dart';

/// Result of a biometric authentication attempt.
enum BiometricResult {
  /// Authentication succeeded.
  success,

  /// Hardware is present but no biometrics are enrolled.
  notEnrolled,

  /// Device has no biometric hardware.
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

  /// Returns true if the device supports biometrics AND the user has them enrolled.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e, st) {
      LoggerService().error('BiometricService.isAvailable', error: e, stackTrace: st);
      return false;
    }
  }

  /// Prompt biometric authentication with [reason].
  ///
  /// Returns [BiometricResult.success] on success,
  /// appropriate error variant otherwise.
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
      if (available.isEmpty) return BiometricResult.notEnrolled;

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // fall back to device PIN if needed
          stickyAuth: true,
        ),
      );

      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } catch (e, st) {
      LoggerService().error('BiometricService.authenticate', error: e, stackTrace: st);
      return BiometricResult.error;
    }
  }
}
