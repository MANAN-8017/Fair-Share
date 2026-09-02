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

  Future<void> _showAddMemberDialog() async {
    final TextEditingController emailController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFAF8F3),
                title: const Text("Add Member", style: TextStyle(color: Color(0xFF17202B))),
                content: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Enter user's email",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2F9E8F))),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF5A6472))),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                      if (emailController.text.trim().isEmpty) return;

                      setDialogState(() => isSubmitting = true);

                      final result = await _groupService.addMemberByEmail(
                        widget.group['id'],
                        emailController.text.trim(),
                      );

                      if (!mounted) return;
                      Navigator.pop(context);

                      if (result == "True") {
                        AppSnackBar.success(context, "Member added!");
                        _loadMembers();
                      } else {
                        AppSnackBar.error(context, result ?? "Failed to add member");
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9E8F)),
                    child: isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Future<void> _removeMember(String userId, String memberName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove $memberName from the group?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6452)),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _groupService.removeMember(widget.group['id'], userId);
    if (!mounted) return;

    if (result == "True") {
      AppSnackBar.success(context, "$memberName removed.");
      _loadMembers();
    } else {
      AppSnackBar.error(context, result ?? "Failed to remove member");
    }
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
            if (widget.group['description'] != null && widget.group['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                child: Text(
                  widget.group['description'],
                  style: const TextStyle(fontSize: 15, color: Color(0xFF5A6472)),
                ),
              ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "MEMBERS",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
                  ),
                  if (isCreator)
                    TextButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: const Icon(Icons.person_add, size: 18, color: Color(0xFF2F9E8F)),
                      label: const Text("Add", style: TextStyle(color: Color(0xFF2F9E8F), fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Members List
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final memberRecord = members[index];
                final userRecord = memberRecord['users'] as Map<String, dynamic>;
                final memberId = userRecord['id'];
                final isMe = memberId == currentUserId;
                final isMemberCreator = memberId == widget.group['created_by'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E0D5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF2F9E8F).withOpacity(0.2),
                        child: Text(
                          userRecord['name'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Color(0xFF1B5C53), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isMe ? "You" : userRecord['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                if (isMemberCreator)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6452).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Creator",
                                      style: TextStyle(fontSize: 10, color: Color(0xFFFF6452), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              userRecord['email'],
                              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA2AC)),
                            ),
                          ],
                        ),
                      ),
                      // Delete button (Only if current user is creator, and not deleting themselves)
                      if (isCreator && !isMe)
                        IconButton(
                          icon: const Icon(Icons.person_remove, color: Color(0xFF9AA2AC)),
                          onPressed: () => _removeMember(memberId, userRecord['name']),
                        )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 90), // leave room so the FAB doesn't cover the last row
          ],
        ),
      ),
    );
  }
}