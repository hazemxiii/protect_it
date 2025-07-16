import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _key = 'key';
  final String _username = 'username';
  final String _accessToken = 'accessToken';
  final String _password = 'password';
  final String _pin = 'pin';

  late String key;
  late String username;
  late String accessToken;
  late String password;
  late String pin;

  SecureStorage._();

  factory SecureStorage() => _instance;

  Future<void> init() async {
    key = await _storage.read(key: _key) ?? '';
    username = await _storage.read(key: _username) ?? '';
    accessToken = await _storage.read(key: _accessToken) ?? '';
    password = await _storage.read(key: _password) ?? '';
    pin = await _storage.read(key: _pin) ?? '';
  }

  Future<void> setKey(String key) async {
    this.key = key;
    await _storage.write(key: _key, value: key);
  }

  Future<void> deleteKey() async {
    key = '';
    await _storage.delete(key: _key);
  }

  Future<void> setUsername(String username) async {
    this.username = username;
    await _storage.write(key: _username, value: username);
  }

  Future<void> deleteUsername() async {
    username = '';
    await _storage.delete(key: _username);
  }

  Future<void> setAccessToken(String accessToken) async {
    this.accessToken = accessToken;
    await _storage.write(key: _accessToken, value: accessToken);
  }

  Future<void> deleteAccessToken() async {
    accessToken = '';
    await _storage.delete(key: _accessToken);
  }

  Future<void> setPassword(String password) async {
    this.password = password;
    await _storage.write(key: _password, value: password);
  }

  Future<void> deletePassword() async {
    password = '';
    await _storage.delete(key: _password);
  }

  Future<void> setPin(String pin) async {
    this.pin = pin;
    await _storage.write(key: _pin, value: pin);
  }

  Future<void> deletePin() async {
    pin = '';
    await _storage.delete(key: _pin);
  }
}
