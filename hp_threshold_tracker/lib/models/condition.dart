class Condition {
  String name;
  int? value;

  Condition({required this.name, this.value});

  bool get hasValue => value != null;

  void increase(int amount) {
    if (value == null) {
      value = amount;
    } else {
      value = value! + amount;
    }
  }

  bool decrease(int amount) {
    if (value == null) {
      return true;
    }

    value = value! - amount;

    return value! <= 0;
  }
}
