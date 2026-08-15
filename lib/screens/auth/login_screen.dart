import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  final String? successMessage;
  final VoidCallback? onBack;
  const LoginScreen({super.key, this.successMessage, this.onBack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool loginWithPhone = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.successMessage != null) {
        AppSnackBar.success( context, widget.successMessage!);
      }
    });
  }

  Future<void> login() async {
    String identifier = identifierController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    String? response = await authService.login(identifier, password,);

    if (!mounted) return;

    if (response == "True") {
      AppRouter.toHome(context, delay: 2);
    }
    else {
      setState(() {
        isLoading = false;
      });
      AppSnackBar.error(context, response.toString());
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
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
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        AppRouter.toAuthOption(context);
                      }
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


                const SizedBox(height: 12),

                // Login method toggle
                Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EEE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE4E0D5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              loginWithPhone = false;
                              identifierController.clear();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !loginWithPhone
                                  ? const Color(0xFF17202B)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                color: !loginWithPhone
                                    ? Colors.white
                                    : const Color(0xFF5A6472),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              loginWithPhone = true;
                              identifierController.clear();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: loginWithPhone
                                  ? const Color(0xFF17202B)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              "Phone",
                              style: TextStyle(
                                color: loginWithPhone
                                    ? Colors.white
                                    : const Color(0xFF5A6472),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Email / Phone field
                KeyedSubtree(
                  key: ValueKey(loginWithPhone),
                  child: TextFormField(
                    controller: identifierController,
                    keyboardType: loginWithPhone
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: loginWithPhone
                          ? "Enter your phone number"
                          : "Enter your email",
                      prefixIcon: Icon(
                        loginWithPhone
                            ? Icons.phone_outlined
                            : Icons.email_outlined,
                        color: const Color(0xFF5A6472),
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
                ),

                const SizedBox(height: 8),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
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
                        ? const LoadingDots(
                      color: Colors.white,
                      size: 7,
                      spacing: 6,
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
                      onPressed: () => AppRouter.toRegister(context),
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
}