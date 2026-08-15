import 'package:fair_share/services/auth_service.dart';
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
    return NavigationService.navigateAfterDelay(
      context,
      const AuthOptionScreen(),
      delay,
    );
  }

  static Future<void> toLogin(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.navigateAfterDelay(
      context,
      const LoginScreen(),
      delay,
    );
  }

  static Future<void> toRegister(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.navigateAfterDelay(
      context,
      const RegisterScreen(),
      delay,
    );
  }

  static Future<void> toHome(
      BuildContext context, {
        int delay = 0,
      }) {
    return NavigationService.navigateAfterDelay(
      context,
      const HomeScreen(),
      delay,
    );
  }
}