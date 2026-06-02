import 'condition.dart';

class Enemy {
  String name;
  int maxHp;
  int currentHp;
  String marker;
  int ac;
  int tempHp;

  List<Condition> conditions;

  Enemy({
    required this.name,
    required this.maxHp,
    required this.currentHp,
    required this.marker,
    required this.ac,
    required this.tempHp,
    List<Condition>? conditions,
  }) : conditions = conditions ?? [];

  double get hpRatio {
    if (maxHp <= 0) return 0;
    return currentHp / maxHp;
  }

  String get status {
    if (hpRatio > 0.75) return "Healthy";
    if (hpRatio > 0.50) return "Wounded";
    if (hpRatio > 0.25) return "Bloodied";
    return "Critical";
  }

  void damage(int amount) {
    if (tempHp > 0) {
      if (amount <= tempHp) {
        tempHp -= amount;
        return;
      }

      amount -= tempHp;
      tempHp = 0;
    }

    currentHp = (currentHp - amount).clamp(0, maxHp);
  }

  int get currentAc {
    if (ac == null) return 0;

    int result = ac!;

    for (final condition in conditions) {
      switch (condition.name) {
        case "Off-Guard":
          result -= 2;
          break;

        case "Clumsy":
        case "Frightened":
        case "Sickened":
          result -= (condition.value ?? 1);
          break;
      }
    }

    return result;
  }

  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }
}
