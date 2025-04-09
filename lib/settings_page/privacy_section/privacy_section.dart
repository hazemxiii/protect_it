import 'package:flutter/material.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/settings_page/privacy_section/privacy_section_button.dart';
import 'package:protect_it/settings_page/settings_page.dart';

class PrivacySectionWidget extends StatelessWidget {
  const PrivacySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionWidget(
        content: Column(
          children: [
            PrivacySectionButton(
                text: "OTP",
                isEnabled: Backend().otpEnabled,
                onPressed: _setOtp),
            PrivacySectionButton(
                text: "Biometric",
                isEnabled: Future.value(false),
                onPressed: (v) => _setBiometric(v)),
          ],
        ),
        title: "Privacy Settings",
        hint: "Extra Privacy Steps");
  }

  Future<bool?> _setOtp(bool v) async {
    return await Backend().setOtp(v);
  }

  Future<bool?> _setBiometric(bool v) async {
    return true;
  }
}
