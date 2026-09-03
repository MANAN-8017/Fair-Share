import 'package:flutter/material.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> expense;
  final List<Map<String, dynamic>> members;
  final String currentUserId;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.members,
    required this.currentUserId,
  });

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

  String _nameForUserId(String userId) {
    if (userId == currentUserId) return "You";
    final match = members.firstWhere(
          (m) => (m['users'] as Map<String, dynamic>)['id'] == userId,
      orElse: () => {'users': {'name': 'Unknown'}},
    );
    return (match['users'] as Map<String, dynamic>)['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final splits = List<Map<String, dynamic>>.from(expense['expense_splits'] ?? []);
    final paidByUser = expense['users'] as Map<String, dynamic>?;
    final category = expense['category'] as String? ?? 'other';
    final color = _categoryColor[category] ?? const Color(0xFF9AA2AC);

    final totalAmount = (expense['amount'] as num).toDouble();
    final mySplit = splits.firstWhere(
          (s) => s['user_id'] == currentUserId,
      orElse: () => {},
    );
    final myShare = mySplit.isNotEmpty ? (mySplit['amount'] as num).toDouble() : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF17202B)),
        title: const Text(
          "Expense Details",
          style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(26)),
                  child: Center(
                    child: Text(_categoryEmoji[category] ?? '💸', style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense['description'] ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF17202B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Paid by ${paidByUser?['name'] ?? 'someone'}",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF9AA2AC)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "₹${(expense['amount'] as num).toStringAsFixed(2)}",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: color),
            ),

            const SizedBox(height: 16),

            // Net balance banner — what YOU owe or are owed for this expense

            const SizedBox(height: 24),

            const Text(
              "SPLIT BETWEEN",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
            ),
            const SizedBox(height: 12),

            ...splits.map((split) {
              final userId = split['user_id'] as String;
              final splitAmount = (split['amount'] as num).toDouble();
              final percentage = split['percentage'];

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
                      radius: 18,
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        _nameForUserId(userId).substring(0, 1).toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _nameForUserId(userId),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    if (percentage != null)
                      Text(
                        "${(percentage as num).toStringAsFixed(0)}%  ",
                        style: const TextStyle(color: Color(0xFF9AA2AC), fontSize: 13),
                      ),
                    Text(
                      "₹${splitAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF17202B)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}