import 'package:protect_it/service/random_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static final Prefs _instance = Prefs._();
  late SharedPreferences _prefs;
  static const String _dontShowAgain = "dontShowAgain";
  static const String _accessToken = "accessToken";
  static const String _username = "username";
  static const String _password = "password";
  static const String _cache = "cache";

  Prefs._();

  factory Prefs() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  RandomPass getRandomPass() {
    return RandomPass(
        upper: _prefs.getBool("upper") ?? true,
        lower: _prefs.getBool("lower") ?? true,
        nums: _prefs.getBool("nums") ?? true,
        length: _prefs.getInt("length") ?? 13,
        specialActive: _prefs.getBool("specialActive") ?? true,
        special: _prefs.getStringList("special") ??
            ["\$", "#", "@", "!", "~", "&", "*", "-", "_", "+", "=", "%"]);
  }

  Future<bool> saveRandomPassData(RandomPass r) async {
    bool success = true;
    success = await _prefs.setBool("upper", r.upper);
    success = await _prefs.setBool("lower", r.lower);
    success = await _prefs.setBool("nums", r.nums);
    success = await _prefs.setBool("specialActive", r.specialActive);
    success = await _prefs.setInt("length", r.length);
    success = await _prefs.setStringList("special", r.special);
    return success;
  }

  bool getDontShowAgain() {
    return _prefs.getBool(_dontShowAgain) ?? false;
  }

  void login(String username, String password, String token) {
    _prefs.setString(_username, username);
    _prefs.setString(_password, password);
    _prefs.setString(_accessToken, token);
  }

  void setDontShowAgain(bool v) {
    _prefs.setBool(_dontShowAgain, v);
  }

  void setAccessToken(String token) {
    _prefs.setString(_accessToken, token);
  }

  String getAccessToken() {
    return _prefs.getString(_accessToken) ?? "";
  }

  bool get isCached => _prefs.containsKey(_cache);

  void setCache(List<String> cache) {
    _prefs.setStringList(_cache, cache);
  }

  List<String> getCache() {
    return _prefs.getStringList(_cache) ?? [];
  }

  bool get isLoggedIn =>
      _prefs.getString(_username) != null &&
      _prefs.getString(_password) != null &&
      _prefs.getString(_accessToken) != null;

  void setUsername(String username) {
    _prefs.setString(_username, username);
  }

  String? get username => _prefs.getString(_username);

  void setPassword(String password) {
    _prefs.setString(_password, password);
  }

  String? get password => _prefs.getString(_password);

  void logout() {
    _prefs.remove(_accessToken);
    _prefs.remove(_username);
    _prefs.remove(_password);
    _prefs.remove(_cache);
  }
}
