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
          .select('*, users!expenses_paid_by_fkey(id, name), expense_splits(user_id, amount, percentage)')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching expenses: $error");
      return [];
    }
  }
}