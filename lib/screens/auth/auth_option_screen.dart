import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../widgets/widgets.dart';

class AuthOptionScreen extends StatelessWidget {
  const AuthOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              FairShareLogo(size: logoSize),

              const SizedBox(height: 25),

              // Heading
              const Text(
                "Welcome to FairShare",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17202B),
                ),
              ),

              const SizedBox(height: 10),

              // Description
              const Text(
                "Split expenses. Track balances.\nKeep friendships simple.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF5A6472),
                ),
              ),

              const Spacer(),

              // Login
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => AppRouter.toLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6452),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Register
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => AppRouter.toRegister(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF17202B),
                    side: const BorderSide(
                      color: Color(0xFF17202B),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Create an account",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Spacer(flex: 2),

              // Footer
              const Text(
                "FairShare • Simple expense sharing",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9AA2AC),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}