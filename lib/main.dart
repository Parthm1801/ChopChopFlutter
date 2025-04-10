import 'package:flutter/material.dart';
import 'screens/goal_setup_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChopChopPage(),
  ));
}

class ChopChopApp extends StatelessWidget {
  const ChopChopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChopChopPage(), // 👈 Main goal-setting screen
    );
  }
}

