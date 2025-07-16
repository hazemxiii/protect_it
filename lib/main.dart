import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page/accounts_page.dart';
import 'package:protect_it/pin_page.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/bio.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/service/secure_storage.dart';
import 'package:protect_it/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'package:protect_it/service/backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs().init();
  await SecureStorage().init();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _loading = true;
  bool _bioFailed = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Prefs().isLoggedIn) {
        if (Prefs().isBioActive) {
          _bioFailed = !(await Bio().authenticate());
        }
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
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (BuildContext context) => AccountNotifier(),
        child: MaterialApp(
          scaffoldMessengerKey: Backend().scaffoldMessengerKey,
          home: _buildChild(),
        ),
      );

  Widget _buildChild() {
    Widget child = const SignInPage();
    if (Prefs().isLoggedIn) {
      if (SecureStorage().pin.isNotEmpty && _bioFailed) {
        child = PinPage(onSubmit: _onPinSubmit, title: 'Enter Pin to continue');
      } else {
        child = const AccountsPage();
      }
    }
    if (_loading) {
      child = const LoadingPage();
    }
    return child;
  }

  void _onPinSubmit(ValueNotifier<String> pinNot, BuildContext context,
      {String? pin}) async {
    final String p = SecureStorage().pin;
    if (!context.mounted) return;
    if (pinNot.value == p) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const AccountsPage()),
          (Route route) => false);
    } else {
      pinNot.value = '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN')),
      );
    }
  }
}

class BioFailedPage extends StatelessWidget {
  const BioFailedPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Biometric Authentication Failed'),
        ),
      );
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        ),
      );
}
