import 'package:flutter/material.dart';

class PinPage extends StatelessWidget {
  final Function(ValueNotifier<String>, BuildContext, {String? pin}) onSubmit;
  final String title;
  final String? pin;
  const PinPage(
      {super.key, required this.onSubmit, required this.title, this.pin});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String> pinNot = ValueNotifier('');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: const TextStyle(fontSize: 20)),
            ValueListenableBuilder(
              valueListenable: pinNot,
              builder: (BuildContext context, String value, Widget? child) => PinInput(pin: value),
            ),
            PinKeyboard(pinNot: pinNot, onSubmit: onSubmit, pin: pin),
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
  Widget build(BuildContext context) => Row(
      spacing: 3,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _children,
    );

  List<Widget> get _children => List.generate(4, (int index) => _pinField(index < pin.length));

  Widget _pinField(bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active ? color : Color.lerp(Colors.white, color, 0.2),
      ),
    );
}

class PinKeyboard extends StatelessWidget {
  const PinKeyboard(
      {super.key, required this.pinNot, required this.onSubmit, this.pin});

  final ValueNotifier<String> pinNot;
  final Function(ValueNotifier<String>, BuildContext, {String? pin}) onSubmit;
  final String? pin;
  final TextStyle textStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
      child: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        children: _children(context),
      ),
    );

  List<Widget> _children(BuildContext context) => List.generate(12, (int index) => _key(index, context));

  Widget _key(int index, BuildContext context) {
    String text = '';
    Widget child = const SizedBox();
    if (index < 9) {
      text = (index + 1).toString();
    } else if (index == 10) {
      text = '0';
    } else if (index == 11) {
      text = 'back';
    }
    if (text == 'back') {
      child = const Icon(Icons.arrow_back_ios);
    } else if (text != '') {
      child = Text(text, style: textStyle);
    }
    return child is SizedBox
        ? child
        : IconButton(
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => _onType(text, context),
            icon: child,
          );
  }

  void _onType(String text, BuildContext context) {
    if (text == 'back') {
      pinNot.value = pinNot.value.substring(0, pinNot.value.length - 1);
    } else {
      pinNot.value += text;
      if (pinNot.value.length == 4) {
        onSubmit(pinNot, context, pin: pin);
      }
    }
  }
}
