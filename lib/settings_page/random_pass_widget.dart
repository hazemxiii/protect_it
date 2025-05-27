import 'package:flutter/material.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/service/random_pass.dart';

class RandomPassWidget extends StatefulWidget {
  const RandomPassWidget({super.key});

  @override
  State<RandomPassWidget> createState() => _RandomPassWidgetState();
}

class _RandomPassWidgetState extends State<RandomPassWidget> {
  RandomPass randomPassGenerator = Prefs().getRandomPass();
  // RandomPass prevState = Prefs.getRandomPass();
  late TextEditingController _controller;
  final TextEditingController _generatedController = TextEditingController();

  @override
  void initState() {
    _controller =
        TextEditingController(text: randomPassGenerator.special.join());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
      children: <Widget>[
        _switch('Use Uppercase', randomPassGenerator.upper,
            randomPassGenerator.setUpper),
        _switch('Use Lowercase', randomPassGenerator.lower,
            randomPassGenerator.setLower),
        _switch('Use Numbers', randomPassGenerator.nums,
            randomPassGenerator.setNums),
        _switch('Use Special Characters', randomPassGenerator.specialActive,
            randomPassGenerator.setSpecialActive),
        _input('Special Characters', null, false, _controller),
        const SizedBox(
          height: 5,
        ),
        _lengthIndicator(),
        _lengthSlider(),
        const SizedBox(
          height: 5,
        ),
        _input('Generated Password', _suffix(), true, _generatedController),
      ],
    );

  Widget _switch(String text, bool value, Function onTap) => SwitchListTile(
      activeColor: Colors.white,
      activeTrackColor: Colors.black,
      inactiveThumbColor: Colors.black,
      inactiveTrackColor: Colors.white,
      hoverColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(0),
      value: value,
      onChanged: (bool v) => _applyChanges(onTap, v),
      title: Text(text),
    );

  Widget _input(String hintText, IconButton? suffix, bool isGenerateInput,
      TextEditingController controller) {
    const OutlineInputBorder border = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(5)));

    const OutlineInputBorder borderF = OutlineInputBorder(
        borderSide: BorderSide(width: 2),
        borderRadius: BorderRadius.all(Radius.circular(5)));
    return TextField(
      // enabled: !isGenerateInput,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(
          disabledBorder: border,
          suffixIcon: suffix,
          hintStyle: const TextStyle(color: Colors.grey),
          focusedBorder: borderF,
          enabledBorder: border,
          hintText: hintText),
      onChanged: !isGenerateInput
          ? (String v) => _applyChanges(randomPassGenerator.setSpecial, v)
          : null,
      controller: controller,
    );
  }

  Widget _lengthIndicator() => Row(
      children: <Widget>[
        Text(
          'Password Length: ${randomPassGenerator.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );

  Widget _lengthSlider() => Slider(
        thumbColor: Colors.white,
        label: randomPassGenerator.length.toString(),
        activeColor: Colors.black,
        min: 6,
        max: 100,
        divisions: 94,
        value: randomPassGenerator.length.toDouble(),
        onChanged: (double v) {
          _applyChanges(randomPassGenerator.setLength, v.toInt());
        });

  IconButton _suffix() => IconButton(
        onPressed: () {
          setState(() {
            _generatedController.text = randomPassGenerator.create();
          });
        },
        icon: const Icon(
          Icons.restart_alt_rounded,
          color: Colors.black,
        ));

  void _applyChanges(Function onTap, v) async {
    onTap(v);
    await Prefs().saveRandomPassData(randomPassGenerator);
    setState(() {});
  }
}
