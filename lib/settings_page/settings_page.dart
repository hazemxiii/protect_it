import 'package:flutter/material.dart';
import 'package:protect_it/service/account_notifier.dart';

import 'package:protect_it/service/prefs.dart';
import 'package:protect_it/settings_page/change_dialog_widget.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _accountSection(context),
            // _twoBtnSection(
            //     context,
            //     "File System",
            //     "Import/Export Your Data",
            //     FileButtonData(
            //         text: "Import", icon: Icons.download, fn: _pickFile),
            //     FileButtonData(
            //         text: "Export", icon: Icons.upload, fn: _saveFile)),
            // _twoBtnSection(
            //     context,
            //     "Sync",
            //     "Auto Sync Your Data",
            //     FileButtonData(
            //         text: "Receive", icon: Icons.download, fn: _startServer),
            //     FileButtonData(
            //         text: "Send", icon: Icons.upload, fn: _sendData)),
            const SettingsSectionWidget(
                content: RandomPassWidget(),
                title: "Password Generator",
                hint: "")
          ],
        ),
      ),
    );
  }

  Widget _accountSection(BuildContext context) {
    return SettingsSectionWidget(
      title: "Account Settings",
      hint: "Change Your Security Key",
      content: Row(
        children: [
          _accountBtn(context, "Change Password",
              () => _showChangeSecretDialog(context)),
          const VerticalDivider(
            width: 10,
          ),
          _accountBtn(context, "Logout", () => _logout()),
        ],
      ),
    );
  }

  Widget _accountBtn(BuildContext context, String text, VoidCallback fn) {
    return MaterialButton(
        color: Colors.white,
        textColor: Colors.black,
        elevation: 0,
        hoverElevation: 0,
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        onPressed: fn,
        child: Text(text));
  }

  // Widget _twoBtnSection(BuildContext context, String title, String hint,
  //     FileButtonData leftBtn, FileButtonData rightBtn) {
  //   return SettingsSectionWidget(
  //     title: title,
  //     hint: hint,
  //     content: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         _fileButton(leftBtn),
  //         const VerticalDivider(
  //           width: 10,
  //         ),
  //         _fileButton(rightBtn),
  //       ],
  //     ),
  //   );
  // }

  // Widget _fileButton(FileButtonData btnData) {
  //   return MaterialButton(
  //       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
  //       color: Colors.black,
  //       textColor: Colors.black,
  //       elevation: 0,
  //       hoverElevation: 0,
  //       shape: const RoundedRectangleBorder(
  //           side: BorderSide(color: Colors.black),
  //           borderRadius: BorderRadius.all(Radius.circular(5))),
  //       onPressed: btnData.fn,
  //       child: Row(
  //         children: [
  //           Icon(
  //             btnData.icon,
  //             color: Colors.white,
  //           ),
  //           Text(
  //             btnData.text,
  //             style: const TextStyle(color: Colors.white),
  //           ),
  //         ],
  //       ));
  // }

  // void _pickFile() async {
  //   if (mounted) {
  //     await Provider.of<AccountNotifier>(context, listen: false).pickFile();
  //   }
  //   if (mounted) {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (_) => const SecretCodePage()),
  //         (_) => false);
  //   }
  // }

  // void _saveFile() async {
  //   String? path = await Storage().saveFile();
  //   if (path != null && mounted) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("File Saved At $path")));
  //   }
  // }

  void _showChangeSecretDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChangeSecretDialog());
  }

  void _logout() {
    Provider.of<AccountNotifier>(context, listen: false).logout();
    Prefs.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInPage()), (_) => false);
  }

  // void _startServer() {
  //   bool dontShow = Prefs.getDontShowAgain();
  //   if (Platform.isWindows && !dontShow) {
  //     Navigator.of(context)
  //         .push(MaterialPageRoute(builder: (_) => const CommandPage()));
  //   } else {
  //     Navigator.of(context)
  //         .push(MaterialPageRoute(builder: (_) => const ServerPage()));
  //   }
  // }

  // void _sendData() {
  //   Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (_) => const SendDataPage()));
  // }
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.fromBorderSide(BorderSide(color: Colors.grey))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
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
}
