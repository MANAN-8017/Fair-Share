import 'package:flutter/material.dart';
import '../../data/retriever.dart';
import '../../routes/routes.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService authService = AuthService();
  final Retriever retriever = Retriever();
  final AccountService accountService = AccountService();

  String? name;
  String? email;
  bool isLoadingProfile = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userName = await retriever.getName();
    final currentUser = authService.supabase.auth.currentUser;

    if (!mounted) return;
    setState(() {
      name = (userName != null && userName.isNotEmpty) ? userName : "User";
      email = currentUser?.email ?? "";
      isLoadingProfile = false;
    });
  }

  Future<void> logout() async {
    authService.logout();
    setState(() => isLoading = true);
    AppRouter.toLogin(context, delay: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 24, 22, 10),
                    child: Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF17202B),
                      ),
                    ),
                  ),

                  Expanded(
                    child: isLoadingProfile
                        ? const Center(
                      child: LoadingDots(
                        color: Color(0xFFFF6452),
                        size: 8,
                        spacing: 8,
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17202B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF3CB6A6),
                                        Color(0xFF1B5C53),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (name != null && name!.isNotEmpty)
                                          ? name![0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name ?? "User",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (email != null && email!.isNotEmpty)
                                            ? email!
                                            : "No email on file",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0x889AA2AC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "SETTINGS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Color(0xFF5A6472),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _AccountRow(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF2F9E8F),
                            title: "Edit Profile",
                            subtitle: "Name, email and photo",
                            onTap: () async { await AppRouter.toEditProfile(context);
                            if (mounted) {
                              _loadProfile();
                            }},
                          ),
                          const SizedBox(height: 12),
                          _AccountRow(
                            icon: Icons.notifications_none_rounded,
                            iconColor: const Color(0xFF6C63A6),
                            title: "Notifications",
                            subtitle: "Reminders and alerts",
                            onTap: () { AppRouter.toNotificationSettings(context); },
                          ),
                          const SizedBox(height: 12),
                          _AccountRow(
                            icon: Icons.currency_rupee_rounded,
                            iconColor: const Color(0xFFC98A2C),
                            title: "Payment Details",
                            subtitle: "Manage settlement info",
                            onTap: () { AppRouter.toPaymentDetails(context); },
                          ),

                          const SizedBox(height: 24),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "SUPPORT",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Color(0xFF5A6472),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _AccountRow(
                            icon: Icons.help_outline_rounded,
                            iconColor: const Color(0xFF2F9E8F),
                            title: "Help & Support",
                            subtitle: "FAQs and contact",
                            onTap: () { AppRouter.toHelpSupport(context); },
                          ),
                          const SizedBox(height: 12),
                          _AccountRow(
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFF5A6472),
                            title: "About FairShare",
                            subtitle: "Version and legal info",
                            onTap: () { AppRouter.toAbout(context); },
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: logout,
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 20,
                                color: Color(0xFFFF6452),
                              ),
                              label: const Text(
                                "Log Out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Color(0xFFFF6452),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFF9686),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (isLoading)
                Container(
                  color: const Color(0xFFFAF8F3),
                  child: const Center(
                    child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8),
                  ),
                ),
            ],
          ),
        )
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EEE5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E0D5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF17202B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA2AC),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9AA2AC),
            ),
          ],
        ),
      ),
    );
  }
}