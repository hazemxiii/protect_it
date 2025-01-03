import 'package:flutter/material.dart';
import 'package:protect_it/home.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:protect_it/service/file.dart';
import 'package:provider/provider.dart';

class SecretCodePage extends StatefulWidget {
  const SecretCodePage({super.key});

  @override
  State<SecretCodePage> createState() => _SecretCodePageState();
}

class _SecretCodePageState extends State<SecretCodePage> {
  bool error = false;

  @override
  Widget build(BuildContext context) {
    UnderlineInputBorder border =
        const UnderlineInputBorder(borderSide: BorderSide());
    final secretController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: secretController,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    label: const Text(
                      "Secret Key",
                      style:
                          TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
                    ),
                    enabledBorder: error
                        ? border.copyWith(
                            borderSide: const BorderSide(color: Colors.red))
                        : border,
                    focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                            color: error ? Colors.red : Colors.black,
                            width: 3))),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () => login(context, secretController.text),
                child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Enter",
                          style: TextStyle(color: Colors.white),
                        ),
                        VerticalDivider(
                          width: 5,
                        ),
                        Icon(color: Colors.white, Icons.login)
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void login(BuildContext context, String secret) async {
    Encryption().setSecret(secret);

    List<Account>? data = await getData();
    if (data != null && context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
                create: (context) => AccountNotifier(data),
                child: const MaterialApp(
                  home: Home(),
                ),
              )));
    } else {
      setState(() {
        error = true;
      });
    }
  }

  Future<List<Account>?> getData() async {
    await FileHolder().init();
    try {
      return await FileHolder().getData();
    } catch (e) {
      return null;
    }
  }
}
