import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class Bio {
  Future<bool> bioIsNotEmpty() async {
    if (await bioIsAvailable()) {
      final auth = LocalAuthentication();
      return (await auth.getAvailableBiometrics()).isNotEmpty;
    }
    return false;
  }

  Future<bool> bioIsAvailable() async {
    try {
      if (kIsWeb) {
        return false;
      }
      final auth = LocalAuthentication();
      return await auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    if (!await bioIsAvailable()) {
      return false;
    }
    final auth = LocalAuthentication();
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please Authenticate to Show Details',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ));

    return didAuthenticate;
  }
}
