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
    String mainKey = '',
    String secKey = '',
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
      key = '$key ';
    }
    names[key] = this;
    final List<String> keys = _attributes.keys.toList();
    if (!keys.contains(_mainKey)) {
      throw "Main Key Doesn't Exist for account $name";
    }
    if (!keys.contains(_secKey) && _secKey != '') {
      throw "Secondary Key Doesn't Exist";
    }
  }

  static Map<String, Account> names = <String, Account>{};
  late String _id;
  late String _name;
  late String _mainKey;
  late String _secKey;
  late Color _color;
  late Map<String, Attribute> _attributes = <String, Attribute>{};

  // String toJSON() {
  //   Encryption en = Encryption();
  //   Map<String, String> map = {};
  //   map['id'] = _id;
  //   map['name'] = en.encryptData(_name);
  //   map['color'] = _color.toARGB32().toString();
  //   map['mainKey'] = en.encryptData(_mainKey);
  //   if (_secKey != "") {
  //     map['secKey'] = en.encryptData(_secKey);
  //   }
  //   for (String attr in attributes.keys) {
  //     map[en.encryptData(attr)] = _attributes[attr]!.toJSON();
  //   }
  //   return jsonEncode(map);
  // }

  String toJSON() {
    final Encryption en = Encryption();
    final Map<String, dynamic> map = {};
    map['id'] = _id;
    map['name'] = _name;
    map['color'] = _color.toARGB32().toString();
    map['mainKey'] = _mainKey;
    map['attributes'] = {};
    if (_secKey != '') {
      map['secKey'] = _secKey;
    }
    for (String attr in attributes.keys) {
      map['attributes'][attr] = _attributes[attr]!.toJSON();
    }
    return en.encryptData(jsonEncode(map));
  }

  static Account? fromJSON(String json) {
    try {
      final Encryption en = Encryption();
      final Map map = jsonDecode(en.decryptData(json));
      final Map<String, Attribute> attributes = <String, Attribute>{};
      final String id = map.remove('id')!;
      final String mainKey = map.remove('mainKey');
      final String name = map.remove('name')!;
      final Color color = Color(int.parse(map.remove('color')!));
      final String secKey = map.remove('secKey') ?? '';
      final Map<String, dynamic> attributesMap = map.remove('attributes')!;
      for (String key in attributesMap.keys) {
        final Attribute? attr = Attribute.fromJSON(attributesMap[key]);
        if (attr == null) {
          return null;
        }
        attributes[key] = attr;
      }

      return Account(
          id: id,
          name: name,
          attributes: attributes,
          mainKey: mainKey,
          secKey: secKey,
          color: color);
    } catch (e) {
      debugPrint('Error in Decrypting Account: ${e.toString()}');
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
      final List<String> attributes = _attributes.keys.toList();
      attributes.remove(_mainKey);
      if (_attributes.length == 1) {
        _secKey = '';
        _mainKey = attributes[0];
      } else {
        attributes.remove(_secKey);
        _mainKey = attributes[Random().nextInt(attributes.length)];
      }
    }
    if (attributeName == _secKey) {
      _secKey = '';
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
      if (_secKey == '') {
        return;
      }
      _mainKey = _secKey;
    }
    if (_secKey == secKey) {
      _secKey = '';
    } else {
      _secKey = secKey;
    }
  }

  bool isAttributeExist(String key) => _attributes.keys.toList().contains(key);

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
