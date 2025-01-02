import 'package:flutter/material.dart';
import 'package:protect_it/models/account.dart';

class AccountNotifier extends ChangeNotifier {
  AccountNotifier(this.accounts);

  List<Account> accounts = [];

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
}
