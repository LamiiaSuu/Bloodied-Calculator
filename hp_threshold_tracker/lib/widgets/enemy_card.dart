import 'package:flutter/material.dart';

import '../dialogs/condition_dialog.dart';
import '../models/enemy.dart';

class EnemyCard extends StatefulWidget {
  final Enemy enemy;
  final bool healMode;
  final VoidCallback onDead;
  final VoidCallback onChanged;

  const EnemyCard({
    super.key,
    required this.enemy,
    required this.healMode,
    required this.onDead,
    required this.onChanged,
  });

  @override
  State<EnemyCard> createState() => _EnemyCardState();
}

class _EnemyCardState extends State<EnemyCard> {
  late TextEditingController nameController;
  late TextEditingController hpController;
  late TextEditingController acController;
  late TextEditingController tempHpController;
  late List<String> markerOptions;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.enemy.name);

    hpController = TextEditingController(text: widget.enemy.maxHp.toString());

    acController = TextEditingController(text: widget.enemy.ac.toString());

    tempHpController = TextEditingController(
      text: widget.enemy.tempHp.toString(),
    );

    markerOptions = [];

    for (final color in [
      "RED",
      "ORANGE",
      "YELLOW",
      "GREEN",
      "BLUE",
      "PURPLE",
    ]) {
      for (int i = 1; i <= 9; i++) {
        markerOptions.add("$color $i");
      }
    }
  }

  Color getStatusColor() {
    switch (widget.enemy.status) {
      case "Healthy":
        return Colors.black;
      case "Wounded":
        return Colors.green;
      case "Bloodied":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Color markerColor(String marker) {
    final color = marker.split(" ").first;

    switch (color) {
      case "RED":
        return Colors.red;

      case "ORANGE":
        return Colors.orange;

      case "YELLOW":
        return Colors.amber;

      case "GREEN":
        return Colors.green;

      case "BLUE":
        return Colors.blue;

      case "PURPLE":
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  List<String> thresholds() {
    final maxHp = widget.enemy.maxHp;

    return [
      "75%: ${(maxHp * 0.75).floor()}",
      "50%: ${(maxHp * 0.50).floor()}",
      "25%: ${(maxHp * 0.25).floor()}",
    ];
  }

  void modifyHp(int amount) {
    if (widget.healMode) {
      widget.enemy.heal(amount);
    } else {
      widget.enemy.damage(amount);
    }
    tempHpController.clear();

    widget.onChanged();

    setState(() {});
  }

  void updateMaxHp(String value) {
    final hp = int.tryParse(value);

    if (hp == null || hp <= 0) return;

    setState(() {
      final wasFullHp = widget.enemy.currentHp == widget.enemy.maxHp;

      widget.enemy.maxHp = hp;

      if (wasFullHp) {
        widget.enemy.currentHp = hp;
      } else if (widget.enemy.currentHp > hp) {
        widget.enemy.currentHp = hp;
      }
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: markerColor(widget.enemy.marker),
                  child: Text(
                    widget.enemy.marker.split(" ").last,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: widget.enemy.marker,
                    items: markerOptions
                        .map(
                          (marker) => DropdownMenuItem(
                            value: marker,
                            child: Text(marker),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.enemy.marker = value!;
                      });

                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Enemy Name"),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                widget.enemy.name = value;
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hpController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "HP"),
                    onChanged: updateMaxHp,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: acController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "AC"),
                    onChanged: (value) {
                      setState(() {
                        widget.enemy.ac = int.tryParse(value) ?? 0;
                      });

                      widget.onChanged();
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: tempHpController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Temp"),
                    onChanged: (value) {
                      setState(() {
                        widget.enemy.tempHp = int.tryParse(value) ?? 0;
                      });

                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "HP ${widget.enemy.currentHp}/${widget.enemy.maxHp}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (widget.enemy.ac != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.enemy.currentAc == widget.enemy.ac
                            ? "AC ${widget.enemy.ac}"
                            : "AC ${widget.enemy.currentAc} (${widget.enemy.ac})",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.enemy.currentAc == widget.enemy.ac
                              ? Colors.grey[700]
                              : Colors.red,
                        ),
                      ),
                    ),

                  if (widget.enemy.tempHp != null && widget.enemy.tempHp! > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "+${widget.enemy.tempHp}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(value: widget.enemy.hpRatio),

            const SizedBox(height: 10),

            Center(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: thresholds()
                    .map(
                      (threshold) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          threshold,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                widget.enemy.status,
                style: TextStyle(
                  color: getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (widget.enemy.conditions.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.enemy.conditions.map((condition) {
                  String text = condition.name;

                  if (condition.value != null) {
                    text += " ${condition.value}";
                  }

                  return Chip(label: Text(text));
                }).toList(),
              ),

            const SizedBox(height: 15),

            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  ElevatedButton(
                    onPressed: () => modifyHp(10),
                    child: Text(widget.healMode ? "+10" : "-10"),
                  ),
                  ElevatedButton(
                    onPressed: () => modifyHp(5),
                    child: Text(widget.healMode ? "+5" : "-5"),
                  ),
                  ElevatedButton(
                    onPressed: () => modifyHp(2),
                    child: Text(widget.healMode ? "+2" : "-2"),
                  ),
                  ElevatedButton(
                    onPressed: () => modifyHp(1),
                    child: Text(widget.healMode ? "+1" : "-1"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConditionDialog(
                          enemy: widget.enemy,
                          onChanged: widget.onChanged,
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text("Conditions"),
                  ),

                  ElevatedButton.icon(
                    onPressed: widget.onDead,
                    icon: const Icon(Icons.dangerous),
                    label: const Text("Dead"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
