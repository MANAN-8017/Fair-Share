import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/auth/auth.dart';
import '../services/navigation_service.dart';

class AppRouter {

  static Future<void> toLoading(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.navigateAfterDelay(
      context,
      const LoadingScreen(),
      delay,
    );
  }

  static Future<void> toAuthOption(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.clearAndNavigate(
      context,
      const AuthOptionScreen(),
      delay: delay,
    );
  }

  static Future<void> toLogin(
      BuildContext context, {
        int delay = 0,
        String? successMessage,
      }) {
    return NavigationService.replace(
      context,
      LoginScreen(
        successMessage: successMessage,
      ),
      delay: delay,
    );
  }

  static Future<void> toRegister(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.replace(
      context,
      const RegisterScreen(),
      delay: delay,
    );
  }

  static Future<void> toHome(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.clearAndNavigate(
      context,
      const HomeScreen(),
      delay: delay,
    );
  }
}