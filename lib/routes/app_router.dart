import 'package:flutter/material.dart';

import '../screens/auth/auth.dart';
import '../screens/expenses/settle_up_screen.dart';
import '../screens/groups/group_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/groups/group_details_screen.dart';
import '../services/navigation_service.dart';
import '../screens/layout.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/expense_details_screen.dart';
import '../screens/groups/group_members_screen.dart';

class AppRouter {

  static Future<void> toLoading(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.navigateAfterDelay(
      context,
      const LoadingScreen(),
      delay,
    );
  }

  static Future<void> toAuthOption(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.clearAndNavigate(
      context,
      const AuthOptionScreen(),
      delay: delay,
    );
  }

  static Future<void> toLogin(BuildContext context, {
    int delay = 0,
    String? successMessage,
  }) {
    return NavigationService.replace(
      context,
      LoginScreen(
        successMessage: successMessage,
      ),
      delay: delay,
    );
  }

  static Future<void> toRegister(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.replace(
      context,
      const RegisterScreen(),
      delay: delay,
    );
  }

  static Future<void> toLayout(BuildContext context, {int delay = 0,}) {
    return NavigationService.clearAndNavigate(
        context, const Layout(), delay: delay);
  }

  static Future<void> toHome(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.clearAndNavigate(
      context,
      const Layout(),
      delay: delay,
    );
  }

  static Future<dynamic> toGroups(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.push(
      context,
      const GroupScreen(),
    );
  }

  static Future<dynamic> toCreateGroup(BuildContext context, {
    int delay = 0,
  }) {
    return NavigationService.push(
      context,
      const CreateGroupScreen(),
    );
  }

  static Future<dynamic> toGroupDetails(BuildContext context,
      Map<String, dynamic> group) {
    return NavigationService.push(
      context,
      GroupDetailsScreen(group: group),
    );
  }

  static Future<dynamic> toGroupMembers(
      BuildContext context, {
        required Map<String, dynamic> group,
        required String currentUserId,
      }) {
    return NavigationService.push(
      context,
      GroupMembersScreen(
        group: group,
        currentUserId: currentUserId,
      ),
    );
  }

  static Future<dynamic> toAddExpense(BuildContext context, {
    required Map<String, dynamic> group,
    required List<Map<String, dynamic>> members,
  }) {
    return NavigationService.push(
      context,
      AddExpenseScreen(group: group, members: members),
    );
  }

  static Future<dynamic> toExpenseDetails(BuildContext context, {
    required Map<String, dynamic> expense,
    required List<Map<String, dynamic>> members,
    required String currentUserId,
  }) {
    return NavigationService.push(
      context,
      ExpenseDetailsScreen(
          expense: expense, members: members, currentUserId: currentUserId),
    );
  }

  static Future<dynamic> toSettleUp(BuildContext context, {
    required Map<String, dynamic> group,
    required List<Map<String, dynamic>> members,
  }) {
    return NavigationService.push(
      context,
      SettleUpScreen(group: group, members: members),
    );
  }
}