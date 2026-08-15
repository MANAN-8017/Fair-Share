import 'package:flutter/material.dart';
import './login_screen.dart';
import './auth_option.dart';
import 'package:fair_share/services/auth_service.dart';
import '../../services/navigation_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin
{
  bool isCircle = false;

  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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

  void register() {
    String username = usernameController.text.trim();
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    AuthService authService = AuthService();
    bool success = authService.register(username, name, email, password, confirmPassword);

    if(success){
      setState(() {
        isLoading = true;
      });
      NavigationService.navigateAfterDelay(context, const LoginScreen(), 2);
    }
  }

  void loginRouter(){
    setState(() {
      isLoading = true;
    });
    NavigationService.navigateAfterDelay(context, const LoginScreen(), 0);
  }

  void authOptionRouter() {
    setState(() {
      isCircle = true;
    });
    NavigationService.navigateAfterDelay(context, const AuthOptionScreen(), 0);
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                    onPressed: authOptionRouter,
                    child: const Text(
                      "← Back",
                      style: TextStyle(
                        color: Color(0xFF17202B),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Heading
                const Text(
                  "Split bills without\nthe awkward math.",
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17202B),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Set up your account in under a minute.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A6472),
                  ),
                ),

                const SizedBox(height: 30),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Full name",
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

                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
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

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email address",
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
                    hintText: "Create password",
                    suffixIcon: const Icon(Icons.visibility_off_outlined),
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

                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Confirm password",
                    suffixIcon: const Icon(Icons.visibility_off_outlined),
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

                const SizedBox(height: 18),

                // Register
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
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
                      "Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already a member?",
                      style: TextStyle(
                        color: Color(0xFF5A6472),
                      ),
                    ),
                    TextButton(
                      onPressed: loginRouter,
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Color(0xFFE3492F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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