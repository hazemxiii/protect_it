import 'package:flutter/material.dart';
import 'package:protect_it/home.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountNotifier(accounts),
      child: const MaterialApp(
        home: Home(),
      ),
    );
  }
}

List<Account> accounts = [
  Account(
      color: Colors.blue,
      mainKey: "email",
      secKey: "password",
      name: "Facebook",
      attributes: {
        "email": Attribute(
          value: "face@book.com",
        ),
        "password": Attribute(value: "facepass", isSensitive: true),
        "phone": Attribute(value: "facephone"),
      }),
  Account(
      color: Colors.orange,
      name: "Google 1",
      mainKey: "gmail",
      secKey: "pass",
      attributes: {
        "gmail": Attribute(value: "g@mail.com"),
        "pass": Attribute(value: "gpass", isSensitive: true)
      })
];
