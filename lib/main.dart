import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KemsApp());
}

class KemsApp extends StatelessWidget {
  const KemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kems',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade800),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}