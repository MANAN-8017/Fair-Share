import 'package:flutter/material.dart';
import './register_screen.dart';
import './login_screen.dart';
import '../../services/navigation_service.dart';

class AuthOptionScreen extends StatefulWidget {
  const AuthOptionScreen({super.key});

  @override
  State<AuthOptionScreen> createState() => _AuthOptionScreenState();
}

class _AuthOptionScreenState extends State<AuthOptionScreen> {
  bool isCircle = false;
  @override
  void initState() {
    super.initState();
  }

  void loginRouter(){
    setState(() {
      isCircle = true;
    });
    NavigationService.navigateAfterDelay(context, const LoginScreen(), 0);
  }

  void registerRouter(){
    setState(() {
      isCircle = true;
    });
    NavigationService.navigateAfterDelay(context, const RegisterScreen(), 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Builder(
                builder: (context) {
                  final logoSize =
                      MediaQuery.of(context).size.width * 0.25;

                  return SizedBox(
                    width: logoSize,
                    height: logoSize,
                    child: Stack(
                      children: [
                        Positioned(
                          left: logoSize * 0.08,
                          top: logoSize * 0.32,
                          child: Container(
                            width: logoSize * 0.70,
                            height: logoSize * 0.40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F9E8F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: logoSize * 0.32,
                          top: logoSize * 0.32,
                          child: Container(
                            width: logoSize * 0.70,
                            height: logoSize * 0.40,
                            decoration: const BoxDecoration(
                              color: Color(0xE0FF6452),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

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
                  onPressed: loginRouter,
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
                  onPressed: registerRouter,
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

              if (isCircle)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF17202B),
                  ),
                ),

              const Spacer(flex: 2),

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