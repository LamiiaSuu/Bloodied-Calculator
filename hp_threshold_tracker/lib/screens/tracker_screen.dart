import 'package:flutter/material.dart';

import '../models/enemy.dart';
import '../widgets/enemy_card.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<Enemy> enemies = [];
  final List<Enemy> graveyard = [];

  bool healMode = false;

  @override
  void initState() {
    super.initState();

    enemies.add(
      Enemy(
        name: "Enemy 1",
        maxHp: 10,
        currentHp: 10,
        marker: "RED 1",
        ac: 15,
        tempHp: 0,
      ),
    );
  }

  String getNextMarker(int index) {
    const colors = ["RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "PURPLE"];

    final colorIndex = index ~/ 9;
    final number = (index % 9) + 1;

    final color = colors[colorIndex % colors.length];

    return "$color $number";
  }

  void addEnemy() {
    setState(() {
      enemies.add(
        Enemy(
          name: "Enemy ${enemies.length + 1}",
          maxHp: 10,
          currentHp: 10,
          marker: getNextMarker(enemies.length),
          ac: 15,
          tempHp: 0,
        ),
      );
    });
  }

  void markDead(Enemy enemy) {
    setState(() {
      enemies.remove(enemy);
      graveyard.add(enemy);
    });
  }

  void resetEncounter() {
    setState(() {
      enemies.clear();
      graveyard.clear();

      enemies.add(
        Enemy(
          name: "Enemy 1",
          maxHp: 10,
          currentHp: 10,
          marker: getNextMarker(enemies.length),
          ac: 15,
          tempHp: 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lamia's Bloodied Tracker"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                healMode = !healMode;
              });
            },
            icon: Icon(healMode ? Icons.favorite : Icons.gps_fixed),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addEnemy,
        child: const Icon(Icons.add),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ListView(
          children: [
            ...enemies.map(
              (enemy) => EnemyCard(
                enemy: enemy,
                healMode: healMode,
                onDead: () => markDead(enemy),
                onChanged: () => setState(() {}),
              ),
            ),

            if (graveyard.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Graveyard",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              ...graveyard.map(
                (enemy) => ListTile(
                  leading: const Icon(Icons.dangerous),
                  title: Text(enemy.name),
                  subtitle: Text("HP ${enemy.currentHp}/${enemy.maxHp}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        graveyard.remove(enemy);
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
