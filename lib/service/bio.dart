import 'package:local_auth/local_auth.dart';

class Bio {
  Future<bool> bioIsNotEmpty() async {
    final auth = LocalAuthentication();
    return (await auth.getAvailableBiometrics()).isNotEmpty;
  }

  Future<bool> authenticate() async {
    final auth = LocalAuthentication();
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please Authenticate to Show Details',
        options: const AuthenticationOptions(biometricOnly: true));

    return didAuthenticate;
  }
}
