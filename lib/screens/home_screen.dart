import 'package:fair_share/screens/auth/auth_option.dart';
import 'package:fair_share/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'package:fair_share/services/auth_service.dart';
import '../services/navigation_service.dart';
import './auth/loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCircle = false;

  String name = mockUsers[0]['name'] as String;
  AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
  }

  void logoutRouter(){
    authService.logout();
    setState(() {
      isCircle = true;
    });
    NavigationService.navigateAfterDelay(context, const LoginScreen(), 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: Column(
          children: [

            // Everything above bottom navigation
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // Top section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "GOOD EVENING",
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5C53),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hi, $name",
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF17202B),
                                ),
                              ),
                            ],
                          ),

                          // Profile
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF3CB6A6),
                                  Color(0xFF1B5C53),
                                ],
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              offset: const Offset(0, 45),
                              onSelected: (value) {
                                if (value == 'logout') {
                                  logoutRouter();
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'logout',
                                  child: Text("Logout"),
                                ),
                              ],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Balance card
                    Container(
                      margin: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17202B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "OVERALL BALANCE",
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1,
                                  color: Color(0x889AA2AC),
                                ),
                              ),
                              Text(
                                "+\$142.50",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7FE0CC),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              Expanded(
                                child: _balancePill(
                                  "YOU OWE",
                                  "\$38.00",
                                  const Color(0xFFFF9686),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _balancePill(
                                  "YOU'RE OWED",
                                  "\$180.50",
                                  const Color(0xFF7FE0CC),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Groups
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "GROUPS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Color(0xFF5A6472),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 115,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        scrollDirection: Axis.horizontal,
                        children: [
                          _groupCard(
                            "?",
                            "Flatmates",
                            "+\$64.00",
                            const Color(0xFF2F9E8F),
                          ),
                          const SizedBox(width: 12),
                          _groupCard(
                            "?",
                            "Goa Trip",
                            "-\$22.00",
                            const Color(0xFFFF6452),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Recent activity
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "RECENT ACTIVITY",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Color(0xFF5A6472),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _activityRow(
                      "??",
                      "Dinner at Otto's",
                      "Priya paid · Flatmates",
                      "+\$24.50",
                      const Color(0xFF1B5C53),
                    ),

                    _activityRow(
                      "?",
                      "Airport cab",
                      "You paid · Goa Trip",
                      "-\$14.00",
                      const Color(0xFFE3492F),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed bottom navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE4E0D5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(Icons.home_outlined, "Home", true),
                  _NavItem(Icons.people_outline, "Groups", false),
                  _NavItem(Icons.add, "Add", false),
                  _NavItem(Icons.person_outline, "Account", false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _balancePill(
      String label,
      String value,
      Color valueColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              color: Color(0x889AA2AC),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(
      String icon,
      String groupName,
      String amount,
      Color iconColor,
      ) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E0D5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          Text(
            groupName,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17202B),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF9AA2AC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow(
      String icon,
      String title,
      String subtitle,
      String amount,
      Color iconColor,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE4E0D5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17202B),
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF9AA2AC),
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(
      this.icon,
      this.label,
      this.active,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: active
              ? const Color(0xFFE3492F)
              : const Color(0xFF9AA2AC),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: active
                ? const Color(0xFFE3492F)
                : const Color(0xFF9AA2AC),
          ),
        ),
      ],
    );
  }
}