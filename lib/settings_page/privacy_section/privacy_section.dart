import 'package:flutter/material.dart';
import 'package:protect_it/pin_page.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/settings_page/privacy_section/privacy_section_button.dart';
import 'package:protect_it/settings_page/settings_page.dart';

class PrivacySectionWidget extends StatefulWidget {
  const PrivacySectionWidget({super.key});

  @override
  State<PrivacySectionWidget> createState() => _PrivacySectionWidgetState();
}

class _PrivacySectionWidgetState extends State<PrivacySectionWidget> {
  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
        content: Column(
          children: [
            PrivacySectionButton(
                getValue: _getOtp, onPressed: (v) => _setOtp(v), text: "OTP"),
            PrivacySectionButton(
                getValue: () => Future.value(Prefs().isBioActive),
                text: "Biometric",
                onPressed: (v) => _setBiometric(v)),
            PrivacySectionButton(
                getValue: () => Future.value(Prefs().pin != null),
                text: "Pin",
                onPressed: (v) => _setPin(v)),
          ],
        ),
        title: "Privacy Settings",
        hint: "Extra Privacy Steps");
  }

  Future<bool> _getOtp() async {
    return await Backend().otpEnabled;
  }

  Future<bool?> _setOtp(bool v) async {
    bool? b = await Backend().setOtp(v);
    if (b == null) {
      return null;
    }
    return b;
  }

  Future<bool?> _setBiometric(bool v) async {
    Prefs().setBio(v);
    return Prefs().isBioActive;
  }

  Future<bool?> _setPin(bool v) async {
    if (!v) {
      Prefs().setPin(null);
    } else {
      String? r = await _getNewPin();
      if (r != null) {
        Prefs().setPin(r);
      }
    }
    return Prefs().pin != null;
  }

  Future<String?> _getNewPin() async {
    var pin = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PinPage(
              onSubmit: _onPinSubmit,
              title: "Enter New Pin",
            )));

    if (!mounted) return null;
    var pinConfirm = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PinPage(
              onSubmit: _onPinConfirmSubmit,
              title: "Confirm New Pin",
              pin: pin,
            )));
    if (pin != null && pin == pinConfirm) {
      return pin;
    }
    return null;
  }

  void _onPinSubmit(ValueNotifier<String> pinNot, BuildContext context,
      {String? pin}) {
    Navigator.pop(context, pinNot.value);
  }

  void _onPinConfirmSubmit(ValueNotifier<String> pinNot, BuildContext context,
      {String? pin}) {
    if (pinNot.value == pin) {
      Navigator.pop(context, pinNot.value);
    } else {
      pinNot.value = "";
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pin does not match")),
      );
    }
  }
}
