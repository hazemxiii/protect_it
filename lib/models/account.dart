import 'package:flutter/material.dart';

class Account {
  Account({
    required String name,
    required Map<String, Attribute> attributes,
    String mainKey = "",
    String secKey = "",
    Color color = Colors.black,
  }) {
    _color = color;
    _secKey = secKey;
    _mainKey = mainKey;
    _attributes = attributes;
    _name = name;
    List<String> keys = _attributes.keys.toList();
    if (!keys.contains(_mainKey)) {
      throw "Main Key Doesn't Exist";
    }
    if (!keys.contains(_secKey) && _secKey != "") {
      throw "Secondary Key Doesn't Exist";
    }
  }

  late String _name;
  late String _mainKey;
  late String _secKey;
  late Color _color;
  late Map<String, Attribute> _attributes = {};

  void addAttributes(Map<String, Attribute> attributes) {
    _attributes.addAll(attributes);
  }

  void deleteAttribute(String attributeName) {
    _attributes.remove(attributeName);
  }

  void setMain(String mainKey) {
    if (mainKey == _secKey) {
      _secKey = _mainKey;
    }
    _mainKey = mainKey;
  }

  void setSec(String secKey) {
    if (_mainKey == secKey) {
      _mainKey = _secKey;
    }
    if (_secKey == secKey) {
      _secKey = "";
    } else {
      _secKey = secKey;
    }
  }

  bool isAttributeExist(String key) {
    return _attributes.keys.toList().contains(key);
  }

  void updateColor(Color c) {
    _color = c;
  }

  Attribute get mainAttr => _attributes[_mainKey]!;
  Attribute? get secAttr => _attributes[_secKey];
  String get name => _name;
  Map<String, Attribute> get attributes => _attributes;
  String get mainKey => _mainKey;
  String get secKey => _secKey;
  Color get color => _color;
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
