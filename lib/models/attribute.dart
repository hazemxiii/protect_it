import 'package:flutter/material.dart';

class Attribute {
  Attribute({
    required this.value,
    this.isSensitive = false,
  });

  String value;
  bool isSensitive;

  Map<String, String> toJSON() {
    final Map<String, String> map = <String, String>{};
    map['sensitive'] = isSensitive.toString();
    map['value'] = value;
    return map;
  }

  static Attribute? fromJSON(Map json) {
    try {
      return Attribute(
          value: json['value']!, isSensitive: (json['sensitive']!) == 'true');
    } catch (e) {
      debugPrint('Error in Attribute.fromJSON: ${e.toString()}');
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
