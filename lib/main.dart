import 'package:flutter/material.dart';
import 'screens/auth/loading_screen.dart';

void main() {
  runApp(const FairShareApp());
}

class FairShareApp extends StatelessWidget {
  const FairShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FairShare',
      home: const LoadingScreen(),
    );
  }
}