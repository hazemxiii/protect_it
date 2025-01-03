import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:protect_it/service/encryption.dart';
import 'package:protect_it/service/file.dart';

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
      throw "Main Key Doesn't Exist for account $name";
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

  String toJSON() {
    Encryption en = Encryption();
    Map<String, String> map = {};
    map['name'] = en.encryptData(_name);
    map['color'] = _color.value.toString();
    map['mainKey'] = en.encryptData(_mainKey);
    map['secKey'] = en.encryptData(_secKey);
    for (String attr in attributes.keys) {
      map[en.encryptData(attr)] = _attributes[attr]!.toJSON();
    }
    return jsonEncode(map);
  }

  static Account? fromJSON(String json) {
    try {
      Encryption en = Encryption();
      Map map = jsonDecode(json);
      Map<String, Attribute> attributes = {};
      String name = en.decryptData(map['name']!);
      Color color = Color(int.parse(map['color']!));
      String mainKey = en.decryptData(map['mainKey']!);
      String secKey = en.decryptData(map['secKey']!);
      for (String key in map.keys) {
        if (key.contains(":")) {
          Attribute? attr = Attribute.fromJSON(map[key]!);
          if (attr == null) {
            return null;
          }
          attributes[en.decryptData(key)] = attr;
        }
      }

      return Account(
          name: name,
          attributes: attributes,
          mainKey: mainKey,
          secKey: secKey,
          color: color);
    } catch (e) {
      if (e == DecryptFileErrors.wrongKey) {
        rethrow;
      }
      return null;
    }
  }

  void addAttributes(Map<String, Attribute> attributes) {
    _attributes.addAll(attributes);
  }

  Attribute? deleteAttribute(String attributeName) {
    if (attributeName == _mainKey) {
      if (_attributes.length <= 1) {
        return null;
      }
      List<String> attributes = _attributes.keys.toList();
      attributes.remove(_mainKey);
      if (_attributes.length == 1) {
        _secKey = "";
        _mainKey = attributes[0];
      } else {
        attributes.remove(_secKey);
        _mainKey = attributes[Random().nextInt(attributes.length)];
      }
    }
    if (attributeName == _secKey) {
      _secKey = "";
    }
    return _attributes.remove(attributeName);
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

  void updateName(String newName) {
    _name = newName;
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

  String toJSON() {
    Map<String, String> map = {};
    map['sensitive'] = isSensitive.toString();
    map['value'] = Encryption().encryptData(value);
    return jsonEncode(map);
  }

  static Attribute? fromJSON(String json) {
    try {
      Map map = jsonDecode(json);
      return Attribute(
          value: Encryption().decryptData(map['value']!),
          isSensitive: (map['sensitive']!) == "true");
    } catch (e) {
      return null;
    }
  }

  void updateValue(String value) {
    this.value = value;
  }

  void updateSensitivity(bool isSensitive) {
    this.isSensitive = isSensitive;
  }
}
