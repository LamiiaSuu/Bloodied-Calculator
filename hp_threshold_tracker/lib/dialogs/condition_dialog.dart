import 'package:flutter/material.dart';

import '../models/condition.dart';
import '../models/enemy.dart';

class ConditionDialog extends StatefulWidget {
  final Enemy enemy;
  final VoidCallback onChanged;

  const ConditionDialog({
    super.key,
    required this.enemy,
    required this.onChanged,
  });

  @override
  State<ConditionDialog> createState() => _ConditionDialogState();
}

class _ConditionDialogState extends State<ConditionDialog> {
  final List<String> conditionOptions = [
    "Blinded",
    "Clumsy",
    "Concealed",
    "Confused",
    "Controlled",
    "Dazzled",
    "Deafened",
    "Doomed",
    "Drained",
    "Dying",
    "Enfeebled",
    "Fascinated",
    "Fatigued",
    "Frightened",
    "Grabbed",
    "Hidden",
    "Invisible",
    "Off-Guard",
    "Paralyzed",
    "Persistent Acid",
    "Persistent Bleed",
    "Persistent Cold",
    "Persistent Electricity",
    "Persistent Fire",
    "Persistent Poison",
    "Petrified",
    "Prone",
    "Restrained",
    "Sickened",
    "Slowed",
    "Stupefied",
    "Unconscious",
    "Wounded",
  ];

  String selected = "Off-Guard";

  void addOrIncrease(int? amount) {
    for (final condition in widget.enemy.conditions) {
      if (condition.name == selected) {
        if (amount != null) {
          condition.increase(amount);
        }

        widget.onChanged();

        setState(() {});
        return;
      }
    }

    widget.enemy.conditions.add(Condition(name: selected, value: amount));

    widget.onChanged();
    setState(() {});
  }

  void modifySelected(int index, int? amount) {
    final condition = widget.enemy.conditions[index];

    if (amount == null) {
      widget.enemy.conditions.removeAt(index);
    } else {
      final remove = condition.decrease(amount);

      if (remove) {
        widget.enemy.conditions.removeAt(index);
      }
    }

    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Conditions"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selected,
              isExpanded: true,
              items: conditionOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selected = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => addOrIncrease(null),
                    child: const Text("ADD"),
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text("+1"),
                      onPressed: () => addOrIncrease(1),
                    ),
                    ActionChip(
                      label: const Text("+2"),
                      onPressed: () => addOrIncrease(2),
                    ),
                    ActionChip(
                      label: const Text("+3"),
                      onPressed: () => addOrIncrease(3),
                    ),
                    ActionChip(
                      label: const Text("+4"),
                      onPressed: () => addOrIncrease(4),
                    ),
                    ActionChip(
                      label: const Text("+5"),
                      onPressed: () => addOrIncrease(5),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: widget.enemy.conditions.length,
                itemBuilder: (context, index) {
                  final c = widget.enemy.conditions[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.value == null ? c.name : "${c.name} ${c.value}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => modifySelected(index, null),
                              child: const Text("REMOVE"),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    onPressed: () => modifySelected(index, 1),
                                    child: const Text("-1"),
                                  ),
                                ),

                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (c.value == null) {
                                          c.value = 1;
                                        } else {
                                          c.value = c.value! + 1;
                                        }
                                      });

                                      widget.onChanged();
                                    },
                                    child: const Text("+1"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
