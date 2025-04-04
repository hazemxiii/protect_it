import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/sign_in_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs().init();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _loading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Prefs().isLoggedIn) {
        await Backend().login(Prefs().username!, Prefs().password!);
        Backend().ping();
      }
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountNotifier(),
      child: MaterialApp(
        home: _loading
            ? const LoadingPage()
            : Prefs().isLoggedIn
                ? const AccountsPage()
                : const SignInPage(),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
  }
}
