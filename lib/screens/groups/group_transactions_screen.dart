import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

/// Shows every debt in the group — between ANY two members, not just the
/// current user — exactly the way the group's "Simplify Debts" setting has
/// it configured (simplified minimal transfers vs. raw per-pair balances).
class GroupTransactionsScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> members;
  final String currentUserId;
  final bool isSimplifyOn;

  const GroupTransactionsScreen({
    super.key,
    required this.group,
    required this.members,
    required this.currentUserId,
    required this.isSimplifyOn,
  });

  @override
  State<GroupTransactionsScreen> createState() => _GroupTransactionsScreenState();
}

class _GroupTransactionsScreenState extends State<GroupTransactionsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final DebtSimplificationService _debtSimplificationService = DebtSimplificationService();

  bool isLoading = true;

  // Each item: {debtor_id, creditor_id, debtor_name, creditor_name, amount}
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);

    try {
      final expenses = await _expenseService.getGroupExpenses(widget.group['id']);

      List<Map<String, dynamic>> result;

      if (widget.isSimplifyOn) {
        final debts = await _debtSimplificationService.simplify(
          widget.group['id'].toString(),
          members: widget.members,
          expenses: expenses,
          onlyCurrentUser: false,
        );

        result = debts
            .map(
              (d) => {
            'debtor_id': d.debtorId,
            'creditor_id': d.creditorId,
            'debtor_name': _getMemberName(d.debtorId),
            'creditor_name': _getMemberName(d.creditorId),
            'amount': d.amount,
          },
        )
            .toList();
      } else {
        result = _expenseService.computeAllPairwiseBalances(
          expenses: expenses,
          members: widget.members,
        );
      }

      if (!mounted) return;
      setState(() {
        _transactions = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AppSnackBar.error(context, "Failed to load transactions");
    }
  }

  String _getMemberName(String userId) {
    for (final member in widget.members) {
      final user = member['users'];
      if (user != null && user['id'].toString() == userId) {
        return user['name']?.toString() ?? 'someone';
      }
    }
    return 'someone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF17202B)),
        title: const Text(
          "Transactions",
          style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
            child: Text(
              widget.isSimplifyOn
                  ? "Simplified — showing the minimum transfers needed to settle up."
                  : "Showing every outstanding balance between members.",
              style: const TextStyle(fontSize: 13, color: Color(0xFF5A6472)),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
              child: Text(
                "Everyone is settled up.",
                style: TextStyle(color: Color(0xFF9AA2AC), fontWeight: FontWeight.w600),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final debtorId = tx['debtor_id'] as String;
                final creditorId = tx['creditor_id'] as String;
                final amount = (tx['amount'] as num).toDouble();

                final debtorIsMe = debtorId == widget.currentUserId;
                final creditorIsMe = creditorId == widget.currentUserId;

                final debtorLabel = debtorIsMe ? "You" : tx['debtor_name'];
                final creditorLabel = creditorIsMe ? "you" : tx['creditor_name'];

                final Color amountColor = creditorIsMe
                    ? const Color(0xFF2F9E8F)
                    : debtorIsMe
                    ? const Color(0xFFFF6452)
                    : const Color(0xFF17202B);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E0D5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 14, color: Color(0xFF17202B)),
                            children: [
                              TextSpan(
                                text: debtorLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: " owes "),
                              TextSpan(
                                text: creditorLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "₹${amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}