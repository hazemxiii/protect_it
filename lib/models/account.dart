import 'package:flutter/material.dart';

class Account {
  Account({
    required this.name,
    required this.attributes,
    this.mainKey = "",
    this.secKey = "",
    this.color = Colors.black,
  }) {
    List<String> keys = attributes.keys.toList();
    if (!keys.contains(mainKey)) {
      throw "Main Key Doesn't Exist";
    }
    if (!keys.contains(secKey) && secKey != "") {
      throw "Secondary Key Doesn't Exist";
    }
  }

  String name;
  String mainKey;
  String secKey;
  Color color;
  Map<String, Attribute> attributes = {};

  void addAttributes(Map<String, Attribute> attributes) {
    this.attributes.addAll(attributes);
  }

  void deleteAttribute(String attributeName) {
    attributes.remove(attributeName);
  }

  void setMain(String mainKey) {
    if (mainKey == secKey) {
      secKey = this.mainKey;
    }
    this.mainKey = mainKey;
  }

  void setSec(String secKey) {
    if (mainKey == secKey) {
      mainKey = this.secKey;
    }
    if (this.secKey == secKey) {
      this.secKey = "";
    } else {
      this.secKey = secKey;
    }
  }

  bool isAttributeExist(String key) {
    return attributes.keys.toList().contains(key);
  }

  Attribute get getMain => attributes[mainKey]!;
  Attribute? get getSec => attributes[secKey];
}

class Attribute {
  Attribute({
    required this.value,
    this.isSensitive = false,
  });

  String value;
  bool isSensitive;

  void updateValue(String value) {
    this.value = value;
  }

  void updateSensitivity(bool isSensitive) {
    this.isSensitive = isSensitive;
  }
}

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
    account.color = c;
    notifyListeners();
  }
}
