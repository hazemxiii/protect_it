import 'dart:convert';
// import 'dart:typed_data';
// import 'package:pointycastle/key_derivators/pbkdf2.dart';
// import 'package:pointycastle/digests/sha256.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:protect_it/service/file.dart';
import 'package:protect_it/service/prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

class Encryption {
  static String? _secret;

  void setSecret(String v) {
    _secret = v;
  }

  String? get secret => _secret;

  String encryptData(String plainText) {
    // final keyBytes = encrypt.Key.fromUtf8(Prefs().key!.padRight(32));
    final keyBytes = base64ToUint8List(Prefs().key!);
    var sha256 = SHA256Digest();
    Uint8List derivedKey = sha256.process(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(derivedKey)));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  String decryptData(String encryptedText) {
    try {
      final parts = encryptedText.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final cipherText = parts[1];

      final keyBytes = base64ToUint8List(Prefs().key!);
      var sha256 = SHA256Digest();
      Uint8List derivedKey = sha256.process(Uint8List.fromList(keyBytes));

      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(derivedKey)));

      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      return decrypted;
    } catch (e) {
      throw DecryptFileErrors.wrongKey;
    }
  }

  String decryptData2(String encryptedText) {
    try {
      final parts = encryptedText.split(':');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final cipherText = parts[1];

      final keyBytes = encrypt.Key.fromUtf8(Prefs().password!.padRight(32));
      final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));

      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      return decrypted;
    } catch (e) {
      throw DecryptFileErrors.wrongKey;
    }
  }

  Future<String?> decryptKey({
    required String encryptedKeyString,
    required String password,
    required String saltString,
    required String ivString,
  }) async {
    try {
      // Register PBKDF2 algorithm
      final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

      // Convert password to bytes
      final passwordBytes = utf8.encode(password);
      final salt = base64ToUint8List(saltString);
      final iv = base64ToUint8List(ivString);
      final encryptedKey = base64ToUint8List(encryptedKeyString);

      // Derive key using PBKDF2 with same parameters as in Python
      final params = Pbkdf2Parameters(salt, 100000, 32);
      pbkdf2.init(params);
      final derivedKey = pbkdf2.process(Uint8List.fromList(passwordBytes));

      // Set up AES-CBC decryption
      final cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final keyParam = KeyParameter(derivedKey);
      final cipherParams = PaddedBlockCipherParameters(
        ParametersWithIV(keyParam, iv),
        null,
      );
      cipher.init(false, cipherParams); // false for decryption

      // Decrypt the data
      final decryptedBytes = cipher.process(encryptedKey);

      return base64.encode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption error: ${e.toString()}');
      return null;
    }
  }

  Uint8List base64ToUint8List(String base64String) {
    return base64.decode(base64String);
  }
}
