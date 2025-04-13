import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';

class PrivacySectionButton extends StatefulWidget {
  final String text;
  final bool isOtp;
  final Future<String?> Function(bool) onPressed;
  const PrivacySectionButton(
      {super.key,
      required this.text,
      required this.isOtp,
      required this.onPressed});

  @override
  State<PrivacySectionButton> createState() => _PrivacySectionButtonState();
}

class _PrivacySectionButtonState extends State<PrivacySectionButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: widget.isOtp ? Backend().otpEnabled : Future.value(false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialButton(
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                color: Colors.white,
                textColor: Colors.black,
                onPressed: () => _onPressed(!snapshot.data!),
                child: Row(
                  children: [
                    Text(widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                    const Spacer(),
                    snapshot.data!
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  ],
                ));
          }
          return const LinearProgressIndicator(color: Colors.black);
        });
  }

  void _onPressed(bool v) async {
    String? b = await widget.onPressed(v);
    if (b == null) {
      setState(() {});
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to Updated")));
      }
    }
  }
}
