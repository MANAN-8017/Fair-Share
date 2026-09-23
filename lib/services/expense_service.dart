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
          .map(
            (entry) => {
              'expense_id': expenseId,
              'user_id': entry.key,
              'amount': entry.value,
              'percentage': splitType == 'percent'
                  ? (entry.value / amount) * 100
                  : null,
            },
          )
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

  List<Map<String, dynamic>> computeBalances({required List<Map<String, dynamic>> expenses, required List<Map<String, dynamic>> members, required String currentUserId}) {
    final nameById = <String, String>{};
    for (final member in members) {
      final user = member['users'] as Map<String, dynamic>;
      nameById[user['id']] = user['name'] ?? 'Unknown';
    }

    final netByUser = <String, double>{};
    final splitIdsByUser = <String, List<String>>{};

    for (final expense in expenses) {
      final paidBy = expense['paid_by'] as String?;
      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );
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

    balances.sort(
      (a, b) => (b['net_amount'] as double).abs().compareTo(
        (a['net_amount'] as double).abs(),
      ),
    );
    return balances;
  }

  List<Map<String, dynamic>> computeGroupNetBalances({required List<Map<String, dynamic>> expenses, required List<Map<String, dynamic>> members}) {
    final net = <String, double>{};
    final nameById = <String, String>{};

    for (final member in members) {
      final user = member['users'];
      if (user == null) continue;
      final userId = user['id'] as String;
      net[userId] = 0.0;
      nameById[userId] = user['name'] as String? ?? 'Unknown';
    }

    for (final expense in expenses) {
      final paidBy = expense['paid_by'] as String?;
      if (paidBy == null) continue;

      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );
      for (final split in splits) {
        if (split['is_settled'] == true)
          continue; // skip fully — no credit, no debit
        final userId = split['user_id'] as String?;
        if (userId == null) continue;
        final amount = (split['amount'] as num?)?.toDouble() ?? 0.0;

        net[paidBy] = (net[paidBy] ?? 0.0) + amount;
        net[userId] = (net[userId] ?? 0.0) - amount;
      }
    }

    return net.entries
        .where((e) => e.value.abs() >= 0.0005)
        .map(
          (e) => {
            'userId': e.key,
            'name': nameById[e.key] ?? 'Unknown',
            'net_amount': e.value,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> computeAllPairwiseBalances({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> members,
  }) {
    final nameById = <String, String>{};
    for (final member in members) {
      final user = member['users'] as Map<String, dynamic>?;
      if (user == null) continue;
      nameById[user['id'].toString()] = user['name']?.toString() ?? 'Unknown';
    }

    // key = "smallerId|largerId" (alphabetically sorted so each pair has one
    // slot). Positive value => first id owes second id. Negative => reverse.
    final Map<String, double> net = {};

    for (final expense in expenses) {
      final paidBy = expense['paid_by'] as String?;
      if (paidBy == null) continue;

      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );

      for (final split in splits) {
        if (split['is_settled'] == true) continue;

        final splitUser = split['user_id'] as String?;
        final amount = (split['amount'] as num?)?.toDouble() ?? 0.0;
        if (splitUser == null || splitUser == paidBy || amount == 0) continue;

        // splitUser owes paidBy `amount`
        final ids = [splitUser, paidBy]..sort();
        final key = "${ids[0]}|${ids[1]}";
        final sign = splitUser == ids[0] ? 1.0 : -1.0;

        net[key] = (net[key] ?? 0) + sign * amount;
      }
    }

    final result = <Map<String, dynamic>>[];
    net.forEach((key, value) {
      if (value.abs() < 0.005) return;

      final parts = key.split('|');
      final String debtorId = value > 0 ? parts[0] : parts[1];
      final String creditorId = value > 0 ? parts[1] : parts[0];

      result.add({
        'debtor_id': debtorId,
        'creditor_id': creditorId,
        'debtor_name': nameById[debtorId] ?? 'Unknown',
        'creditor_name': nameById[creditorId] ?? 'Unknown',
        'amount': value.abs(),
      });
    });

    result.sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );
    return result;
  }
  Future<double> calculateUserBalanceInGroup(String groupId, String userId) async {
    final expenses = await getGroupExpenses(groupId);
    double netBalance = 0.0;

    for (var expense in expenses) {
      final paidBy = expense['paid_by'];
      if (paidBy == null) continue;

      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );

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
      await supabase
          .from('expense_splits')
          .update({
            'is_settled': true,
            'settled_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', splitIds);

      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final groupResponse = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', user.id);

      final groupIds = List<String>.from(groupResponse.map((g) => g['group_id'].toString()));

      if (groupIds.isEmpty) return [];

      final response = await supabase
          .from('expenses')
          .select('*, users!expenses_paid_by_fkey(id, name), groups(name), expense_splits(id, user_id, amount, percentage, is_settled, settled_at)')
          .inFilter('group_id', groupIds)
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching recent activity: $error");
      return [];
    }
  }
}