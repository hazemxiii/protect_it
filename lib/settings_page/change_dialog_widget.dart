import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';

class ChangeSecretDialog extends StatefulWidget {
  const ChangeSecretDialog({super.key});

  @override
  State<ChangeSecretDialog> createState() => _ChangeSecretDialogState();
}

class _ChangeSecretDialogState extends State<ChangeSecretDialog> {
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isHidden = true;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text(
        'Change Secret Key',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _input(_oldController, _oldValidator, 'Old Password'),
              _input(_newController, _newValidator, 'New Password'),
              _input(_confirmController, _newValidator, 'Confirm New Password')
            ],
          ),
        ),
      ),
      actions: !_isLoading
          ? <Widget>[
              TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  onPressed: _onSubmit,
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.white),
                  ))
            ]
          : <Widget>[const CircularProgressIndicator(color: Colors.white)],
    );

  TextFormField _input(
      TextEditingController controller, validator, String hint) {
    const UnderlineInputBorder border = UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white));
    const UnderlineInputBorder focus = UnderlineInputBorder(
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

  String? _oldValidator(String? v) => null;

  String? _newValidator(String? v) {
    if (_newController.text != _confirmController.text) {
      return 'Passwords Do not Match';
    }
    return null;
  }

  void _toggleHidden() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final String? error = await Backend()
          .changePassword(_oldController.text, _newController.text);
      if (mounted) {
        if (error == null) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // void _onSubmit() {
  //   if (_formKey.currentState!.validate()) {
  //     Encryption().setSecret(_newController.text);
  //     Provider.of<AccountNotifier>(context, listen: false).writeUpdate();
  //   }
  // }
}
