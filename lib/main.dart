import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page.dart';
import 'package:protect_it/secret_code.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountNotifier(),
      child: MaterialApp(
        home: Encryption().secret != null
            ? const AccountsPage()
            : const SecretCodePage(),
      ),
    );
  }
}
