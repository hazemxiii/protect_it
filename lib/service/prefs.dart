import 'package:protect_it/service/random_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static const String _dontShowAgain = "dontShowAgain";
  static const String _accessToken = "accessToken";
  static const String _username = "username";
  static const String _password = "password";

  static RandomPass getRandomPass() {
    return RandomPass(
        upper: prefs.getBool("upper") ?? true,
        lower: prefs.getBool("lower") ?? true,
        nums: prefs.getBool("nums") ?? true,
        length: prefs.getInt("length") ?? 13,
        specialActive: prefs.getBool("specialActive") ?? true,
        special: prefs.getStringList("special") ??
            ["\$", "#", "@", "!", "~", "&", "*", "-", "_", "+", "=", "%"]);
  }

  static Future<bool> saveRandomPassData(RandomPass r) async {
    bool success = true;
    success = await prefs.setBool("upper", r.upper);
    success = await prefs.setBool("lower", r.lower);
    success = await prefs.setBool("nums", r.nums);
    success = await prefs.setBool("specialActive", r.specialActive);
    success = await prefs.setInt("length", r.length);
    success = await prefs.setStringList("special", r.special);
    return success;
  }

  static bool getDontShowAgain() {
    return prefs.getBool(_dontShowAgain) ?? false;
  }

  static void setDontShowAgain(bool v) {
    prefs.setBool(_dontShowAgain, v);
  }

  static void setAccessToken(String token) {
    prefs.setString(_accessToken, token);
  }

  static String getAccessToken() {
    return prefs.getString(_accessToken) ?? "";
  }

  static bool get isLoggedIn =>
      prefs.getString(_username) != null && prefs.getString(_password) != null;

  static void setUsername(String username) {
    prefs.setString(_username, username);
  }

  static String? get username => prefs.getString(_username);

  static void setPassword(String password) {
    prefs.setString(_password, password);
  }

  static String? get password => prefs.getString(_password);

  static void logout() {
    prefs.remove(_accessToken);
    prefs.remove(_username);
    prefs.remove(_password);
  }
}
