import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Result of checking device lock capability.
final class DeviceLockAvailability {
  /// True if biometrics (fingerprint, face) are enrolled.
  final bool hasBiometrics;

  /// True if the device supports any screen lock (PIN, pattern, password).
  final bool hasDeviceLock;

  const DeviceLockAvailability({
    required this.hasBiometrics,
    required this.hasDeviceLock,
  });

  /// True if either biometric or device lock is available.
  bool get isAvailable => hasBiometrics || hasDeviceLock;
}

final class CheckBiometricAvailabilityUseCase {
  final LocalAuthentication _auth;

  CheckBiometricAvailabilityUseCase([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  Future<DeviceLockAvailability> call() async {
    try {
      final deviceSupported = await _auth.isDeviceSupported();
      if (!deviceSupported) {
        return const DeviceLockAvailability(
          hasBiometrics: false,
          hasDeviceLock: false,
        );
      }

      final canCheck = await _auth.canCheckBiometrics;
      final enrolled = canCheck
          ? await _auth.getAvailableBiometrics()
          : <BiometricType>[];

      return DeviceLockAvailability(
        hasBiometrics: enrolled.isNotEmpty,
        hasDeviceLock: deviceSupported,
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricAuth] availability check failed: ${e.code}');
      }
      return const DeviceLockAvailability(
        hasBiometrics: false,
        hasDeviceLock: false,
      );
    }
  }
}
