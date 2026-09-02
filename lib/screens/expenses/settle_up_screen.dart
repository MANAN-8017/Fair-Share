import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class SettleUpScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> members;

  const SettleUpScreen({super.key, required this.group, required this.members});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  List<Map<String, dynamic>> _balances = [];
  bool isLoading = true;

  // Whether any settlement actually happened, so the previous screen
  // knows to refresh its expense list / totals.
  bool _didSettleAny = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final expenses = await _expenseService.getGroupExpenses(widget.group['id']);
    if (!mounted) return;
    setState(() {
      _balances = _expenseService.computeBalances(
        expenses: expenses,
        members: widget.members,
        currentUserId: currentUserId,
      );
      isLoading = false;
    });
  }

  Future<void> _confirmAndSettle(Map<String, dynamic> balance) async {
    final name = balance['name'] as String;
    final netAmount = balance['net_amount'] as double;
    final theyOweYou = netAmount > 0;
    final amount = netAmount.abs();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text("Settle Up"),
        content: Text(
          theyOweYou
              ? "Mark that $name paid you \$${amount.toStringAsFixed(2)}?"
              : "Mark that you paid $name \$${amount.toStringAsFixed(2)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF5A6472))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9E8F)),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final splitIds = List<String>.from(balance['split_ids'] ?? []);
    final result = await _expenseService.settleWithUser(splitIds);
    if (!mounted) return;

    if (result == "True") {
      _didSettleAny = true;
      AppSnackBar.success(context, "Settled up with $name!");
      setState(() {
        _balances.removeWhere((b) => b['user_id'] == balance['user_id']);
      });
    } else {
      AppSnackBar.error(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overall = _balances.fold<double>(0, (sum, b) => sum + (b['net_amount'] as double));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _didSettleAny);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8F3),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF17202B)),
          title: const Text(
            "Settle Up",
            style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _didSettleAny),
          ),
        ),
        body: isLoading
            ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
            : _balances.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "You're all settled up! 🎉",
              style: TextStyle(color: Color(0xFF5A6472), fontSize: 15),
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(22),
          itemCount: _balances.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final owed = overall >= 0;
              final color = owed ? const Color(0xFF1B5C53) : const Color(0xFFE3492F);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF5A6472)),
                    children: [
                      TextSpan(text: owed ? "You are owed " : "You owe "),
                      TextSpan(
                        text: "\$${overall.abs().toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 17),
                      ),
                      const TextSpan(text: " overall"),
                    ],
                  ),
                ),
              );
            }

            final balance = _balances[index - 1];
            final name = balance['name'] as String;
            final netAmount = balance['net_amount'] as double;
            final theyOweYou = netAmount > 0;
            final color = theyOweYou ? const Color(0xFF2F9E8F) : const Color(0xFFFF6452);

            return ActivityRow(
              icon: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
              iconColor: color,
              title: name,
              subtitle: theyOweYou ? "Owes you" : "You owe",
              amount: "\$${netAmount.abs().toStringAsFixed(2)}",
              onTap: () => _confirmAndSettle(balance),
            );
          },
        ),
      ),
    );
  }
}