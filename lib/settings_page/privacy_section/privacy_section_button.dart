import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacySectionButton extends StatefulWidget {
  final String text;
  final Future<bool> Function() getValue;
  final Future<bool?> Function(bool) onPressed;
  const PrivacySectionButton(
      {super.key,
      required this.text,
      required this.getValue,
      required this.onPressed});

  @override
  State<PrivacySectionButton> createState() => _PrivacySectionButtonState();
}

class _PrivacySectionButtonState extends State<PrivacySectionButton> {
  @override
  void initState() {
    super.initState();
    widget.getValue().then((value) {
      setState(() {
        _value = value;
      });
    });
  }

  bool? _value;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.white,
        textColor: Colors.black,
        onPressed: () => _onPressed(_value),
        child: Row(
          children: [
            Text(widget.text,
                style: const TextStyle(
                  fontSize: 16,
                )),
            const Spacer(),
            (_value == null || _loading)
                ? const LoadingWidget()
                : _value == false
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : const Icon(Icons.check_circle, color: Colors.green),
          ],
        ));
  }

  void _onPressed(bool? oldValue) async {
    if (oldValue == null) {
      return;
    }
    setState(() {
      _loading = true;
    });
    bool? b = await widget.onPressed(!oldValue);
    if (b == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to Updated")));
      }
    } else {
      _value = b;
    }
    _loading = false;
    setState(() {});
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoActivityIndicator(
      color: Colors.black,
    );
  }
}
