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
                isOtp: true, onPressed: (v) => _setOtp(v), text: "OTP"),
            PrivacySectionButton(
                text: "Biometric",
                isOtp: false,
                onPressed: (v) => _setBiometric(v)),
          ],
        ),
        title: "Privacy Settings",
        hint: "Extra Privacy Steps");
  }

  Future<String?> _setOtp(bool v) async {
    bool? b = await Backend().setOtp(v);
    if (b == null) {
      return "Failed to update";
    }
    return null;
  }

  Future<String?> _setBiometric(bool v) async {
    // return true;
    return null;
  }
}
