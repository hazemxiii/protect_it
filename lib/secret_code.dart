import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page/accounts_page.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:provider/provider.dart';

class SecretCodePage extends StatefulWidget {
  const SecretCodePage({super.key});

  @override
  State<SecretCodePage> createState() => _SecretCodePageState();
}

class _SecretCodePageState extends State<SecretCodePage> {
  bool isVisible = false;
  bool error = false;

  late TextEditingController secretController;

  @override
  void initState() {
    secretController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UnderlineInputBorder border =
        const UnderlineInputBorder(borderSide: BorderSide());
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
                obscureText: !isVisible,
                controller: secretController,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: _toggleVisibility,
                        icon: Icon(isVisible
                            ? Icons.visibility
                            : Icons.visibility_off)),
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
                onTap: () => _login(context, secretController.text),
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

  void _toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  void _login(BuildContext context, String secret) async {
    Encryption().setSecret(secret);

    bool isCorrect =
        await Provider.of<AccountNotifier>(context, listen: false).getData();

    if (isCorrect) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AccountsPage()));
      }
    } else {
      setState(() {
        error = true;
      });
    }
  }
}
