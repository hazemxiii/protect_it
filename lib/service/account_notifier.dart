import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/file.dart';
import 'package:protect_it/service/storage.dart';

// TODO: implement internet back callback

class AccountNotifier extends ChangeNotifier {
  String searchQ = "";
  List<Account> _accounts = [];
  Map<String, dynamic> deleteAttributeData = {};
  final FileHolder f = FileHolder();

  Future<bool> getData() async {
    List<Account>? accounts = await Backend().getAccounts();
    if (accounts == null) {
      return false;
    }
    _accounts = accounts;
    notifyListeners();
    return true;
    // await FileHolder().init();
    // try {
    //   List<Account> data = await FileHolder().getData();
    //   _accounts = data;
    //   notifyListeners();
    //   return true;
    // } catch (e) {
    //   return false;
    // }
  }

  Future<void> cancel(Account account, Account old) async {
    int i = _accounts.indexOf(account);
    _accounts.removeAt(i);
    _accounts.insert(i, old);
    notifyListeners();

    Response d = await Backend().deleteAccount(account.id);
    Response r = await Backend().setAccount(account);
    if (!d.ok) {}
    if (!r.ok) {}
    // await writeUpdate();
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSensitive(
      Account account, Attribute attribute, bool v) async {
    attribute.updateSensitivity(v);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setMain(Account account, String key) async {
    account.setMain(key);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSec(Account account, String key) async {
    account.setSec(key);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateValue(
      Account account, String value, Attribute attr) async {
    attr.updateValue(value);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateAttrKey(
      Account account, String oldKey, String newKey) async {
    if (oldKey == newKey) {
      return;
    }
    account.attributes[newKey] = account.attributes[oldKey]!;
    if (account.mainKey == oldKey) {
      account.setMain(newKey);
    }
    if (account.secKey == oldKey) {
      account.setSec(newKey);
    }
    account.attributes.remove(oldKey);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateColor(Account account, Color c) async {
    account.updateColor(c);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> deleteAccount(Account account) async {
    _accounts.remove(account);
    notifyListeners();
    Response r = await Backend().deleteAccount(account.id);
    if (!r.ok) {}
    // writeUpdate();
  }

  Map<String, Attribute> addAttribute(Account account) {
    Attribute attr = Attribute(value: "value");
    String name = "newAttribute";
    List<String> names = account.attributes.keys.toList();
    while (names.contains(name)) {
      int number = int.tryParse(name[name.length - 1]) ?? 0;
      name = "newAttribute_${number + 1}";
    }
    account.addAttributes({name: attr});
    notifyListeners();
    Backend().setAccount(account).then((r) {
      if (!r.ok) {}
    });
    // writeUpdate();
    return {name: attr};
  }

  bool deleteAttribute(Account account, String attributeKey) {
    Attribute? attr = account.deleteAttribute(attributeKey);
    if (attr == null) {
      return false;
    }
    deleteAttributeData['account'] = account;
    deleteAttributeData['attribute'] = attr;
    deleteAttributeData['key'] = attributeKey;
    notifyListeners();
    Backend().setAccount(account).then((r) {
      if (!r.ok) {}
    });
    // writeUpdate();
    return true;
  }

  Future<void> undo() async {
    Account? account = deleteAttributeData['account'];
    String? key = deleteAttributeData['key'];
    Attribute? attribute = deleteAttributeData['attribute'];
    if (account != null && key != null && attribute != null) {
      (deleteAttributeData['account'] as Account)
          .addAttributes({key: attribute});
    }
    deleteAttributeData = {};
    if (account != null) {
      notifyListeners();
      Response r = await Backend().setAccount(account);
      if (!r.ok) {}
    }
    // writeUpdate();
  }

  Future<void> updateName(Account account, String newName) async {
    account.updateName(newName);
    notifyListeners();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> writeUpdate() async {
    if (await FileHolder().updateFile(_accounts)) {
      notifyListeners();
    } else {
      getData();
    }
  }

  Future<void> pickFile() async {
    File? importedFile = await Storage().pickFile();
    if (importedFile != null) {
      await f.replaceFile(importedFile);
    }
    getData();
  }

  void updateSearchQ(String s) {
    searchQ = s;
    notifyListeners();
  }

  List<Account> accounts() {
    if (searchQ.trim() == "") {
      return _accounts;
    } else {
      List<Account> filtered = [];
      List<ExtractedResult<String>> result = extractTop(
        query: searchQ,
        choices: Account.names.keys.toList(),
        limit: 10,
        cutoff: 50,
      );

      for (var r in result) {
        Account account = Account.names[r.choice]!;
        if (_accounts.contains(account)) {
          filtered.add(account);
        }
      }
      return filtered;
    }
  }
}
