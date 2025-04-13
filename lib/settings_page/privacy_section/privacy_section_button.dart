import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';

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
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.white,
        textColor: Colors.black,
        onPressed: () => _onPressed(!_value),
        child: Row(
          children: [
            Text(widget.text,
                style: const TextStyle(
                  fontSize: 16,
                )),
            const Spacer(),
            SizedBox(
              height: 20,
              child: FutureBuilder<bool>(
                  future: widget.isOtp
                      ? Backend().otpEnabled
                      : Future.value(Prefs().isBioActive),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      _value = snapshot.data!;
                      return _value
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red);
                    }
                    return const CircularProgressIndicator(color: Colors.black);
                  }),
            ),
          ],
        ));
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
