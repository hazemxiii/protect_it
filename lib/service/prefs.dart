import 'package:protect_it/models/offline_request.dart';
import 'package:protect_it/service/random_pass.dart';
import 'package:protect_it/service/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static final Prefs _instance = Prefs._();
  late final SharedPreferences _prefs;
  static const String _dontShowAgain = 'dontShowAgain';
  static const String _cache = 'cache';
  static const String _bio = 'bio';
  static const String _expiresOn = 'expiresOn';
  static const String _offlineRequests = 'offlineRequests';

  Prefs._();

  factory Prefs() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void setBio(bool v) {
    _prefs.setBool(_bio, v);
  }

  Future<void> setPin(String? pin) async {
    if (pin == null) {
      await SecureStorage().deletePin();
    } else {
      await SecureStorage().setPin(pin);
    }
  }

  void setDontShowAgain(bool v) {
    _prefs.setBool(_dontShowAgain, v);
  }

  void setCache(List<String> cache) {
    _prefs.setStringList(_cache, cache);
  }

  void addOfflineRequest(OfflineRequest request) {
    _prefs.setStringList(_offlineRequests, <String>[
      ..._prefs.getStringList(_offlineRequests) ?? <String>[],
      request.toJSON()
    ]);
  }

  void removeOfflineRequest(OfflineRequest request) {
    _prefs.setStringList(
        _offlineRequests,
        _prefs
                .getStringList(_offlineRequests)
                ?.where((String e) => e != request.toJSON())
                .toList() ??
            <String>[]);
  }

  bool get isBioActive => _prefs.getBool(_bio) ?? false;
  bool get isCached => _prefs.containsKey(_cache);

  List<OfflineRequest> getOfflineRequests() =>
      _prefs
          .getStringList(_offlineRequests)
          ?.map((String e) => OfflineRequest.fromJSON(e))
          .toList() ??
      <OfflineRequest>[];

  List<String> getCache() => _prefs.getStringList(_cache) ?? <String>[];

  bool get isLoggedIn {
    final String? expDate = _prefs.getString(_expiresOn);

    if (expDate == null) return false;
    final DateTime expireOn = DateTime.parse(expDate);
    if (expireOn.isBefore(DateTime.now())) return false;

    return SecureStorage().username.isNotEmpty &&
        SecureStorage().password.isNotEmpty &&
        SecureStorage().accessToken.isNotEmpty;
  }

  bool getDontShowAgain() => _prefs.getBool(_dontShowAgain) ?? false;

  RandomPass getRandomPass() => RandomPass(
      upper: _prefs.getBool('upper') ?? true,
      lower: _prefs.getBool('lower') ?? true,
      nums: _prefs.getBool('nums') ?? true,
      length: _prefs.getInt('length') ?? 13,
      specialActive: _prefs.getBool('specialActive') ?? true,
      special: _prefs.getStringList('special') ??
          <String>[
            '\$',
            '#',
            '@',
            '!',
            '~',
            '&',
            '*',
            '-',
            '_',
            '+',
            '=',
            '%'
          ]);

  Future<bool> saveRandomPassData(RandomPass r) async {
    bool success = true;
    success = await _prefs.setBool('upper', r.upper);
    success = await _prefs.setBool('lower', r.lower);
    success = await _prefs.setBool('nums', r.nums);
    success = await _prefs.setBool('specialActive', r.specialActive);
    success = await _prefs.setInt('length', r.length);
    success = await _prefs.setStringList('special', r.special);
    return success;
  }

  Future<void> login(String username, String password, String token,
      DateTime expireOn, String key) async {
    await SecureStorage().setUsername(username);
    await SecureStorage().setPassword(password);
    await SecureStorage().setAccessToken(token);
    _prefs.setString(_expiresOn, expireOn.toIso8601String());
    await SecureStorage().setKey(key);
  }

  void logout() {
    SecureStorage().deleteAccessToken();
    SecureStorage().deleteUsername();
    SecureStorage().deleteKey();
    SecureStorage().deletePassword();
    _prefs.remove(_cache);
  }
}
