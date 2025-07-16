import 'package:flutter/material.dart';
import 'package:protect_it/pin_page.dart';
import 'package:protect_it/service/bio.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/service/secure_storage.dart';
import 'package:protect_it/settings_page/privacy_section/privacy_section_button.dart';
import 'package:protect_it/settings_page/settings_page.dart';

class PrivacySectionWidget extends StatefulWidget {
  const PrivacySectionWidget({super.key});

  @override
  State<PrivacySectionWidget> createState() => _PrivacySectionWidgetState();
}

class _PrivacySectionWidgetState extends State<PrivacySectionWidget> {
  @override
  Widget build(BuildContext context) => SettingsSectionWidget(
      content: Column(
        children: <Widget>[
          // PrivacySectionButton(
          //     getValue: _getOtp, onPressed: (bool v) => _setOtp(v), text: 'OTP'),
          PrivacySectionButton(
              getValue: () => Future.value(SecureStorage().pin.isNotEmpty),
              text: 'Pin',
              onPressed: (bool v) => _setPin(v)),
          FutureBuilder(
              future: Bio().bioIsAvailable(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return PrivacySectionButton(
                      getValue: _getBiometric,
                      text: 'Biometric',
                      onPressed: (bool v) => _setBiometric(v));
                }
                return const SizedBox.shrink();
              }),
        ],
      ),
      title: 'Privacy Settings',
      hint: 'Extra Privacy Steps');

  // Future<bool> _getOtp() async => await Backend().otpEnabled;

  Future<bool> _getBiometric() async {
    if (await Bio().bioIsNotEmpty()) {
      return Prefs().isBioActive;
    }
    return false;
  }

  // Future<bool?> _setOtp(bool v) async {
  //   final bool? b = await Backend().setOtp(v);
  //   if (b == null) {
  //     return null;
  //   }
  //   return b;
  // }

  Future<bool?> _setBiometric(bool v) async {
    // if (Prefs().pin == null) {
    if (SecureStorage().pin.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a pin first')),
      );
      return null;
    }
    Prefs().setBio(v);
    return Prefs().isBioActive;
  }

  Future<bool?> _setPin(bool v) async {
    if (!v) {
      await Prefs().setPin(null);
    } else {
      final String? r = await _getNewPin();
      if (r != null) {
        await Prefs().setPin(r);
      }
    }
    return SecureStorage().pin.isNotEmpty;
    // return Prefs().pin != null;
  }

  Future<String?> _getNewPin() async {
    final pin = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PinPage(
              onSubmit: _onPinSubmit,
              title: 'Enter New Pin',
            )));

    if (!mounted) return null;
    final pinConfirm = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PinPage(
              onSubmit: _onPinConfirmSubmit,
              title: 'Confirm New Pin',
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
      pinNot.value = '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pin does not match')),
      );
    }
  }
}
