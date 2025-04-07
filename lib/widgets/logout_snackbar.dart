import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/sign_in_page.dart';

class LogoutSnackbar extends StatefulWidget {
  const LogoutSnackbar({super.key});

  @override
  State<LogoutSnackbar> createState() => _LogoutSnackbarState();
}

class _LogoutSnackbarState extends State<LogoutSnackbar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    _controller.addListener(() {
      if (_controller.isCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInPage()));
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.blue);
    return Column(
      children: [
        Row(
          children: [
            const Text("Your session has expired. Please sign in again.",
                style: style),
            TextButton(
                onPressed: () {
                  Backend().scaffoldMessengerKey.currentState?.clearSnackBars();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                      (_) => false);
                },
                child: const Text("Sign in again", style: style)),
          ],
        ),
        LinearProgressIndicator(
          color: Colors.blue,
          value: _animation.value,
          minHeight: 2,
        )
      ],
    );
  }
}
