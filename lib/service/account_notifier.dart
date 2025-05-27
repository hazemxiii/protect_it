import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/models/attribute.dart';
import 'package:protect_it/service/backend.dart';
import 'package:protect_it/service/prefs.dart';

class AccountNotifier extends ChangeNotifier {
  String searchQ = '';
  List<Account> _accounts = <Account>[];
  Map<String, dynamic> deleteAttributeData = {};
  bool _loading = true;

  Future<bool> getData() async {
    getCachedData();
    final List<Account>? accounts = await Backend().getAccounts();
    _sendOfflineRequests();
    if (accounts == null) {
      return false;
    }
    if ((accounts).isNotEmpty) _accounts = accounts;
    _loading = false;
    dataUpdated();
    return true;
  }

  void _sendOfflineRequests() async {
    await Backend().sendOfflineRequests();
    final List<Account>? accounts = await Backend().getAccounts();
    if ((accounts?.isNotEmpty) ?? false) {
      _accounts = accounts!;
      dataUpdated();
    }
  }

  void getCachedData() {
    if (!Prefs().isCached) {
      return;
    }
    final List<String> cache = Prefs().getCache();
    if (cache.isEmpty) {
      return;
    }
    final List<Account> accounts = <Account>[];
    for (String c in cache) {
      final Account? account = Account.fromJSON(c);
      if (account != null) {
        accounts.add(account);
      }
    }
    _accounts = accounts;
    _loading = false;
    notifyListeners();
  }

  void updateCache() {
    final List<String> cache = <String>[];
    for (Account a in _accounts) {
      cache.add(a.toJSON());
    }
    Prefs().setCache(cache);
  }

  Future<void> logout() async {
    _accounts = <Account>[];
    _loading = true;
    dataUpdated();
  }

  Future<void> cancel(Account account, Account old) async {
    final int i = _accounts.indexOf(account);
    _accounts.removeAt(i);
    _accounts.insert(i, old);
    dataUpdated();
    final Response d = await Backend().deleteAccount(account.id);
    final Response r = await Backend().setAccount(account);
    if (!d.ok) {}
    if (!r.ok) {}
    // await writeUpdate();
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSensitive(
      Account account, Attribute attribute, bool v) async {
    attribute.updateSensitivity(v);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setMain(Account account, String key) async {
    account.setMain(key);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> setSec(Account account, String key) async {
    account.setSec(key);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateValue(
      Account account, String value, Attribute attr) async {
    attr.updateValue(value);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
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
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> updateColor(Account account, Color c) async {
    account.updateColor(c);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
    if (!r.ok) {}
    // writeUpdate();
  }

  Future<void> deleteAccount(Account account) async {
    _accounts.remove(account);
    dataUpdated();
    final Response r = await Backend().deleteAccount(account.id);
    if (!r.ok) {}
    // writeUpdate();
  }

  Map<String, Attribute> addAttribute(Account account) {
    final Attribute attr = Attribute(value: 'value');
    String name = 'newAttribute';
    final List<String> names = account.attributes.keys.toList();
    while (names.contains(name)) {
      final int number = int.tryParse(name[name.length - 1]) ?? 0;
      name = 'newAttribute_${number + 1}';
    }
    account.addAttributes(<String, Attribute>{name: attr});
    dataUpdated();
    Backend().setAccount(account).then((Response r) {
      if (!r.ok) {}
    });
    // writeUpdate();
    return <String, Attribute>{name: attr};
  }

  bool deleteAttribute(Account account, String attributeKey) {
    final Attribute? attr = account.deleteAttribute(attributeKey);
    if (attr == null) {
      return false;
    }
    deleteAttributeData['account'] = account;
    deleteAttributeData['attribute'] = attr;
    deleteAttributeData['key'] = attributeKey;
    dataUpdated();
    Backend().setAccount(account).then((Response r) {
      if (!r.ok) {}
    });
    // writeUpdate();
    return true;
  }

  Future<void> undo() async {
    final Account? account = deleteAttributeData['account'];
    final String? key = deleteAttributeData['key'];
    final Attribute? attribute = deleteAttributeData['attribute'];
    if (account != null && key != null && attribute != null) {
      (deleteAttributeData['account'] as Account)
          .addAttributes(<String, Attribute>{key: attribute});
    }
    deleteAttributeData = {};
    if (account != null) {
      dataUpdated();
      final Response r = await Backend().setAccount(account);
      if (!r.ok) {}
    }
    // writeUpdate();
  }

  Future<void> updateName(Account account, String newName) async {
    account.updateName(newName);
    dataUpdated();
    final Response r = await Backend().setAccount(account);
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
    if (searchQ.trim() == '') {
      return _accounts;
    } else {
      final List<Account> filtered = <Account>[];
      final List<ExtractedResult<String>> result = extractTop(
        query: searchQ,
        choices: Account.names.keys.toList(),
        limit: 10,
        cutoff: 50,
      );

      for (ExtractedResult<String> r in result) {
        final Account account = Account.names[r.choice]!;
        if (_accounts.contains(account)) {
          filtered.add(account);
        }
      }
      return filtered;
    }
  }
}
