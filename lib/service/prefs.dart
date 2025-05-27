import 'package:protect_it/models/offline_request.dart';
import 'package:protect_it/service/random_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static final Prefs _instance = Prefs._();
  late SharedPreferences _prefs;
  static const String _dontShowAgain = 'dontShowAgain';
  static const String _accessToken = 'accessToken';
  static const String _username = 'username';
  static const String _password = 'password';
  static const String _cache = 'cache';
  static const String _bio = 'bio';
  static const String _pin = 'pin';
  static const String _expiresOn = 'expiresOn';
  static const String _offlineRequests = 'offlineRequests';
  static const String _key = 'key';

  Prefs._();

  factory Prefs() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void setBio(bool v) {
    _prefs.setBool(_bio, v);
  }

  void setPin(String? pin) {
    if (pin == null) {
      _prefs.remove(_pin);
    } else {
      _prefs.setString(_pin, pin);
    }
  }

  void setDontShowAgain(bool v) {
    _prefs.setBool(_dontShowAgain, v);
  }

  void setAccessToken(String token) {
    _prefs.setString(_accessToken, token);
  }

  void setKey(String key) {
    _prefs.setString(_key, key);
  }

  void setCache(List<String> cache) {
    _prefs.setStringList(_cache, cache);
  }

  void setExpireOn(DateTime expireOn) {
    _prefs.setString(_expiresOn, expireOn.toIso8601String());
  }

  void setUsername(String username) {
    _prefs.setString(_username, username);
  }

  void setPassword(String password) {
    _prefs.setString(_password, password);
  }

  void addOfflineRequest(OfflineRequest request) {
    _prefs.setStringList(_offlineRequests,
        <String>[..._prefs.getStringList(_offlineRequests) ?? <String>[], request.toJSON()]);
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
  String? get username => _prefs.getString(_username);
  String? get pin => _prefs.getString(_pin);
  String? get password => _prefs.getString(_password);
  String? get key => _prefs.getString(_key);
  bool get isCached => _prefs.containsKey(_cache);

  List<OfflineRequest> getOfflineRequests() => _prefs
            .getStringList(_offlineRequests)
            ?.map((String e) => OfflineRequest.fromJSON(e))
            .toList() ??
        <OfflineRequest>[];

  String getAccessToken() => _prefs.getString(_accessToken) ?? '';

  List<String> getCache() => _prefs.getStringList(_cache) ?? <String>[];

  bool get isLoggedIn {
    final String? expDate = _prefs.getString(_expiresOn);

    if (expDate == null) return false;
    final DateTime expireOn = DateTime.parse(expDate);
    if (expireOn.isBefore(DateTime.now())) return false;

    return _prefs.getString(_username) != null &&
        _prefs.getString(_password) != null &&
        _prefs.getString(_accessToken) != null;
  }

  bool getDontShowAgain() => _prefs.getBool(_dontShowAgain) ?? false;

  RandomPass getRandomPass() => RandomPass(
        upper: _prefs.getBool('upper') ?? true,
        lower: _prefs.getBool('lower') ?? true,
        nums: _prefs.getBool('nums') ?? true,
        length: _prefs.getInt('length') ?? 13,
        specialActive: _prefs.getBool('specialActive') ?? true,
        special: _prefs.getStringList('special') ??
            <String>['\$', '#', '@', '!', '~', '&', '*', '-', '_', '+', '=', '%']);

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

  void login(String username, String password, String token, DateTime expireOn,
      String key) {
    _prefs.setString(_username, username);
    _prefs.setString(_password, password);
    _prefs.setString(_accessToken, token);
    _prefs.setString(_expiresOn, expireOn.toIso8601String());
    _prefs.setString(_key, key);
  }

  void logout() {
    _prefs.remove(_accessToken);
    _prefs.remove(_username);
    _prefs.remove(_password);
    _prefs.remove(_cache);
  }
}
