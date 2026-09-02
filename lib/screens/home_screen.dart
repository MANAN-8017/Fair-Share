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
  List<Map<String, dynamic>> userGroups = [];
  bool isLoadingGroups = true;

  double totalOwedToMe = 0.0;
  double totalIOwe = 0.0;

  @override
  void initState() {
    super.initState();
    setGreeting();
    loadUser();
    loadGroups();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.successMessage != null) {
        AppSnackBar.success(context, widget.successMessage!);
      }
    });
  }

  Future<void> loadGroups() async {
    final GroupService groupService = GroupService();
    final ExpenseService expenseService = ExpenseService();
    final groups = await groupService.getUserGroups();
    final currentUserId = authService.supabase.auth.currentUser!.id;

    double tempOwed = 0.0;
    double tempOwe = 0.0;

    for (var group in groups) {
      double bal = await expenseService.calculateUserBalanceInGroup(group['id'], currentUserId);
      group['my_balance'] = bal;

      if (bal > 0) {
        tempOwed += bal;
      } else {
        tempOwe += bal.abs();
      }
    }

    if (!mounted) return;

    setState(() {
      userGroups = groups;
      totalOwedToMe = tempOwed;
      totalIOwe = tempOwe;
      isLoadingGroups = false;
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
    setState(() => isLoading = true);
    AppRouter.toLogin(context, delay: 2);
  }

  @override
  Widget build(BuildContext context) {
    final overallBalance = totalOwedToMe - totalIOwe;
    final overallPrefix = overallBalance >= 0 ? "+" : "-";
    final overallColor = overallBalance >= 0 ? const Color(0xFF7FE0CC) : const Color(0xFFFF9686);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Profile Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting.toUpperCase(),
                                style: const TextStyle(
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
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF3CB6A6), Color(0xFF1B5C53)],
                            ),
                          ),
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 2),
                            position: PopupMenuPosition.under,
                            onSelected: (value) {
                              if (value == 'logout') logout();
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(value: 'logout', child: Text("Logout")),
                            ],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance Card
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
                          children: [
                            const Text(
                              "OVERALL BALANCE",
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1,
                                color: Color(0x889AA2AC),
                              ),
                            ),
                            Text(
                              "$overallPrefix₹${overallBalance.abs().toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: overallColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: BalancePill(
                                label: "YOU OWE",
                                value: "₹${totalIOwe.toStringAsFixed(2)}",
                                valueColor: const Color(0xFFFF9686),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BalancePill(
                                label: "YOU'RE OWED",
                                value: "₹${totalOwedToMe.toStringAsFixed(2)}",
                                valueColor: const Color(0xFF7FE0CC),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Groups Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "RECENT GROUPS",
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

                  // 2x2 Groups Grid
                  if (isLoadingGroups)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8),
                      ),
                    )
                  else if (userGroups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          "No groups yet. Go to Groups to create one!",
                          style: TextStyle(color: Color(0xFF5A6472), fontSize: 14),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: userGroups.length > 4 ? 4 : userGroups.length,
                      itemBuilder: (context, index) {
                        final group = userGroups[index];
                        final groupName = group['name'] as String? ?? 'Group';
                        final iconChar = groupName.isNotEmpty ? groupName[0].toUpperCase() : '?';
                        final iconColor = (index % 2 == 0) ? const Color(0xFF2F9E8F) : const Color(0xFFFF6452);

                        final balance = group['my_balance'] as double? ?? 0.0;
                        String amountText;
                        Color amountColor;

                        if (balance > 0) {
                          amountText = "+₹${balance.toStringAsFixed(2)}";
                          amountColor = const Color(0xFF2F9E8F);
                        } else if (balance < 0) {
                          amountText = "-₹${balance.abs().toStringAsFixed(2)}";
                          amountColor = const Color(0xFFFF6452);
                        } else {
                          amountText = "Settled";
                          amountColor = const Color(0xFF9AA2AC);
                        }

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final result = await AppRouter.toGroupDetails(context, group);
                            if (result == true) {
                              setState(() => isLoadingGroups = true);
                              loadGroups();
                            }
                          },
                          child: GroupCard(
                            icon: iconChar,
                            groupName: groupName,
                            amount: amountText,
                            iconColor: iconColor,
                            amountColor: amountColor,
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
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
    );
  }
}