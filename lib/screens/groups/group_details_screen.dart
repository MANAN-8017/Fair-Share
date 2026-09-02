import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';
import '../../routes/routes.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupService _groupService = GroupService();
  final ExpenseService _expenseService = ExpenseService();
  final DebtSimplificationService _debtSimplificationService = DebtSimplificationService();

  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  List<Map<String, dynamic>> members = [];
  bool isLoading = true;

  List<Map<String, dynamic>> expenses = [];
  bool isLoadingExpenses = true;

  bool _balanceExpanded = true;

  late bool _isSimplifyOn;
  bool _isSimplifying = false;

  List<Map<String, dynamic>> get balances =>
      _expenseService.computeBalances(
        expenses: expenses,
        members: members,
        currentUserId: currentUserId,
      );

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

  bool get isCreator => currentUserId == widget.group['created_by'];

  List<Debt> transactions = [];

  @override
  void initState() {
    super.initState();
    _isSimplifyOn = widget.group['isSimplify'] ?? false;
    _loadMembers();
    _loadExpenses();
    if (_isSimplifyOn) {
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    setState(() {
      _isSimplifying = true;
    });

    try {
      final result = await _debtSimplificationService.simplify(
        widget.group['id'].toString(),
      );

      if (!mounted) return;

      setState(() {
        transactions = result;
        _isSimplifying = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSimplifying = false;
      });

      print('Failed to load simplified debts: $e');
    }
  }

  String _getMemberName(String userId) {
    final member = members.firstWhere(
          (member) => member['id'] == userId,
      orElse: () => {},
    );

    return member['name'] ?? 'someone';
  }

  Future<void> _toggleSimplify(bool value) async {
    if (_isSimplifying) return;

    setState(() {
      _isSimplifying = true;
    });

    try {
      List<Debt> result = [];

      if (value) {
        result = await _debtSimplificationService.simplify(
          widget.group['id'].toString(),
        );
      }

      await Supabase.instance.client
          .from('groups')
          .update({
        'isSimplify': value,
      })
          .eq('id', widget.group['id']);

      if (!mounted) return;
      setState(() {
        _isSimplifyOn = value;
        transactions = value ? result : [];
        widget.group['isSimplify'] = value;
        _isSimplifying = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSimplifying = false;
      });

      print('Failed to update simplify setting: $e');

      AppSnackBar.error(
        context,
        "Failed to update simplify setting.",
      );
    }
  }

  Widget _buildBalanceSummary() {
    final currentBalances = balances;

    if (currentBalances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE4E0D5),
            ),
          ),
          child: const Text(
            "You're all settled up in this group",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A6472),
            ),
          ),
        ),
      );
    }

    // NORMAL BALANCE
    final currentUserBalance = currentBalances.firstWhere(
          (b) => b['userId'] == currentUserId,
      orElse: () => {'netAmount': 0.0},
    );

    final overall =
        (currentUserBalance['netAmount'] as num?)?.toDouble() ?? 0.0;

    // SIMPLIFIED BALANCE
    double simplifiedOverall = 0.0;

    for (final debt in transactions) {
      if (debt.from == currentUserId) {
        // You have to pay this amount
        simplifiedOverall -= debt.netAmount;
      } else if (debt.to == currentUserId) {
        // You receive this amount
        simplifiedOverall += debt.netAmount;
      }
    }

    // SELECT WHICH BALANCE TO DISPLAY
    final displayedBalance =
    _isSimplifyOn ? simplifiedOverall : overall;

    final displayedOwed = displayedBalance >= 0;

    final headlineColor = displayedOwed
        ? const Color(0xFF1B5C53)
        : const Color(0xFFE3492F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE4E0D5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            InkWell(
              onTap: () {
                setState(() {
                  _balanceExpanded = !_balanceExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF17202B),
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: displayedOwed
                                ? "You are owed "
                                : "You owe ",
                          ),

                          TextSpan(
                            text:
                            "₹${displayedBalance.abs().toStringAsFixed(2)}",
                            style: TextStyle(
                              color: headlineColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const TextSpan(
                            text: " overall",
                          ),
                        ],
                      ),
                    ),
                  ),

                  Icon(
                    _balanceExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9AA2AC),
                  ),
                ],
              ),
            ),

            // EXPANDED BALANCES
            if (_balanceExpanded) ...[
              const SizedBox(height: 10),

              if (_isSimplifyOn)
              // SIMPLIFIED TRANSACTIONS
                if (transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      "You're all settled up.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A6472),
                      ),
                    ),
                  )
                else
                  ...transactions.map((debt) {

                    final isCurrentUserDebtor =
                        debt.from == currentUserId;

                    final isCurrentUserCreditor =
                        debt.to == currentUserId;

                    // Only show transactions involving current user.
                    if (!isCurrentUserDebtor &&
                        !isCurrentUserCreditor) {
                      return const SizedBox.shrink();
                    }

                    final amount = debt.netAmount;

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            color: const Color(0xFFE4E0D5),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              isCurrentUserDebtor
                                  ? "You owe ${_getMemberName(debt.to)}"
                                  : "${_getMemberName(debt.from)} owes you",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5A6472),
                              ),
                            ),
                          ),

                          Text(
                            "\$${amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCurrentUserDebtor
                                  ? const Color(0xFFFF6452)
                                  : const Color(0xFF2F9E8F),
                            ),
                          ),
                        ],
                      ),
                    );
                  })

              else
              // ORIGINAL BALANCES
                ...currentBalances.map((b) {
                  final netAmount = (b['netAmount'] as num?)?.toDouble() ?? 0.0;

                  final theyOweYou = netAmount > 0;

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          color: const Color(0xFFE4E0D5),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            theyOweYou
                                ? "${b['name']} owes you"
                                : "You owe ${b['name']}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5A6472),
                            ),
                          ),
                        ),

                        Text(
                          "₹${netAmount.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theyOweYou
                                ? const Color(0xFF2F9E8F)
                                : const Color(0xFFFF6452),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadMembers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final fetchedMembers =
      await _groupService.getGroupMembers(
        widget.group['id'],
      );

      if (!mounted) return;

      setState(() {
        members = fetchedMembers;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      AppSnackBar.error(
        context,
        "Failed to load members",
      );
    }
  }

  Future<void> _loadExpenses() async {
    if (mounted) {
      setState(() {
        isLoadingExpenses = true;
      });
    }

    try {
      final fetchedExpenses =
      await _expenseService.getGroupExpenses(
        widget.group['id'],
      );

      if (!mounted) return;

      setState(() {
        expenses = fetchedExpenses;
        isLoadingExpenses = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingExpenses = false;
      });

      AppSnackBar.error(
        context,
        "Failed to load expenses",
      );
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text("Delete Group"),
        content: const Text(
          "Are you sure? This will permanently delete the group and all associated expenses. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6452),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result =
      await _groupService.deleteGroup(
        widget.group['id'],
      );

      if (!mounted) return;

      if (result == "True") {
        Navigator.pop(context, true);
      } else {
        AppSnackBar.error(
          context,
          result ?? "Failed to delete group",
        );
      }
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.error(
        context,
        "Failed to delete group",
      );
    }
  }

  Future<void> _goToAddExpense() async {
    if (members.isEmpty) {
      AppSnackBar.error(
        context,
        "Add at least one member before creating an expense.",
      );
      return;
    }

    final result = await AppRouter.toAddExpense(
      context,
      group: widget.group,
      members: members,
    );

    if (result == true) {
      await _loadExpenses();
    }
  }

  void _goToExpenseDetails(
      Map<String, dynamic> expense,
      ) {
    AppRouter.toExpenseDetails(
      context,
      expense: expense,
      members: members,
      currentUserId: currentUserId,
    );
  }

  Future<void> _goToMembersScreen() async {
    final result =
    await AppRouter.toGroupMembers(
      context,
      group: widget.group,
      currentUserId: currentUserId,
    );

    if (result == true) {
      await _loadMembers();
      await _loadExpenses();
    }
  }

  Future<void> _goToSettleUp() async {
    final result = await AppRouter.toSettleUp(
      context,
      group: widget.group,
      members: members,
    );

    if (result == true) {
      await _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      floatingActionButton: isLoading
          ? null
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'settle_up_fab',
            onPressed: _goToSettleUp,
            backgroundColor:
            const Color(0xFF5277FF),
            foregroundColor: Colors.white,
            label: const Text(
              "Settle Up",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_expense_fab',
            onPressed: _goToAddExpense,
            backgroundColor:
            const Color(0xFFFF6452),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              "Add Expense",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF17202B),
        ),
        title: Text(
          widget.group['name'] ?? 'Group Details',
          style: const TextStyle(
            color: Color(0xFF17202B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF6452),
              ),
              tooltip: "Delete Group",
              onPressed: _deleteGroup,
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: LoadingDots(
          color: Color(0xFFFF6452),
          size: 8,
          spacing: 8,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            if (widget.group['description'] != null &&
                widget.group['description']
                    .toString()
                    .isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 4,
                ),
                child: Text(
                  widget.group['description'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5A6472),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (!isLoadingExpenses)
              _buildBalanceSummary(),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goToMembersScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF17202B).withOpacity(0.3),
                        ),
                      ),
                      // View members button
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Color(0xFF17202B),
                          ),
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

                  // Simplify debts toggle
                  if (isCreator)
                    Row(
                      children: [
                        const Text(
                          "Simplify Debts",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A6472),
                          ),
                        ),

                        const SizedBox(width: 8),

                        if (_isSimplifying)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: LoadingDots(
                              color: Color(0xFF2F9E8F),
                              size: 5,
                              spacing: 4,
                            ),
                          ),

                        Switch(
                          value: _isSimplifyOn,
                          onChanged: _isSimplifying
                              ? null
                              : _toggleSimplify,
                          activeColor: const Color(0xFF2F9E8F),
                          inactiveThumbColor: const Color(0xFF9AA2AC),
                          inactiveTrackColor: const Color(0xFFE4E0D5),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACTIVITY",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Color(0xFF5A6472),
                    ),
                  ),
                  const SizedBox(height: 10),

                  isLoadingExpenses
                      ? const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    child: Center(
                      child: LoadingDots(
                        color:
                        Color(0xFFFF6452),
                        size: 6,
                        spacing: 6,
                      ),
                    ),
                  )
                      : expenses.isEmpty
                      ? const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      "No expenses yet.",
                      style: TextStyle(
                        color:
                        Color(0xFF9AA2AC),
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount:
                    expenses.length,
                    itemBuilder:
                        (context, index) {
                      final expense =
                      expenses[index];

                      final category =
                          expense['category']
                          as String? ??
                              'other';

                      final paidByUser =
                      expense['users']
                      as Map<String,
                          dynamic>?;

                      final amount =
                      (expense['amount']
                      as num)
                          .toDouble();

                      return ActivityRow(
                        icon:
                        _categoryEmoji[
                        category] ??
                            '💸',
                        iconColor:
                        _categoryColor[
                        category] ??
                            const Color(
                              0xFF9AA2AC,
                            ),
                        title:
                        expense['description'] ??
                            '',
                        subtitle:
                        "Paid by ${paidByUser?['name'] ?? 'someone'}",
                        amount:
                        "₹${amount.toStringAsFixed(2)}",
                        onTap: () =>
                            _goToExpenseDetails(
                              expense,
                            ),
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