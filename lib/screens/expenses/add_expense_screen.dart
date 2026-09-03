import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

const List<String> _categories = ['Food', 'Travel', 'Rent', 'Utility'];

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> members;

  const AddExpenseScreen({
    super.key,
    required this.group,
    required this.members,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;
  final ExpenseService _expenseService = ExpenseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Food';
  late String paidById;
  String splitType = 'equal'; // 'equal' | 'unequal' | 'percent'
  bool isSaving = false;

  // memberId -> controller, used for unequal / percent split entry
  final Map<String, TextEditingController> _splitControllers = {};

  @override
  void initState() {
    super.initState();
    paidById = currentUserId;
    for (final m in widget.members) {
      final userRecord = m['users'] as Map<String, dynamic>;
      _splitControllers[userRecord['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    for (final c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _amount => double.tryParse(amountController.text.trim()) ?? 0;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, double> splits = {};

    if (splitType == 'equal') {
      final share = _amount / widget.members.length;
      for (final m in widget.members) {
        final userRecord = m['users'] as Map<String, dynamic>;
        splits[userRecord['id']] = share;
      }
    } else if (splitType == 'unequal') {
      double total = 0;
      for (final entry in _splitControllers.entries) {
        final value = double.tryParse(entry.value.text.trim()) ?? 0;
        splits[entry.key] = value;
        total += value;
      }
      if ((total - _amount).abs() > 0.01) {
        AppSnackBar.error(
          context,
          "Split amounts must add up to ₹${_amount.toStringAsFixed(2)} (currently ₹${total.toStringAsFixed(2)}).",
        );
        return;
      }
    } else {
      double totalPercent = 0;
      for (final entry in _splitControllers.entries) {
        final pct = double.tryParse(entry.value.text.trim()) ?? 0;
        totalPercent += pct;
        splits[entry.key] = _amount * (pct / 100);
      }
      if ((totalPercent - 100).abs() > 0.5) {
        AppSnackBar.error(
          context,
          "Percentages must add up to 100% (currently ${totalPercent.toStringAsFixed(1)}%).",
        );
        return;
      }
    }

    setState(() => isSaving = true);

    final result = await _expenseService.addExpense(
      groupId: widget.group['id'],
      description: descriptionController.text.trim(),
      amount: _amount,
      category: selectedCategory.toLowerCase(),
      paidBy: paidById,
      splitType: splitType,
      splits: splits,
    );

    if (!mounted) return;

    if (result == "True") {
      AppSnackBar.success(context, "Expense added!");
      Navigator.pop(context, true);
    } else {
      setState(() => isSaving = false);
      AppSnackBar.error(context, result ?? "Failed to add expense.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Amount
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) return "Enter a valid amount";
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "e.g. Dinner",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              (value == null || value.trim().isEmpty) ? "Enter a description" : null,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // Paid by
            DropdownButtonFormField<String>(
              initialValue: paidById,
              decoration: const InputDecoration(
                labelText: "Paid by",
                border: OutlineInputBorder(),
              ),
              items: widget.members.map((m) {
                final userRecord = m['users'] as Map<String, dynamic>;
                final memberId = userRecord['id'];
                final label = memberId == currentUserId ? "You" : userRecord['name'];
                return DropdownMenuItem(value: memberId as String, child: Text(label));
              }).toList(),
              onChanged: (value) => setState(() => paidById = value!),
            ),
            const SizedBox(height: 16),

            // Split type
            const Text("Split", style: TextStyle(fontWeight: FontWeight.w600)),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text("Equally"),
              value: 'equal',
              groupValue: splitType,
              onChanged: (value) => setState(() => splitType = value!),
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text("Unequally (₹ amounts)"),
              value: 'unequal',
              groupValue: splitType,
              onChanged: (value) => setState(() => splitType = value!),
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text("By percentage (%)"),
              value: 'percent',
              groupValue: splitType,
              onChanged: (value) => setState(() => splitType = value!),
            ),

            if (splitType == 'equal' && widget.members.isNotEmpty && _amount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  "₹${(_amount / widget.members.length).toStringAsFixed(2)} per person",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),

            if (splitType != 'equal') ...[
              const SizedBox(height: 8),
              ...widget.members.map((m) {
                final userRecord = m['users'] as Map<String, dynamic>;
                final memberId = userRecord['id'];
                final label = memberId == currentUserId ? "You" : userRecord['name'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: _splitControllers[memberId],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: label,
                      prefixText: splitType == 'percent' ? null : "₹ ",
                      suffixText: splitType == 'percent' ? "%" : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _handleSave,
                child: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text("Save Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}