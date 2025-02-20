import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:protect_it/models/account.dart';

enum DecryptFileErrors { notAccount, wrongKey }

class FileHolder {
  static File? file;

  void delete() async {
    await file!.delete();
  }

  Future<bool> init() async {
    final directory = await getApplicationDocumentsDirectory();
    file = File("${directory.path}/userData.txt");
    if (file == null) {
      return false;
    }
    if (await file!.exists()) {
      return true;
    } else {
      file!.writeAsString("");
      return false;
    }
  }

  Future<List<Account>> getData() async {
    List<String> data = (await file!.readAsString()).split("\n");
    List<Account> accounts = [];
    for (String json in data) {
      try {
        Account? account = Account.fromJSON(json);
        if (account != null) {
          accounts.add(account);
        }
      } catch (e) {
        if (e == DecryptFileErrors.wrongKey) {
          rethrow;
        }
      }
    }
    return accounts;
  }

  Future<void> replaceFile(File newFile) async {
    await file!.writeAsString(await newFile.readAsString());
  }

  Future<void> writeFromList(Uint8List list) async {
    await file!.writeAsBytes(list);
  }

  Future<bool> updateFile(List<Account> newData) async {
    if (file == null) {
      return false;
    }
    List<String> data = [];
    for (Account acc in newData) {
      data.add(acc.toJSON());
    }
    try {
      await file!.writeAsString(data.join("\n"));
      return true;
    } catch (e) {
      return false;
    }
  }
}
