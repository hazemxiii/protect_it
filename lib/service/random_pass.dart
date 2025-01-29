import 'dart:math';

class RandomPass {
  late int _length;
  final Set<String> _special = {};

  late bool _upper;
  late bool _lower;
  late bool _nums;
  late bool _specialActive;

  final Map<String, Function> _generator = {};

  RandomPass({
    required bool upper,
    required bool lower,
    required bool nums,
    required int length,
    required bool specialActive,
    required List<String> special,
  }) {
    _length = length;
    _upper = upper;
    _lower = lower;
    _nums = nums;
    _special.addAll(special);
    _specialActive = specialActive;
  }

  void _setGenerators() {
    if (_upper) {
      int a = "A".codeUnitAt(0);
      int z = "Z".codeUnitAt(0);
      _generator['upper'] = () {
        return String.fromCharCode(Random().nextInt(z - a + 1) + a);
      };
    } else {
      _generator.remove("upper");
    }
    if (_lower) {
      _generator['lower'] = () {
        int a = "a".codeUnitAt(0);
        int z = "z".codeUnitAt(0);
        return String.fromCharCode(Random().nextInt(z - a + 1) + a);
      };
    } else {
      _generator.remove("lower");
    }
    if (_nums) {
      _generator['nums'] = () => Random().nextInt(10).toString();
    } else {
      _generator.remove("nums");
    }
    if (_specialActive && _special.isNotEmpty) {
      _special.addAll(special);
      _generator['special'] =
          () => _special.elementAt(Random().nextInt(_special.length));
    } else {
      _specialActive = false;
      _generator.remove("special");
    }
  }

  String create() {
    _setGenerators();
    String s = "";
    for (int i = 0; i < _length; i++) {
      List<String> keys = _generator.keys.toList();
      if (keys.isEmpty) {
        return "";
      }
      try {
        s += _generator[keys[Random().nextInt(keys.length)]]!();
      } catch (e) {
        s += "";
      }
    }
    return s;
  }

  void setUpper(bool v) {
    _upper = v;
  }

  void setLower(bool v) {
    _lower = v;
  }

  void setSpecialActive(bool v) {
    _specialActive = v;
  }

  void setNums(bool v) {
    _nums = v;
  }

  void setSpecial(String s) {
    _special.clear();
    _special.addAll(s.split("").toSet());
    if (_special.isEmpty) {
      _specialActive = false;
    }
  }

  void setLength(int l) {
    _length = l;
  }

  bool get upper => _upper;
  bool get lower => _lower;
  bool get nums => _nums;
  bool get specialActive => _specialActive;
  int get length => _length;
  List<String> get special => _special.toList();
}
