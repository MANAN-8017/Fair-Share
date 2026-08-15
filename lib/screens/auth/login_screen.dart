import 'package:flutter/material.dart';
import '../home_screen.dart';
import './register_screen.dart';
import 'package:fair_share/services/auth_service.dart';
import '../../services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late AnimationController _dotController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    AuthService authService = AuthService();
    bool success = authService.login(email, password);

    if (success) {
      setState(() {
        isLoading = true;
      });

      NavigationService.navigateAfterDelay(
        context,
        const HomeScreen(),
        2,
      );
    }
  }

  void registerRouter(){
    setState(() {
    });
    NavigationService.navigateAfterDelay(context, const RegisterScreen(), 0);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: registerRouter,
                    child: const Text(
                      "← Back",
                      style: TextStyle(
                        color: Color(0xFF17202B),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Heading
                const Text(
                  "Welcome back.\nLet's settle up.",
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17202B),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Sign in to see who owes who.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A6472),
                  ),
                ),

                const SizedBox(height: 30),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    filled: true,
                    fillColor: const Color(0xFFF1EEE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: const Color(0xFFF1EEE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Color(0xFF1B5C53),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Login
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6452),
                      disabledBackgroundColor: const Color(0xFFFF6452),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? AnimatedBuilder(
                      animation: _dotController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDot(0),
                            const SizedBox(width: 6),
                            _buildDot(1),
                            const SizedBox(width: 6),
                            _buildDot(2),
                          ],
                        );
                      },
                    )
                        : const Text(
                      "Log in",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "New here?",
                      style: TextStyle(
                        color: Color(0xFF5A6472),
                      ),
                    ),
                    TextButton(
                      onPressed: registerRouter,
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          color: Color(0xFFE3492F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDot(int index) {
    double progress =
        (_dotController.value - (index * 0.125)) % 1.0;

    double opacity;

    if (progress < 0.4) {
      opacity = 0.25 + (progress / 0.4) * 0.75;
    } else {
      opacity = 1.0 - ((progress - 0.4) / 0.6) * 0.75;
    }

    double scale = 0.85 + (opacity - 0.25) / 0.75 * 0.15;

    final double dotSize =
        MediaQuery.of(context).size.width * 0.025;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}