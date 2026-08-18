import 'package:flutter/material.dart';
import 'theme.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const SupremoLabsApp());
}

class SupremoLabsApp extends StatelessWidget {
  const SupremoLabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supremo Labs',
      debugShowCheckedModeBanner: false,
      theme: slTheme(),
      home: const HomeScreen(),
    );
  }
}
