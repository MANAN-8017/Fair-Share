import 'package:flutter/material.dart';
import '../data/retriever.dart';
import '../routes/routes.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final String? successMessage;
  const HomeScreen({super.key, this.successMessage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthService authService = AuthService();
  final Retriever retriever = Retriever();

  String greeting = "Good evening";
  String? name = "User";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setGreeting();
    loadUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.successMessage != null) {
        AppSnackBar.success(context, widget.successMessage!);
      }
    });
  }

  void setGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      greeting = "Good morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good evening";
    } else {
      greeting = "Good night";
    }
  }

  Future<void> loadUser() async {
    final userName = await retriever.getName();

    if (!mounted) return;

    setState(() {
      if (userName != null && userName.isNotEmpty) {
        name = userName;
      }
    });
  }

  Future<void> logout() async {
    authService.logout();
    setState(() {
      isLoading = true;
    });
    AppRouter.toLogin(context, delay: 2);
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
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting.toUpperCase(),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF17202B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

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
                              offset: const Offset(0, 2),
                              position: PopupMenuPosition.under,
                              onSelected: (value) {
                                if (value == 'logout') {
                                  logout();
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem<String>(
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
                      )
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
                                child:
                                BalancePill(
                                  label: "YOU OWE",
                                  value: "\$38.00",
                                  valueColor: const Color(0xFFFF9686),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child:
                                BalancePill(
                                  label: "YOU'RE OWED",
                                  value: "\$180.50",
                                  valueColor: const Color(0xFF7FE0CC),
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
                          GroupCard(
                            icon: "?",
                            groupName: "Flatmates",
                            amount: "+\$64.00",
                            iconColor: const Color(0xFF2F9E8F),
                          ),
                          const SizedBox(width: 12),
                          GroupCard(
                            icon: "?",
                            groupName: "Goa Trip",
                            amount: "+\$22.00",
                            iconColor: const Color(0xFFFF6452),
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
                    ActivityRow(icon: "??", title: "Dinner at Otto's", subtitle: "Priya paid → Flatmates", amount: "+\$24.50", iconColor: const Color(0xFF1B5C53)),
                    ActivityRow(icon: "?", title: "Airport cab", subtitle: "You paid · Goa Trip", amount: "+\$14.00", iconColor: const Color(0xFFE3492F)),
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
                  NavItem(Icons.home_outlined, "Home", true),
                  NavItem(Icons.people_outline, "Groups", false),
                  NavItem(Icons.add, "Add", false),
                  NavItem(Icons.person_outline, "Account", false),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: const Color(0xFFFAF8F3),
                child: const Center(
                  child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8,),
                ),
              ),
          ],
        ),
      ),
    );
  }
}