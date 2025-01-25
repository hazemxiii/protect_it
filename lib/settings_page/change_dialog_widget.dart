import 'package:flutter/material.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:provider/provider.dart';

class ChangeSecretDialog extends StatefulWidget {
  const ChangeSecretDialog({super.key});

  @override
  State<ChangeSecretDialog> createState() => _ChangeSecretDialogState();
}

class _ChangeSecretDialogState extends State<ChangeSecretDialog> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Change Secret Key",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(_oldController, _oldValidator, "Old Key"),
              _input(_newController, _newValidator, "New Key"),
              _input(_confirmController, _newValidator, "Confirm New Key")
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            )),
        TextButton(
            onPressed: _onSubmit,
            child: const Text(
              "Change",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }

  TextFormField _input(
      TextEditingController controller, dynamic validator, String hint) {
    const border = UnderlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white));
    const focus = UnderlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.white));
    return TextFormField(
      obscureText: _isHidden,
      controller: controller,
      validator: validator,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: _toggleHidden,
              icon: Icon(_isHidden ? Icons.visibility_off : Icons.visibility)),
          hintStyle: const TextStyle(color: Colors.grey),
          hintText: hint,
          focusedBorder: focus,
          enabledBorder: border),
    );
  }

  String? _oldValidator(String? v) {
    if (v != Encryption().secret) {
      return "Wrong Secret Key";
    }
    return null;
  }

  String? _newValidator(String? v) {
    if (_newController.text != _confirmController.text) {
      return "Passwords Do not Match";
    }
    return null;
  }

  void _toggleHidden() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      Encryption().setSecret(_newController.text);
      Provider.of<AccountNotifier>(context, listen: false).writeUpdate();
    }
  }
}
