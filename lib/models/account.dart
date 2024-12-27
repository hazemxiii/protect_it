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
    if (!keys.contains(secKey)) {
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
    this.mainKey = mainKey;
  }

  void setSec(String secKey) {
    this.secKey = secKey;
  }

  Attribute get getMain => attributes[mainKey]!;
  Attribute get getSec => attributes[secKey]!;
}

class Attribute {
  Attribute({
    required this.value,
    this.isSensitive = false,
  });

  String value;
  bool isSensitive;

  void updateName(String name) {
    name = name;
  }

  void updateValue(String value) {
    value = value;
  }

  void updateSensitivity(bool isSensitive) {
    isSensitive = isSensitive;
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
    account.mainKey = key;
    notifyListeners();
  }

  void setSec(Account account, String key) {
    account.secKey = key;
    notifyListeners();
  }
}
