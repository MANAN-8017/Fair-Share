import 'package:flutter/material.dart';

class NavigationService {
  static void navigateAfterDelay(
      BuildContext context,
      Widget screen,
      int time
      ) {
    Future.delayed(
      Duration(seconds: time),
          () {
        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ),
        );
      },
    );
  }
}