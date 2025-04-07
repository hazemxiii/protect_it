import 'dart:convert';
import 'dart:math';
import 'package:protect_it/models/attribute.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:protect_it/service/encryption.dart';

class Account {
  Account({
    String? id,
    required String name,
    required Map<String, Attribute> attributes,
    String mainKey = "",
    String secKey = "",
    Color color = Colors.black,
  }) {
    _id = id ?? const Uuid().v4();
    _color = color;
    _secKey = secKey;
    _mainKey = mainKey;
    _attributes = attributes;
    _name = name;
    String key = _name;
    while (names.containsKey(key)) {
      key = "$key ";
    }
    names[key] = this;
    List<String> keys = _attributes.keys.toList();
    if (!keys.contains(_mainKey)) {
      throw "Main Key Doesn't Exist for account $name";
    }
    if (!keys.contains(_secKey) && _secKey != "") {
      throw "Secondary Key Doesn't Exist";
    }
  }

  static Map<String, Account> names = {};
  late String _id;
  late String _name;
  late String _mainKey;
  late String _secKey;
  late Color _color;
  late Map<String, Attribute> _attributes = {};

  String toJSON() {
    Encryption en = Encryption();
    Map<String, String> map = {};
    map['id'] = _id;
    map['name'] = en.encryptData(_name);
    map['color'] = _color.toARGB32().toString();
    map['mainKey'] = en.encryptData(_mainKey);
    if (_secKey != "") {
      map['secKey'] = en.encryptData(_secKey);
    }
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
      String id = map['id']!;

      String secKey =
          map['secKey'] != null ? en.decryptData(map['secKey']) : "";

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
          id: id,
          name: name,
          attributes: attributes,
          mainKey: mainKey,
          secKey: secKey,
          color: color);
    } catch (e) {
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
      if (_secKey == "") {
        return;
      }
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
    names.remove(_name);
    _name = newName;
    names[newName] = this;
  }

  Attribute get mainAttr => _attributes[_mainKey]!;
  Attribute? get secAttr => _attributes[_secKey];
  String get name => _name;
  Map<String, Attribute> get attributes => _attributes;
  String get mainKey => _mainKey;
  String get secKey => _secKey;
  String get id => _id;
  Color get color => _color;
}
