import 'package:flutter/material.dart';

void main() {
  runApp(const FairShare());
}

class FairShare extends StatefulWidget {
  const FairShare({super.key});

  @override
  State<FairShare> createState() => _FairShareState();
}

class _FairShareState extends State<FairShare> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(style: (TextStyle(fontSize: 24, fontFamily: "Times New Roman" ,fontWeight: FontWeight.bold)),
                'Welcome to FairShare'
              ),
            ],
          ),
        ),
      ),
    );
  }
}