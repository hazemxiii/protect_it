import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<bool> saveFile() async {
    if (!await requestStoragePermission()) {
      return false;
    }
    Directory? outputFile = await getDownloadsDirectory();
    try {
      if (outputFile != null) {
        File f = File("${outputFile.path}/account.act");
        await f.writeAsString(await FileHolder.file!.readAsString());
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }
}
