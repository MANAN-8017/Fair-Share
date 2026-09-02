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
    List<Map<String, dynamic>> result = [];
    final nameById = <String,String>{};

    for(final member in members){
      final user = member['users'];
      final id  = user['id'];

      nameById[id] = user['name'];
    }
    final splitByIds = <String, List<String>>{};
    final net = <String,double>{};

    for(var expense in expenses){
      final paidBy = expense['paid_by'];
      if(paidBy == null) continue;
      final splits = List<Map<String, dynamic>>.from(
        expense['expense_splits'] ?? [],
      );

      for(final split in splits){
        if(split['is_settled'] == true) continue;

        final splitUser = split['user_id'];
        final id = split['id'];
        final a = (split['amount'] as num?)?.toDouble() ?? 0.0;

        String? otherUser;

        if (paidBy == currentUserId) {
          otherUser = splitUser;
          net[splitUser] = (net[splitUser] ?? 0.0) + a;
        } else if (splitUser == currentUserId) {
          otherUser = paidBy;
          net[paidBy] = (net[paidBy] ?? 0.0) - a;
        }

        if (otherUser != null) {
          final ids = splitByIds[otherUser] ?? [];
          ids.add(id);
          splitByIds[otherUser] = ids;
        }
      }
    }
    for(final entry in net.entries){
      final userid = entry.key;
      final a = entry.value;

      if(a < 0.0005) continue;

      result.add({
        'user_id': userid,
        'name': nameById[userid] ?? 'Unknown',
        'net_amount': a,
        'split_ids': splitByIds[userid] ?? [],
      });
    }
    return result;
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