import 'package:flutter/material.dart';
import 'screens/auth/loading_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    ),
  );
}