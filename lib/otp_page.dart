import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = [];
  final List<String> _otp = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    super.initState();
  }

  @override
  void dispose() {
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  BorderSide enabledSide = const BorderSide(color: Colors.black);
  BorderSide disabledSide =
      BorderSide(color: Color.lerp(Colors.black, Colors.white, 0.95)!);

  double size = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: List.generate(6, (index) => _otpField(index)),
        ),
      ),
    );
  }

  Widget _otpField(int index) {
    // TODO: get focus
    // TODO: get otp
    bool isFilled = _focusNodes[index].hasFocus;
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            return _formatter(index, oldValue, newValue);
          })
        ],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        controller: _controllers[index],
        style: TextStyle(
            fontSize: 20, color: isFilled ? Colors.white : Colors.black),
        decoration: InputDecoration(
          fillColor: Colors.black,
          filled: isFilled,
          border: OutlineInputBorder(
            borderSide: disabledSide,
          ),
        ),
      ),
    );
  }

  TextEditingValue _formatter(
      int index, TextEditingValue oldValue, TextEditingValue newValue) {
    int nextIndex = index + 1;
    if (nextIndex < _controllers.length) {
      _focusNodes[nextIndex].requestFocus();
    }
    if (newValue.text.length > 1) {
      return oldValue;
    }
    return newValue;
  }

  void _submit() {
    String otp = _controllers.map((e) => e.text).join();
    print(otp);
  }
}
