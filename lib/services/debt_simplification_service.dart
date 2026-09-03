import 'dart:math';
import 'package:fair_share/services/expense_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'group_service.dart';

class Debt {
  final String from;
  final String to;
  final double netAmount;

  Debt({required this.from, required this.to, required this.netAmount});
}

class DebtSimplificationService {
  final SupabaseClient supabase = Supabase.instance.client;
  DebtSimplificationService._internal();

  static final DebtSimplificationService _instance =
      DebtSimplificationService._internal();

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

      final users = expenseService.computeGroupNetBalances(
        expenses: expenses,
        members: members,
      );

      final creditors = users
          .map(
            (user) => {
              ...user,
              'netAmount': (user['netAmount'] as num?)?.toDouble() ?? 0.0,
            },
          )
          .where((user) => user['netAmount'] > 0.0005)
          .toList();

      final debtors = users
          .map(
            (user) => {
              ...user,
              'netAmount': (user['netAmount'] as num?)?.toDouble() ?? 0.0,
            },
          )
          .where((user) => user['netAmount'] < -0.0005)
          .toList();

      creditors.sort(
        (a, b) =>
            (b['netAmount'] as double).compareTo(a['netAmount'] as double),
      );

      debtors.sort(
        (a, b) =>
            (a['netAmount'] as double).compareTo(b['netAmount'] as double),
      );

      int creditorIndex = 0;
      int debtorIndex = 0;

      while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
        final creditor = creditors[creditorIndex];
        final debtor = debtors[debtorIndex];

        final creditorAmount =
            (creditor['netAmount'] as num?)?.toDouble() ?? 0.0;

        final debtorAmount = (debtor['netAmount'] as num?)?.toDouble() ?? 0.0;

        final amount = min(creditorAmount, debtorAmount.abs());

        if (amount < 0.0005) {
          break;
        }

        transactions.add(
          Debt(
            from: debtor['userId'] as String,
            to: creditor['userId'] as String,
            netAmount: amount,
          ),
        );

        creditor['netAmount'] = creditorAmount - amount;

        debtor['netAmount'] = debtorAmount + amount;

        final remainingCredit =
            (creditor['netAmount'] as num?)?.toDouble() ?? 0.0;

        final remainingDebt = (debtor['netAmount'] as num?)?.toDouble() ?? 0.0;

        if (remainingCredit.abs() < 0.01) {
          creditorIndex++;
        }

        if (remainingDebt.abs() < 0.01) {
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