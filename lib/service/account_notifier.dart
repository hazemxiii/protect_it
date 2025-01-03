import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';
import 'package:protect_it/service/file.dart';

class AccountNotifier extends ChangeNotifier {
  AccountNotifier() {
    // getData();
  }

  List<Account> accounts = [];
  Map<String, dynamic> deleteAttributeData = {};
  final FileHolder f = FileHolder();

  Future<bool> getData() async {
    await FileHolder().init();
    try {
      List<Account> data = await FileHolder().getData();
      accounts = data;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void addAccount(Account account) {
    accounts.add(account);
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
    accounts.remove(account);
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
    account.addAttributes({"newAttribute": attr});
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

  void writeUpdate() async {
    if (await FileHolder().updateFile(accounts)) {
      notifyListeners();
    } else {
      getData();
    }
  }
}
