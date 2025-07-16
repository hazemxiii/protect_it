import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:protect_it/service/file.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:protect_it/service/secure_storage.dart';

class Encryption {
  static String? _secret;

  void setSecret(String v) {
    _secret = v;
  }

  String? get secret => _secret;

  String encryptData(String plainText) {
    // final keyBytes = encrypt.Key.fromUtf8(Prefs().key!.padRight(32));
    final Uint8List keyBytes = base64ToUint8List(SecureStorage().key);
    final SHA256Digest sha256 = SHA256Digest();
    final Uint8List derivedKey = sha256.process(Uint8List.fromList(keyBytes));
    final encrypt.IV iv = encrypt.IV.fromLength(16);
    final encrypt.Encrypter encrypter =
        encrypt.Encrypter(encrypt.AES(encrypt.Key(derivedKey)));

    final encrypt.Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  String decryptData(String encryptedText) {
    try {
      final List<String> parts = encryptedText.split(':');
      final encrypt.IV iv = encrypt.IV.fromBase64(parts[0]);
      final String cipherText = parts[1];

      final Uint8List keyBytes = base64ToUint8List(SecureStorage().key);
      final SHA256Digest sha256 = SHA256Digest();
      final Uint8List derivedKey = sha256.process(Uint8List.fromList(keyBytes));

      final encrypt.Encrypter encrypter =
          encrypt.Encrypter(encrypt.AES(encrypt.Key(derivedKey)));

      final String decrypted = encrypter.decrypt64(cipherText, iv: iv);
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
      final PBKDF2KeyDerivator pbkdf2 =
          PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

      // Convert password to bytes
      final Uint8List passwordBytes = utf8.encode(password);
      final Uint8List salt = base64ToUint8List(saltString);
      final Uint8List iv = base64ToUint8List(ivString);
      final Uint8List encryptedKey = base64ToUint8List(encryptedKeyString);

      // Derive key using PBKDF2 with same parameters as in Python
      final Pbkdf2Parameters params = Pbkdf2Parameters(salt, 100000, 32);
      pbkdf2.init(params);
      final Uint8List derivedKey =
          pbkdf2.process(Uint8List.fromList(passwordBytes));

      // Set up AES-CBC decryption
      final PaddedBlockCipher cipher = PaddedBlockCipher('AES/CBC/PKCS7');
      final KeyParameter keyParam = KeyParameter(derivedKey);
      final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, void>
          cipherParams = PaddedBlockCipherParameters(
        ParametersWithIV(keyParam, iv),
        null,
      );
      cipher.init(false, cipherParams);

      // Decrypt the data
      final Uint8List decryptedBytes = cipher.process(encryptedKey);

      return base64.encode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption error: ${e.toString()}');
      return null;
    }
  }

  Uint8List base64ToUint8List(String base64String) =>
      base64.decode(base64String);
}
