import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/file.dart';
import 'package:protect_it/service/storage.dart';

class AccountNotifier extends ChangeNotifier {
  String searchQ = "";
  List<Account> _accounts = [];
  Map<String, dynamic> deleteAttributeData = {};
  final FileHolder f = FileHolder();

  Future<bool> getData() async {
    await FileHolder().init();
    try {
      List<Account> data = await FileHolder().getData();
      _accounts = data;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> cancel(Account account, Account old) async {
    int i = _accounts.indexOf(account);
    _accounts.removeAt(i);
    _accounts.insert(i, old);
    await writeUpdate();
  }

  void addAccount(Account account) {
    _accounts.add(account);
    writeUpdate();
  }

  void setSensitive(Attribute attribute, bool v) {
    attribute.updateSensitivity(v);
    writeUpdate();
  }

  void setMain(Account account, String key) {
    account.setMain(key);
    writeUpdate();
  }

  void setSec(Account account, String key) {
    account.setSec(key);
    writeUpdate();
  }

  void updateValue(String value, Attribute attr) {
    attr.updateValue(value);
    writeUpdate();
  }

  void updateAttrKey(Account account, String oldKey, String newKey) {
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
    writeUpdate();
  }

  void updateColor(Account account, Color c) {
    account.updateColor(c);
    writeUpdate();
  }

  void deleteAccount(Account account) {
    _accounts.remove(account);
    writeUpdate();
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
    writeUpdate();
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
    writeUpdate();
    return true;
  }

  void undo() {
    Account? account = deleteAttributeData['account'];
    String? key = deleteAttributeData['key'];
    Attribute? attribute = deleteAttributeData['attribute'];
    if (account != null && key != null && attribute != null) {
      (deleteAttributeData['account'] as Account)
          .addAttributes({key: attribute});
    }
    deleteAttributeData = {};
    writeUpdate();
  }

  void updateName(Account account, String newName) {
    account.updateName(newName);
    writeUpdate();
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
