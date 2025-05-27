import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

void copy(BuildContext context, Color c, String value) async {
  await FlutterClipboard.copy(value);
  if (context.mounted) {
    _showCopiedSnackBack(context, c, value);
  }
}

void _showCopiedSnackBack(BuildContext context, Color c, String s) async {
  ScaffoldMessenger.of(context).clearSnackBars();
  final String copied = await FlutterClipboard.paste();
  if (s != copied) {
    return;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        content: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Color.lerp(Colors.white, c, 0.3),
                borderRadius: const BorderRadius.all(Radius.circular(999))),
            margin: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width - 170) / 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(999))),
                  child: Icon(
                    Icons.check,
                    color: c,
                  ),
                ),
                const VerticalDivider(
                  width: 10,
                ),
                Text(
                  'Copied',
                  style: TextStyle(color: c),
                ),
              ],
            ))));
  }
}
