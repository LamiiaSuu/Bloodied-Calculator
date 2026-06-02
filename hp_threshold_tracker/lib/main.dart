import 'package:flutter/material.dart';
import 'screens/tracker_screen.dart';

void main() {
  runApp(const HPTrackerApp());
}

class HPTrackerApp extends StatelessWidget {
  const HPTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HP Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const TrackerScreen(),
    );
  }
}
