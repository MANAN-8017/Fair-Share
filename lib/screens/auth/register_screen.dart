import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RegisterScreen({super.key, this.onBack});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final AuthService authService = AuthService();

  Future<void> register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    setState(() {
      isLoading = true;
    });

    final response = await authService.register(
      name,
      email,
      phoneNumber,
      password,
      confirmPassword,
    );

    if (!mounted) return;

    if (response == "True") {
      AppRouter.toLogin(
        context,
        successMessage: "Account created successfully.",
      );
    } else {
      setState(() {
        isLoading = false;
      });

      AppSnackBar.error(
        context,
        response.toString(),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
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
                  child: IconButton(
                    onPressed: () {
                      AppRouter.toAuthOption(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Color(0xFF17202B),
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    tooltip: "Back",
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

                // Phone number
                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Phone Number",
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
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Create password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
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
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "Confirm password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
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
                        ? const LoadingDots(
                      color: Colors.white,
                      size: 7,
                      spacing: 6,
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
                      onPressed: () => AppRouter.toLogin(context),
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
}