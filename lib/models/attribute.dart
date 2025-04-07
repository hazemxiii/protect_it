import 'dart:convert';

import 'package:protect_it/service/encryption.dart';

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
