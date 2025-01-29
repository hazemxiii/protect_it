import 'package:flutter/material.dart';
import 'package:protect_it/settings_page/change_dialog_widget.dart';
import 'package:protect_it/secret_code.dart';
import 'package:protect_it/service/account_notifier.dart';
import 'package:protect_it/service/storage.dart';
import 'package:protect_it/settings_page/random_pass_widget.dart';
import 'package:provider/provider.dart';

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
            _fileSection(context),
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
      content: MaterialButton(
          color: Colors.white,
          textColor: Colors.black,
          elevation: 0,
          hoverElevation: 0,
          shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          onPressed: () => _showChangeSecretDialog(context),
          child: const Text("Change Key")),
    );
  }

  Widget _fileSection(BuildContext context) {
    return SettingsSectionWidget(
      title: "File System",
      hint: "Import/Export Your Data",
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fileButton(true),
          const VerticalDivider(
            width: 10,
          ),
          _fileButton(false),
        ],
      ),
    );
  }

  Widget _fileButton(bool isImport) {
    return MaterialButton(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: Colors.black,
        textColor: Colors.black,
        elevation: 0,
        hoverElevation: 0,
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        onPressed: isImport ? _pickFile : _saveFile,
        child: Row(
          children: [
            Icon(
              isImport ? Icons.download : Icons.upload,
              color: Colors.white,
            ),
            Text(
              isImport ? "Import" : "Export",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  void _pickFile() async {
    if (mounted) {
      await Provider.of<AccountNotifier>(context, listen: false).pickFile();
    }
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SecretCodePage()),
          (_) => false);
    }
  }

  void _saveFile() async {
    String? path = await Storage().saveFile();
    if (path != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("File Saved At $path")));
    }
  }

  void _showChangeSecretDialog(context) {
    showDialog(context: context, builder: (_) => const ChangeSecretDialog());
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
