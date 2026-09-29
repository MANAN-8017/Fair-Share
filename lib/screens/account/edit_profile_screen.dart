import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AccountService accountService = AccountService();
  final ValidationService validationService = ValidationService();

  // ---- Profile (name + avatar) ----
  final _profileFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _avatarUrl;
  bool isLoading = true;
  bool isSavingProfile = false;
  bool isUploadingAvatar = false;
  String? profileErrorText;

  // ---- Email ----
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  String _originalEmail = "";
  bool isSavingEmail = false;
  String? emailErrorText;

  // ---- Password ----
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isSavingPassword = false;
  String? passwordErrorText;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await accountService.getProfile();

    if (!mounted) return;
    setState(() {
      _nameController.text = profile?['name'] ?? "";
      _emailController.text = profile?['email'] ?? "";
      _originalEmail = profile?['email'] ?? "";
      _avatarUrl = profile?['avatar_url'];
      isLoading = false;
    });
  }

  // ---------------- Avatar ----------------

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF8F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E0D5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF17202B)),
              title: const Text("Take Photo", style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF17202B)),
              title: const Text("Choose from Gallery", style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6452)),
                title: const Text("Remove Photo", style: TextStyle(color: Color(0xFFFF6452), fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 800);
    if (picked == null) return;

    setState(() => isUploadingAvatar = true);
    final bytes = await picked.readAsBytes();
    final result = await accountService.uploadAvatar(bytes);
    if (!mounted) return;

    setState(() {
      isUploadingAvatar = false;
      if (result != null) _avatarUrl = result.toString();
    });

    if (result == null) {
      AppSnackBar.error(context, "Couldn't upload photo. Please try again.");
    } else {
      AppSnackBar.success(context, "Profile Picture Updated!");
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => isUploadingAvatar = true);
    final result = await accountService.removeAvatar();
    if (!mounted) return;

    setState(() {
      isUploadingAvatar = false;
      if (result == "True") _avatarUrl = null;
    });

    if (result != "True") {
      AppSnackBar.error(context, "Couldn't remove photo. Please try again.");
    }
  }

  // ---------------- Save handlers ----------------

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() {
      isSavingProfile = true;
      profileErrorText = null;
    });

    final result = await accountService.updateProfile(name: _nameController.text.trim());

    if (!mounted) return;

    if (result == "True") {
      setState(() => isSavingProfile = false);
      AppSnackBar.success(context, "Profile updated.");
    } else {
      setState(() {
        isSavingProfile = false;
        profileErrorText = result ?? "Something went wrong. Please try again.";
      });
    }
  }

  Future<void> _saveEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final val = ValidationService.validate(_emailController.text.trim(), type: ValidationType.email);

    if(val != null){
      return;
    }

    if (_emailController.text.trim() == _originalEmail) {
      setState(() => emailErrorText = "That's already your current email.");
      return;
    }

    setState(() {
      isSavingEmail = true;
      emailErrorText = null;
    });

    final result = await accountService.updateEmail(
      newEmail: _emailController.text.trim(),
      currentPassword: _emailPasswordController.text,
    );

    if (!mounted) return;

    if (result == "True") {
      _originalEmail = _emailController.text.trim();
      _emailPasswordController.clear();
      setState(() => isSavingEmail = false);
      AppSnackBar.success(context, "Check your inbox to confirm your new email.");
    } else {
      setState(() {
        isSavingEmail = false;
        emailErrorText = result ?? "Something went wrong. Please try again.";
      });
    }
  }

  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      isSavingPassword = true;
      passwordErrorText = null;
    });

    final result = await accountService.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (result == "True") {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => isSavingPassword = false);
      AppSnackBar.success(context, "Password updated.");
    } else {
      setState(() {
        isSavingPassword = false;
        passwordErrorText = result ?? "Something went wrong. Please try again.";
      });
    }
  }

  // ---------------- UI helpers ----------------

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

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E0D5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _saveButton({required bool isSaving, required VoidCallback onPressed, required String label}) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF17202B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isSaving
            ? const LoadingDots(color: Colors.white, size: 6, spacing: 6)
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- Avatar ----
                    Center(
                      child: GestureDetector(
                        onTap: isUploadingAvatar ? null : _showImageSourceSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _avatarUrl == null
                                    ? const LinearGradient(colors: [Color(0xFF3CB6A6), Color(0xFF1B5C53)])
                                    : null,
                                image: _avatarUrl != null
                                    ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: isUploadingAvatar
                                  ? const Center(
                                child: LoadingDots(color: Colors.white, size: 6, spacing: 6),
                              )
                                  : (_avatarUrl == null
                                  ? Center(
                                child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "?",
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              )
                                  : null),
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
                    ),
                    const SizedBox(height: 28),

                    // ---- Name ----
                    _sectionLabel("PROFILE"),
                    const SizedBox(height: 10),
                    Form(
                      key: _profileFormKey,
                      child: _sectionCard(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: _decoration("Full Name"),
                            validator: (value) => ValidationService.validate(value ?? "", type: ValidationType.name),
                          ),
                          if (profileErrorText != null) ...[
                            const SizedBox(height: 10),
                            Text(profileErrorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                          ],
                          const SizedBox(height: 14),
                          _saveButton(isSaving: isSavingProfile, onPressed: _saveProfile, label: "Save Name"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Email ----
                    _sectionLabel("EMAIL"),
                    const SizedBox(height: 10),
                    Form(
                      key: _emailFormKey,
                      child: _sectionCard(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _decoration("New Email"),
                            validator: (value) => ValidationService.validate(value ?? "", type: ValidationType.email),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailPasswordController,
                            obscureText: true,
                            decoration: _decoration("Current Password"),
                            validator: (value) => ValidationService.validate(value ?? "", type: ValidationType.required),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Confirm your password to change your email.",
                            style: TextStyle(fontSize: 12, color: Color(0xFF9AA2AC)),
                          ),
                          if (emailErrorText != null) ...[
                            const SizedBox(height: 10),
                            Text(emailErrorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                          ],
                          const SizedBox(height: 14),
                          _saveButton(isSaving: isSavingEmail, onPressed: _saveEmail, label: "Update Email"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- Password ----
                    _sectionLabel("PASSWORD"),
                    const SizedBox(height: 10),
                    Form(
                      key: _passwordFormKey,
                      child: _sectionCard(
                        children: [
                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            decoration: _decoration("Current Password"),
                            validator: (value) => ValidationService.validate(value ?? "", type: ValidationType.required),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: _decoration("New Password"),
                            validator: (value) => ValidationService.validate(
                              value ?? "",
                              type: ValidationType.password,
                              minLength: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _decoration("Confirm New Password"),
                            validator: (value) => ValidationService.validate(
                              value ?? "",
                              type: ValidationType.confirmPassword,
                              compareValue: _newPasswordController.text.trim(),
                            ),
                          ),
                          if (passwordErrorText != null) ...[
                            const SizedBox(height: 10),
                            Text(passwordErrorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                          ],
                          const SizedBox(height: 14),
                          _saveButton(isSaving: isSavingPassword, onPressed: _savePassword, label: "Update Password"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}