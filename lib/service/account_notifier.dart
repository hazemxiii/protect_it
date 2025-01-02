import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';

class AccountNotifier extends ChangeNotifier {
  AccountNotifier(this.accounts);

  List<Account> accounts = [];
  Map<String, dynamic> deleteAttributeData = {};

  void addAccount(Account account) {
    accounts.add(account);
    notifyListeners();
  }

  void setSensitive(Attribute attribute, bool v) {
    attribute.updateSensitivity(v);
    notifyListeners();
  }

  void setMain(Account account, String key) {
    account.setMain(key);
    notifyListeners();
  }

  void setSec(Account account, String key) {
    account.setSec(key);
    notifyListeners();
  }

  void updateValue(String value, Attribute attr) {
    attr.updateValue(value);
    notifyListeners();
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
    notifyListeners();
  }

  void updateColor(Account account, Color c) {
    account.updateColor(c);
    notifyListeners();
  }

  void deleteAccount(Account account) {
    accounts.remove(account);
    notifyListeners();
  }

  void addAttribute(Account account) {
    account.addAttributes({"newAttribute": Attribute(value: "value")});
    notifyListeners();
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
    notifyListeners();
  }

  void updateName(Account account, String newName) {
    account.updateName(newName);
    notifyListeners();
  }
}
