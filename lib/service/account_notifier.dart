import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/attribute.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';

class AccountNotifier extends ChangeNotifier {
  String searchQ = "";
  List<Account> _accounts = [];
  Map<String, dynamic> deleteAttributeData = {};
  bool _loading = true;

  Future<bool> getData() async {
    getCachedData();
    List<Account>? accounts = await Backend().getAccounts();
    if (accounts == null) {
      return false;
    }
    if ((accounts).isNotEmpty) _accounts = accounts;
    _loading = false;
    dataUpdated();
    return true;
  }

  void getCachedData() {
    if (!Prefs().isCached) {
      return;
    }
    List<String> cache = Prefs().getCache();
    if (cache.isEmpty) {
      return;
    }
    List<Account> accounts = [];
    for (String c in cache) {
      Account? account = Account.fromJSON(c);
      if (account != null) {
        accounts.add(account);
      }
    }
    _accounts = accounts;
    _loading = false;
    notifyListeners();
  }

  void updateCache() {
    List<String> cache = [];
    for (Account a in _accounts) {
      cache.add(a.toJSON());
    }
    Prefs().setCache(cache);
  }

  Future<void> logout() async {
    _accounts = [];
    _loading = true;
    dataUpdated();
  }

  Future<void> cancel(Account account, Account old) async {
    int i = _accounts.indexOf(account);
    _accounts.removeAt(i);
    _accounts.insert(i, old);
    dataUpdated();
    Response d = await Backend().deleteAccount(account.id);
    Response r = await Backend().setAccount(account);
    if (!d.ok) {}
    if (!r.ok) {}
    // await writeUpdate();
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSensitive(
      Account account, Attribute attribute, bool v) async {
    attribute.updateSensitivity(v);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setMain(Account account, String key) async {
    account.setMain(key);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSec(Account account, String key) async {
    account.setSec(key);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateValue(
      Account account, String value, Attribute attr) async {
    attr.updateValue(value);
    dataUpdated();
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
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateColor(Account account, Color c) async {
    account.updateColor(c);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> deleteAccount(Account account) async {
    _accounts.remove(account);
    dataUpdated();
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
    dataUpdated();
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
    dataUpdated();
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
      dataUpdated();
      Response r = await Backend().setAccount(account);
      if (!r.ok) {}
    }
    // writeUpdate();
  }

  Future<void> updateName(Account account, String newName) async {
    account.updateName(newName);
    dataUpdated();
    Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  // Future<void> writeUpdate() async {
  //   if (await FileHolder().updateFile(_accounts)) {
  //     notifyListeners();
  //   } else {
  //     getData();
  //   }
  // }

  // Future<void> pickFile() async {
  //   File? importedFile = await Storage().pickFile();
  //   if (importedFile != null) {
  //     await f.replaceFile(importedFile);
  //   }
  //   getData();
  // }

  void dataUpdated() {
    notifyListeners();
    updateCache();
  }

  bool get loading => _loading;

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
