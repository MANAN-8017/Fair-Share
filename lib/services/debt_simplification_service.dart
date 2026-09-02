import 'dart:math';
import 'package:fair_share/services/expense_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_service.dart';

class Debt {
  final String from;
  final String to;
  final double netAmount;

  Debt({
    required this.from,
    required this.to,
    required this.netAmount,
  });
}

class DebtSimplificationService {
  final SupabaseClient supabase = Supabase.instance.client;
  DebtSimplificationService._internal();

  static final DebtSimplificationService _instance = DebtSimplificationService._internal();

  factory DebtSimplificationService(){
    return _instance;
  }
  
  final GroupService groupService = GroupService();
  final ExpenseService expenseService = ExpenseService();

  Future<List<Debt>> simplify(String id) async {
    try {
      final transactions = <Debt>[];
        final members = await groupService.getGroupMembers(id.toString());
        final expenses = await expenseService.getGroupExpenses(id.toString());

        final users = expenseService.computeGroupNetBalances(expenses: expenses, members: members);

        final creditors = users.where((credit) => credit['netAmount'] > 0).toList();
        final debtors = users.where((debit) => debit['netAmount'] < 0).toList();

        creditors.sort((a, b) => b['netAmount'].compareTo(a['netAmount']));
        debtors.sort((a, b) => a['netAmount'].compareTo(b['netAmount']));

        int creditorIndex = 0;
        int debtorIndex = 0;

        while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
          final creditor = creditors[creditorIndex];
          final debtor = debtors[debtorIndex];

          final amount = min(creditor['netAmount'], debtor['netAmount'].abs());

          transactions.add(
            Debt(
              from: debtor['userId'],
              to: creditor['userId'],
              netAmount: amount.toDouble(),
            )
          );

          creditor['netAmount'] -= amount;
          debtor['netAmount'] += amount;

          if (creditor['netAmount'] < 0.01) {
            creditorIndex++;
          }

          if (debtor['netAmount'].abs() < 0.01) {
            debtorIndex++;
          }
        }
      return transactions;
    }
    catch (error) {
      print('Debt simplification error: $error');
      return [];
    }
  }
}