import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Check if hardware is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  // 2. Trigger the Scan
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to open Vault',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep dialog open if app goes to background
          biometricOnly: true, // Don't allow PIN backup (optional)
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Biometric Error: $e");
      return false;
    }
  }
}
