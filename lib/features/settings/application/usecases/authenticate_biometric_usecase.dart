import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

final class AuthenticateBiometricUseCase {
  final LocalAuthentication _auth;

  AuthenticateBiometricUseCase([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  Future<bool> call({
    String reason = 'Authenticate to open Dawarich',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BiometricAuth] authenticate failed: $e');
      }
      return false;
    }
  }
}



