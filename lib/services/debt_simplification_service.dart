import 'dart:math';
import 'package:fair_share/services/expense_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_service.dart';

class Debt{
  String debtorId;
  String creditorId;
  double amount;
  Debt({required this.debtorId, required this.creditorId, required this.amount});
}

class DebtSimplificationService{
  final SupabaseClient supabase = Supabase.instance.client;
  DebtSimplificationService._internal();
  static final DebtSimplificationService _instance = DebtSimplificationService._internal();

  factory DebtSimplificationService(){ return _instance; }

  final GroupService groupService = GroupService();
  final ExpenseService expenseService = ExpenseService();

  Future<List<Debt>> simplify(String groupId, {List<Map<String, dynamic>>? members, List<Map<String, dynamic>>? expenses}) async {
    try{
      final resolvedMembers = members ?? await groupService.getGroupMembers(groupId);
      final resolvedExpenses = expenses ?? await expenseService.getGroupExpenses(groupId);

      final users = expenseService.computeGroupNetBalances(expenses: resolvedExpenses, members: resolvedMembers);
      final balances = <String, double>{};

      for (final user in users){
        final userId = user['userId'] as String;
        final netAmount = (user['net_amount'] as num?)?.toDouble() ?? 0.0;
        if (netAmount.abs() > 0.0) {
          balances[userId] = netAmount;
        }
      }
      final simplified = <Debt>[];

      while(true){
        String? debtorId, creditorId;
        double maxDebt = 0.0, maxCredit = 0.0;

        for (final entry in balances.entries){
          final userId = entry.key;
          final balance = entry.value;

          if (balance < 0 && balance.abs() > maxDebt) {
            maxDebt = balance.abs();
            debtorId = userId;
          }
        }

        for (final entry in balances.entries){
          final userId = entry.key;
          final balance = entry.value;

          if (balance > 0 && balance > maxCredit) {
            maxCredit = balance;
            creditorId = userId;
          }
        }

        if (debtorId == null || creditorId == null) {
          break;
        }

        final amount = min(maxDebt, maxCredit);

        simplified.add(Debt(debtorId: debtorId, creditorId: creditorId, amount: amount));

        balances[debtorId] = balances[debtorId]! + amount;
        balances[creditorId] = balances[creditorId]! - amount;
        balances.removeWhere((userId, balance) => balance.abs() < 0.0);
      }

      String currentUserId = supabase.auth.currentUser!.id;
      simplified.removeWhere((s) => s.debtorId.compareTo(currentUserId) != 0 && s.creditorId.compareTo(currentUserId) != 0);

      return simplified;
    } catch (error) {
      return [];
    }
  }
}