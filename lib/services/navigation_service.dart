import 'package:flutter/material.dart';

class NavigationService {

  static Future<void> navigateAfterDelay(
      BuildContext context,
      Widget screen,
      int delay,
      ) async {

    if (delay > 0) {
      await Future.delayed(
        Duration(seconds: delay),
      );
    }

    if (!context.mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}