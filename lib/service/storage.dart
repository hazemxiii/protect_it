import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:protect_it/service/file.dart';

class Storage {
  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      await openAppSettings();
      return false;
    }
  }

  Future<File?> pickFile() async {
    if (!await requestStoragePermission()) {
      return null;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    }
    return null;
  }

  void saveFile() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'accounts.act',
    );

    if (outputFile != null) {
      File f = File(outputFile);
      await f.writeAsString(await FileHolder.file!.readAsString());
    }
  }
}
