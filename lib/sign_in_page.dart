import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page/accounts_page.dart';
import 'package:protect_it/otp_page.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: <Widget>[
            _input('Username', _usernameController),
            _input('Password', _passwordController,
                showPassword: _showPassword),
            const SizedBox(height: 20),
            _btn(),
            _signUpBtn(),
          ],
        ),
      ),
    );

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
      onPressed: _signIn,
      child: const Text('Sign In'),
    );
  }

  Widget _signUpBtn() => TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => const SignUpPage())),
        child: const Text(
          'Sign Up',
        ));

  Widget _input(String label, TextEditingController controller,
      {bool? showPassword}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Color.lerp(Colors.white, Colors.black, 0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        controller: controller,
        obscureText: !(showPassword ?? true),
        decoration: inputDecoration(label, showPassword),
      ),
    );

  InputDecoration inputDecoration(String label, bool? showPassword) => InputDecoration(
      suffixIcon: showPassword != null
          ? IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon:
                  Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
            )
          : null,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Colors.black),
      labelText: label,
      border: InputBorder.none,
    );

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    final String? error = await Backend()
        .login(_usernameController.text, _passwordController.text);
    setState(() {
      _isLoading = false;
    });
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } else {
      if (await Backend().otpEnabled) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => OtpPage(
                    username: _usernameController.text,
                    password: _passwordController.text,
                  )),
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const AccountsPage()),
        );
      }
    }
  }
}
