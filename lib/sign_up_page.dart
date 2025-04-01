import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;
  bool _showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            _input("Username", _usernameController, _usernameError),
            _input("Password", _passwordController, _passwordError,
                showPassword: _showPassword),
            _input(
                "Confirm Password", _confirmPasswordController, _passwordError,
                showPassword: _showPassword),
            const SizedBox(height: 20),
            _btn(),
          ],
        ),
      ),
    );
  }

  Widget _btn() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.black);
    }
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13),
      minWidth: 100,
      textColor: Colors.white,
      color: Colors.black,
      onPressed: _register,
      child: const Text("Sign Up"),
    );
  }

  Widget _input(
      String label, TextEditingController controller, String? errorMsg,
      {bool? showPassword}) {
    bool error = errorMsg != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Color.lerp(Colors.white, error ? Colors.red : Colors.black,
                error ? 0.2 : 0.05),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            controller: controller,
            decoration: inputDecoration(label, showPassword),
            obscureText: !(showPassword ?? true),
          ),
        ),
        if (error) Text(errorMsg, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  InputDecoration inputDecoration(String label, bool? showPassword) {
    return InputDecoration(
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        labelText: label,
        border: InputBorder.none,
        suffixIcon: showPassword == null
            ? null
            : IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off)));
  }

  bool _validateUsername() {
    setState(() {
      if (_usernameController.text.length < 5) {
        _usernameError = "Username must be at least 5 characters long";
      } else {
        _usernameError = null;
      }
    });
    return _usernameError == null;
  }

  bool _validatePassword() {
    setState(() {
      if (_passwordController.text.length < 2) {
        _passwordError = "Password must be at least 2 characters long";
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = "Passwords do not match";
      } else {
        _passwordError = null;
      }
    });
    return _passwordError == null;
  }

  Future<void> _register() async {
    if (_validateUsername() && _validatePassword()) {
      setState(() {
        _isLoading = true;
      });
      final error = await Backend()
          .register(_usernameController.text, _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? "Account created successfully")),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
}
