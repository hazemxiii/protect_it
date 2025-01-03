import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:protect_it/service/file.dart';

class Encryption {
  static String? _secret;

  void setSecret(String v) {
    _secret = v;
  }

  String? get secret => _secret;

  String encryptData(String plainText) {
    final keyBytes = encrypt.Key.fromUtf8(_secret!.padRight(32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  String decryptData(String encryptedText) {
    try {
      final parts = encryptedText.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final cipherText = parts[1];

      final keyBytes = encrypt.Key.fromUtf8(_secret!.padRight(32));
      final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      return decrypted;
    } catch (e) {
      throw DecryptFileErrors.wrongKey;
    }
  }
}
