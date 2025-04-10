import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protect_it/accounts_page.dart';
import 'package:protect_it/service/backend.dart';

class OtpPage extends StatefulWidget {
  final String username;
  final String password;
  const OtpPage({super.key, required this.username, required this.password});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = [];
  int _length = 0;
  final List<FocusNode> _focusNodes = [];
  int _focusedIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      FocusNode focusNode = FocusNode();
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
      _focusNodes.add(focusNode);
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

  BorderSide side = const BorderSide(color: Colors.black);

  double size = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _titleWidget(),
            const SizedBox(height: 10),
            _subtitleWidget(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: List.generate(6, (index) => _otpField(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return const Text(
      "Enter Verifiction Code",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _subtitleWidget() {
    return Text(
      "Enter the 6-digit verification code sent to your email",
      style: TextStyle(
          fontSize: 16, color: Color.lerp(Colors.white, Colors.black, 0.5)),
    );
  }

  Widget _otpField(int index) {
    bool isFilled = _focusedIndex == index;
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
        onChanged: (v) => _submit(v),
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        cursorColor: isFilled ? Colors.white : Colors.black,
        controller: _controllers[index],
        style: TextStyle(
            fontSize: 20, color: isFilled ? Colors.white : Colors.black),
        decoration: InputDecoration(
          fillColor: Colors.black,
          filled: isFilled,
          border: OutlineInputBorder(
            borderSide: side,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: side,
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

  void _submit(String v) async {
    if (v.isNotEmpty) {
      _length++;
    } else {
      _length--;
    }
    if (_length == 6) {
      String otp = _controllers.map((e) => e.text).join();
      String? error =
          await Backend().login(widget.username, widget.password, otp: otp);
// TODO: get otp if user was already logged in
      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AccountsPage()),
            (route) => false);
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
