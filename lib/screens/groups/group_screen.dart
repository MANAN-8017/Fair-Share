import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final AuthService authService = AuthService();

  bool isLoading = false;
  List<Map<String, dynamic>> userGroups = [];
  bool isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    final GroupService groupService = GroupService();
    final groups = await groupService.getUserGroups();

    if (!mounted) return;
    setState(() {
      userGroups = groups;
      isLoadingGroups = false;
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "My Groups",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF17202B),
                        ),
                      ),

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
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    "Manage your shared expenses and members.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5A6472),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create group button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await AppRouter.toCreateGroup(context);
                        if (result == true) {
                          setState(() { isLoadingGroups = true; });
                          loadGroups();
                        }
                      },
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text(
                        "Create New Group",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17202B), // Dark Navy
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Group list
                Expanded(
                  child: isLoadingGroups
                      ? const Center(
                    child: LoadingDots(
                      color: Color(0xFFFF6452),
                      size: 8,
                      spacing: 8,
                    ),
                  )
                      : userGroups.isEmpty
                      ? const Center(
                    child: Text(
                      "No groups yet. Click above to create one!",
                      style: TextStyle(
                        color: Color(0xFF5A6472),
                        fontSize: 14,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    itemCount: userGroups.length,
                    itemBuilder: (context, index) {
                      final group = userGroups[index];
                      final groupName = group['name'] as String? ?? 'Group';
                      final iconChar = groupName.isNotEmpty
                          ? groupName[0].toUpperCase()
                          : '?';
                      final iconColor = (index % 2 == 0)
                          ? const Color(0xFF2F9E8F)
                          : const Color(0xFFFF6452);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          // Navigate to details screen.
                          // If it returns true, it means the group was deleted, so we refresh!
                          final result = await AppRouter.toGroupDetails(context, group);
                          if (result == true) {
                            setState(() { isLoadingGroups = true; });
                            loadGroups();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EEE5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE4E0D5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    iconChar,
                                    style: const TextStyle(
                                      fontSize: 20,
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
                                      groupName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF17202B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "No expenses yet",
                                      style: TextStyle(
                                        fontSize: 13,
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
                    },
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
      ),
    );
  }
}