import 'package:flutter/material.dart';
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
      setState(() {});
      if (_controller.isCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Your session has expired. Please sign in again."),
            TextButton(onPressed: () {}, child: Text("Sign in again")),
          ],
        ),
        LinearProgressIndicator(
          value: _animation.value,
          minHeight: 2,
        )
      ],
    );
  }
}
