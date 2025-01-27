import 'dart:math';

class RandomPass {
  late int _length;
  final Set<String> _special = {
    "\$",
    "#",
    "@",
    "!",
    "~",
    "&",
    "*",
    "-",
    "_",
    "+",
    "=",
    "%"
  };

  final Map<String, Function> _generator = {};

  RandomPass(
      {required bool upper,
      required bool lower,
      required bool nums,
      required int length,
      required bool specialActive,
      required List<String> special,
      required List<String> not}) {
    _length = length;
    if (upper) {
      int a = "A".codeUnitAt(0);
      int z = "Z".codeUnitAt(0);
      _generator['upper'] = () {
        return String.fromCharCode(Random().nextInt(z - a + 1) + a);
      };
    }
    if (lower) {
      _generator['lower'] = () {
        int a = "a".codeUnitAt(0);
        int z = "z".codeUnitAt(0);
        return String.fromCharCode(Random().nextInt(z - a + 1) + a);
      };
    }
    if (nums) {
      _generator['nums'] = () => Random().nextInt(10).toString();
    }
    if (specialActive) {
      _special.addAll(special);
      _special.removeAll(not);
      _generator['special'] =
          () => _special.elementAt(Random().nextInt(_special.length));
    }
  }

  String create() {
    String s = "";
    while (s.length < _length) {
      List<String> keys = _generator.keys.toList();
      s += _generator[keys[Random().nextInt(keys.length)]]!();
    }
    return s;
  }
}
