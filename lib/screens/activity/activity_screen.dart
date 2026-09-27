import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final GroupService _groupService = GroupService();

  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;
  bool isNavigating = false;

  static const Map<String, String> _categoryEmoji = {
    'food': '🍜',
    'travel': '🚗',
    'rent': '🏠',
    'utility': '💡',
  };

  static const Map<String, Color> _categoryColor = {
    'food': Color(0xFF2F9E8F),
    'travel': Color(0xFFFF6452),
    'rent': Color(0xFFC98A2C),
    'utility': Color(0xFF6C63A6),
  };

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    final fetchedActivities = await _expenseService.getRecentActivity();

    if (!mounted) return;

    setState(() {
      activities = fetchedActivities;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 24, 22, 10),
            child: Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: Color(0xFF17202B),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
                : activities.isEmpty
                ? const Center(
              child: Text(
                "No recent activity.",
                style: TextStyle(color: Color(0xFF9AA2AC), fontSize: 15),
              ),
            )
                : Stack(
              children: [
                RefreshIndicator(
                  color: const Color(0xFFFF6452),
                  onRefresh: _loadActivity,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final expense = activities[index];

                      final category = expense['category'] as String? ?? 'other';
                      final description = expense['description'] ?? 'Expense';
                      final amount = (expense['amount'] as num).toDouble();

                      final groupData = expense['groups'] as Map<String, dynamic>?;
                      final groupName = groupData?['name'] ?? 'Unknown Group';

                      final userData = expense['users'] as Map<String, dynamic>?;
                      final paidByName = userData?['name'] ?? 'Someone';

                      return ActivityRow(
                        icon: _categoryEmoji[category] ?? '💸',
                        iconColor: _categoryColor[category] ?? const Color(0xFF9AA2AC),
                        title: description,
                        subtitle: "Paid by $paidByName • $groupName",
                        amount: "₹${amount.toStringAsFixed(2)}",
                        onTap: () async {
                          if (isNavigating) return;
                          setState(() => isNavigating = true);

                          try {
                            final currentUserId = Supabase.instance.client.auth.currentUser!.id;

                            final members = await _groupService.getGroupMembers(expense['group_id']);

                            if (!context.mounted) return;

                            AppRouter.toExpenseDetails(
                              context,
                              expense: expense,
                              members: members,
                              currentUserId: currentUserId,
                            );
                          } finally {
                            if (mounted) {
                              setState(() => isNavigating = false);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
                if (isNavigating)
                  const Positioned.fill(
                    child: Center(
                      child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}