import 'package:flutter/material.dart';
import 'package:protect_it/home.dart';
import 'package:protect_it/secret_code.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // return const MaterialApp(
    //   home: SecretCodePage(),
    // );
    return ChangeNotifierProvider(
      create: (context) => AccountNotifier(),
      child: MaterialApp(
        home:
            Encryption().secret != null ? const Home() : const SecretCodePage(),
      ),
    );
  }
}
