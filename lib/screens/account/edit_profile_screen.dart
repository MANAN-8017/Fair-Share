import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AccountService accountService = AccountService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await accountService.getProfile();

    if (!mounted) return;
    setState(() {
      _nameController.text = profile?['name'] ?? "";
      _emailController.text = profile?['email'] ?? "";
      isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      errorText = null;
    });

    final result = await accountService.updateProfile(
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (result == "True") {
      AppRouter.toLayout(context, 3);
    } else {
      setState(() {
        isSaving = false;
        errorText = result ?? "Something went wrong. Please try again.";
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF5A6472), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1EEE5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E0D5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E0D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F9E8F)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 22, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF17202B)),
                  ),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF3CB6A6), Color(0xFF1B5C53)],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "?",
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6452),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFAF8F3), width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      TextFormField(
                        controller: _nameController,
                        decoration: _decoration("Full Name"),
                        validator: (value) => ValidationService.validate(
                          value ?? "",
                          type: ValidationType.name,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        decoration: _decoration("Email"),
                      ),

                      if (errorText != null) ...[
                        const SizedBox(height: 14),
                        Text(errorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17202B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const LoadingDots(color: Colors.white, size: 6, spacing: 6)
                              : const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}