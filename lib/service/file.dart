import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:protect_it/models/account.dart';

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

  Future<List<Account>> getData(String secret) async {
    List<String> data = (await file!.readAsString()).split("\n");
    List<Account> accounts = [];
    for (String json in data) {
      Account? account = Account.fromJSON(json, secret);
      if (account != null) {
        accounts.add(account);
      }
    }
    return accounts;
  }
}
