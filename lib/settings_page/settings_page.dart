import 'package:flutter/material.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/settings_page/change_dialog_widget.dart';
import 'package:protect_it/settings_page/privacy_section/privacy_section.dart';
import 'package:protect_it/settings_page/random_pass_widget.dart';
import 'package:protect_it/sign_in_page.dart';
import 'package:provider/provider.dart';

class FileButtonData {
  final String text;
  final IconData icon;
  final VoidCallback fn;
  FileButtonData({required this.text, required this.icon, required this.fn});
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _accountSection(context),
              const PrivacySectionWidget(),
              const SettingsSectionWidget(
                  content: RandomPassWidget(),
                  title: 'Password Generator',
                  hint: '')
            ],
          ),
        ),
      );

  Widget _accountSection(BuildContext context) => SettingsSectionWidget(
        title: 'Account Settings',
        hint: 'Change Your Password',
        content: Row(
          children: <Widget>[
            _accountBtn(context, 'Change Password',
                () => _showChangeSecretDialog(context)),
            const VerticalDivider(
              width: 10,
            ),
            _accountBtn(context, 'Logout', () => _logout()),
          ],
        ),
      );

  Widget _accountBtn(BuildContext context, String text, VoidCallback fn) =>
      MaterialButton(
          color: Colors.white,
          textColor: Colors.black,
          elevation: 0,
          hoverElevation: 0,
          shape: const RoundedRectangleBorder(
              side: BorderSide(),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          onPressed: fn,
          child: Text(text));

  void _showChangeSecretDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChangeSecretDialog());
  }

  void _logout() async {
    final bool r = await Backend().logout();
    if (!mounted) return;
    if (r) {
      Provider.of<AccountNotifier>(context, listen: false).logout();
      Prefs().logout();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SignInPage()), (_) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Logout Failed')));
    }
  }
}

class SettingsSectionWidget extends StatelessWidget {
  final Widget content;
  final String title;
  final String hint;
  const SettingsSectionWidget(
      {super.key,
      required this.content,
      required this.title,
      required this.hint});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.fromBorderSide(BorderSide(color: Colors.grey))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              hint,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            content
          ],
        ),
      );
}
