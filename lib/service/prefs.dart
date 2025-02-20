import 'package:protect_it/service/random_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static const String _dontShowAgain = "dontShowAgain";

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
}
