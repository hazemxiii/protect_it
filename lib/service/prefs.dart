import 'package:protect_it/service/random_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static RandomPass getRandomPass() {
    return RandomPass(
        upper: prefs.getBool("upper") ?? true,
        lower: prefs.getBool("lower") ?? true,
        nums: prefs.getBool("nums") ?? true,
        length: prefs.getInt("length") ?? 13,
        specialActive: prefs.getBool("specialActive") ?? true,
        not: prefs.getStringList("not") ?? [],
        special: prefs.getStringList("special") ?? []);
  }
}
