import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupService _groupService = GroupService();
  final ExpenseService _expenseService = ExpenseService();

  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  List<Map<String, dynamic>> expenses = [];
  bool isLoadingExpenses = true;

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
    _loadMembers();
    _loadExpenses();
  }

  bool get isCreator => currentUserId == widget.group['created_by'];

  Future<void> _loadMembers() async {
    setState(() => isLoading = true);
    final fetchedMembers = await _groupService.getGroupMembers(widget.group['id']);
    if (!mounted) return;
    setState(() {
      members = fetchedMembers;
      isLoading = false;
    });
  }

  Future<void> _loadExpenses() async {
    setState(() => isLoadingExpenses = true);
    final fetchedExpenses = await _expenseService.getGroupExpenses(widget.group['id']);
    if (!mounted) return;
    setState(() {
      expenses = fetchedExpenses;
      isLoadingExpenses = false;
    });
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text("Delete Group"),
        content: const Text("Are you sure? This will permanently delete the group and all associated expenses. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6452)),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _groupService.deleteGroup(widget.group['id']);
    if (!mounted) return;

    if (result == "True") {
      Navigator.pop(context, true);
    } else {
      AppSnackBar.error(context, result ?? "Failed to delete group");
    }
  }

  Future<void> _goToAddExpense() async {
    if (members.isEmpty) {
      AppSnackBar.error(context, "Add at least one member before creating an expense.");
      return;
    }

    final result = await AppRouter.toAddExpense(
      context,
      group: widget.group,
      members: members,
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  void _goToExpenseDetails(Map<String, dynamic> expense) {
    AppRouter.toExpenseDetails(
      context,
      expense: expense,
      members: members,
      currentUserId: currentUserId,
    );
  }

  Future<void> _goToMembersScreen() async {
    final result = await AppRouter.toGroupMembers(
      context,
      group: widget.group,
      currentUserId: currentUserId,
    );

    if (result == true) {
      _loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton.extended(
        onPressed: _goToAddExpense,
        backgroundColor: const Color(0xFFFF6452),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF17202B)),
        title: Text(
          widget.group['name'] ?? 'Group Details',
          style: const TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6452)),
              tooltip: "Delete Group",
              onPressed: _deleteGroup,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Description
            if (widget.group['description'] != null && widget.group['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                child: Text(
                  widget.group['description'],
                  style: const TextStyle(fontSize: 15, color: Color(0xFF5A6472)),
                ),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  // The Members Button
                  GestureDetector(
                    onTap: _goToMembersScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF17202B).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: Color(0xFF17202B)),
                          const SizedBox(width: 6),
                          Text(
                            "${members.length} people",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF17202B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            // Activity / Expenses section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACTIVITY",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
                  ),
                  const SizedBox(height: 10),

                  isLoadingExpenses
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: LoadingDots(color: Color(0xFFFF6452), size: 6, spacing: 6)),
                  )
                      : expenses.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("No expenses yet.", style: TextStyle(color: Color(0xFF9AA2AC))),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final category = expense['category'] as String? ?? 'other';
                      final paidByUser = expense['users'] as Map<String, dynamic>?;

                      return ActivityRow(
                        icon: _categoryEmoji[category] ?? '💸',
                        iconColor: _categoryColor[category] ?? const Color(0xFF9AA2AC),
                        title: expense['description'] ?? '',
                        subtitle: "Paid by ${paidByUser?['name'] ?? 'someone'}",
                        amount: "\$${(expense['amount'] as num).toStringAsFixed(2)}",
                        onTap: () => _goToExpenseDetails(expense),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}