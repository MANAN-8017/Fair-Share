import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseService {
  final SupabaseClient supabase = Supabase.instance.client;

  ExpenseService._internal();
  static final ExpenseService _instance = ExpenseService._internal();

  factory ExpenseService() {
    return _instance;
  }

  Future<String?> addExpense({
    required String groupId,
    required String description,
    required double amount,
    required String category,
    required String paidBy,
    required String splitType, // 'equal' | 'unequal' | 'percent'
    required Map<String, double> splits,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return "You must be logged in to add an expense.";
      }

      final expenseResponse = await supabase
          .from('expenses')
          .insert({
        'group_id': groupId,
        'description': description,
        'amount': amount,
        'category': category,
        'paid_by': paidBy,
        'split_type': splitType,
        'created_by': user.id,
      })
          .select()
          .single();

      final expenseId = expenseResponse['id'];

      final splitRows = splits.entries
          .map((entry) => {
        'expense_id': expenseId,
        'user_id': entry.key,
        'amount': entry.value,
        'percentage': splitType == 'percent'
            ? (entry.value / amount) * 100
            : null,
      })
          .toList();

      await supabase.from('expense_splits').insert(splitRows);

      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getGroupExpenses(String groupId) async {
    try {
      final response = await supabase
          .from('expenses')
          .select('*, users!expenses_paid_by_fkey(id, name), expense_splits(id, user_id, amount, percentage, is_settled, settled_at)')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching expenses: $error");
      return [];
    }
  }

  List<Map<String, dynamic>> computeBalances({
  required List<Map<String, dynamic>> expenses,
  required List<Map<String, dynamic>> members,
  required String currentUserId,
  }) {
  final nameById = <String, String>{};
  for (final member in members) {
    final user = member['users'] as Map<String, dynamic>;
    nameById[user['id']] = user['name'] ?? 'Unknown';
  }


  final netByUser = <String, double>{};
  final splitIdsByUser = <String, List<String>>{};


  for (final expense in expenses) {
    final paidBy = expense['paid_by'] as String?;
    final splits = List<Map<String, dynamic>>.from(expense['expense_splits'] ?? []);
    if (paidBy == null) continue;


    for (final split in splits) {
      if (split['is_settled'] == true) continue;


      final splitUser = split['user_id'] as String?;
      final amount = (split['amount'] as num?)?.toDouble() ?? 0;
      final splitId = split['id'] as String?;
      if (splitUser == null || splitId == null) continue;
      if (splitUser == paidBy) continue; // own share, not a debt


      String? other;
      if (paidBy == currentUserId) {
        // splitUser owes currentUser
        other = splitUser;
        netByUser[other] = (netByUser[other] ?? 0) + amount;
      } else if (splitUser == currentUserId) {
        // currentUser owes paidBy
        other = paidBy;
        netByUser[other] = (netByUser[other] ?? 0) - amount;
      }


      if (other != null) {
        final ids = splitIdsByUser[other] ?? [];
        ids.add(splitId);
        splitIdsByUser[other] = ids;
      }
    }
  }


  final balances = <Map<String, dynamic>>[];
  netByUser.forEach((userId, net) {
    if (net.abs() < 0.005) return;
    balances.add({
      'user_id': userId,
      'name': nameById[userId] ?? 'Unknown',
      'net_amount': net,
      'split_ids': splitIdsByUser[userId] ?? [],
    });
  });


  balances.sort((a, b) => (b['net_amount'] as double).abs().compareTo((a['net_amount'] as double).abs()));
  return balances;
  }

  List<Map<String, dynamic>> computeGroupNetBalances({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> members,
  }) {
    final net = <String, double>{};
    final nameById = <String, String>{};

    // Initialize every group member with 0 balance
    for (final member in members) {
      final user = member['users'];

      if (user == null) continue;

      final userId = user['id'] as String;
      final name = user['name'] as String? ?? 'Unknown';

      net[userId] = 0.0;
      nameById[userId] = name;
    }

    // Calculate the complete group's net balance
    for (final expense in expenses) {
      final paidBy = expense['paid_by'] as String?;

      if (paidBy == null) continue;

      final expenseAmount =
          (expense['amount'] as num?)?.toDouble() ?? 0.0;

      // Person who paid gets credit
      net[paidBy] = (net[paidBy] ?? 0.0) + expenseAmount;

      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );

      // People who owe their share get debited
      for (final split in splits) {
        if (split['is_settled'] == true) continue;

        final userId = split['user_id'] as String?;

        if (userId == null) continue;

        final amount =
            (split['amount'] as num?)?.toDouble() ?? 0.0;

        net[userId] = (net[userId] ?? 0.0) - amount;
      }
    }

    return net.entries
        .where((entry) => entry.value.abs() >= 0.0005)
        .map((entry) {
      return {
        'userId': entry.key,
        'name': nameById[entry.key] ?? 'Unknown',
        'net_amount': entry.value,
      };
    })
        .toList();
  }

  Future<double> calculateUserBalanceInGroup(String groupId, String userId) async {
    final expenses = await getGroupExpenses(groupId);
    double netBalance = 0.0;

    for (var expense in expenses) {
      final paidBy = expense['paid_by'];
      if (paidBy == null) continue;

      final splits = List<Map<String, dynamic>>.from(expense['expense_splits'] ?? []);

      for (final split in splits) {
        if (split['is_settled'] == true) continue;

        final splitUserId = split['user_id'];
        final amount = (split['amount'] as num).toDouble();

        if (paidBy == userId && splitUserId != userId) {
          netBalance += amount;
        } else if (paidBy != userId && splitUserId == userId) {
          netBalance -= amount;
        }
      }
    }
    return netBalance;
  }

  Future<String> settleWithUser(List<String> splitIds) async {
    if (splitIds.isEmpty) return "True";
    try {
      await supabase.from('expense_splits').update({
        'is_settled': true,
        'settled_at': DateTime.now().toIso8601String(),
      }).inFilter('id', splitIds);

      return "True";
    } catch (error) {
      return error.toString();
    }
  }
}