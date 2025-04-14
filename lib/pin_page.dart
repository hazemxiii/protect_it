import 'package:flutter/material.dart';
import 'package:protect_it/accounts_page.dart';
import 'package:protect_it/service/prefs.dart';

class PinPage extends StatelessWidget {
  const PinPage({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> pinNot = ValueNotifier("");
    // TODO: submit pin
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: pinNot,
              builder: (context, value, child) {
                return PinInput(pin: value);
              },
            ),
            PinKeyboard(pinNot: pinNot),
          ],
        ),
      ),
    );
  }
}

class PinInput extends StatelessWidget {
  final String pin;
  const PinInput({super.key, required this.pin});

  final double size = 13;
  final Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _children,
    );
  }

  List<Widget> get _children {
    return List.generate(4, (index) => _pinField(index < pin.length));
  }

  Widget _pinField(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active ? color : Color.lerp(Colors.white, color, 0.2),
      ),
    );
  }
}

class PinKeyboard extends StatelessWidget {
  const PinKeyboard({super.key, required this.pinNot});

  final ValueNotifier<String> pinNot;

  final TextStyle textStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
      child: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        children: _children(context),
      ),
    );
  }

  List<Widget> _children(BuildContext context) {
    return List.generate(12, (index) => _key(index, context));
  }

  Widget _key(int index, BuildContext context) {
    String text = "";
    Widget child = const SizedBox();
    if (index < 9) {
      text = (index + 1).toString();
    } else if (index == 10) {
      text = "0";
    } else if (index == 11) {
      text = "back";
    }
    if (text == "back") {
      child = const Icon(Icons.arrow_back_ios);
    } else if (text != "") {
      child = Text(text, style: textStyle);
    }
    return child is SizedBox
        ? child
        : IconButton(
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => _onPressed(text, context),
            icon: child,
          );
  }

  void _onPressed(String text, BuildContext context) {
    if (text == "back") {
      pinNot.value = pinNot.value.substring(0, pinNot.value.length - 1);
    } else {
      pinNot.value += text;
      if (pinNot.value.length == 4) {
        if (pinNot.value == Prefs().pin) {
          Prefs().setPin(pinNot.value);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AccountsPage()),
              (route) => false);
        } else {
          pinNot.value = "";
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid PIN")),
          );
        }
      }
    }
  }
}
