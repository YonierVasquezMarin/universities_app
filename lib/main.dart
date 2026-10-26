import 'package:flutter/material.dart';
import 'package:universities_app/screens/universities_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _seedColor = Color(0xFF1B4D72);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universidades App',
      theme: _buildTheme(),
      home: const UniversitiesHomePage(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seedColor));
  }
}
