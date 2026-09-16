import 'dart:math';
import 'package:fair_share/services/expense_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_service.dart';

class Debt {
  final String from;
  final String to;
  final double net_amount;
  Debt({required this.from, required this.to, required this.net_amount});
}

class DebtSimplificationService {
  final SupabaseClient supabase = Supabase.instance.client;
  DebtSimplificationService._internal();
  static final DebtSimplificationService _instance = DebtSimplificationService._internal();
  factory DebtSimplificationService() {
    return _instance;
  }
  final GroupService groupService = GroupService();
  final ExpenseService expenseService = ExpenseService();

  Future<List<Debt>> simplify(String id) async {
    try {
      final transactions = <Debt>[];
      final members = await groupService.getGroupMembers(id);
      final expenses = await expenseService.getGroupExpenses(id);
      final users = expenseService.computeGroupNetBalances(expenses: expenses, members: members);

      final creditors = users.map((user) => {...user, 'net_amount': (user['net_amount'] as num?)?.toDouble() ?? 0.0})
          .where((user) => user['net_amount'] > 0.0)
          .toList();

      final debtors = users.map((user) => {...user, 'net_amount': (user['net_amount'] as num?)?.toDouble() ?? 0.0})
          .where((user) => user['net_amount'] < -0.0)
          .toList();

      creditors.sort((a, b) => (b['net_amount'] as double).compareTo(a['net_amount'] as double));
      debtors.sort((a, b) => (a['net_amount'] as double).compareTo(b['net_amount'] as double));

      int creditorIndex = 0;
      int debtorIndex = 0;

      while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
        final creditor = creditors[creditorIndex];
        final debtor = debtors[debtorIndex];
        final creditorAmount = (creditor['net_amount'] as num?)?.toDouble() ?? 0.0;
        final debtorAmount = (debtor['net_amount'] as num?)?.toDouble() ?? 0.0;
        final amount = min(creditorAmount, debtorAmount.abs());

        if (amount < 0.0) {
          break;
        }

        transactions.add(Debt(from: debtor['userId'] as String, to: creditor['userId'] as String, net_amount: amount));
        creditor['net_amount'] = creditorAmount - amount;
        debtor['net_amount'] = debtorAmount + amount;

        final remainingCredit = (creditor['net_amount'] as num?)?.toDouble() ?? 0.0;
        final remainingDebt = (debtor['net_amount'] as num?)?.toDouble() ?? 0.0;
        const epsilon = 0.01; // or whatever precision you're working with

        if (remainingCredit.abs() < epsilon) {
          creditorIndex++;
        }
        if (remainingDebt.abs() < epsilon) {
          debtorIndex++;
        }
      }
      return transactions;
    } catch (error) {
      print('Debt simplification error: $error');
      return [];
    }
  }
}