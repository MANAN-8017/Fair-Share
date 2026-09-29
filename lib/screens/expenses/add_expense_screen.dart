import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

const List<String> _categories = ['Food', 'Travel', 'Rent', 'Utility', 'Other'];

const Map<String, String> _categoryEmoji = {
  'Food': '🍜',
  'Travel': '🚗',
  'Rent': '🏠',
  'Utility': '💡',
  'Other': '💸',
};

const Map<String, Color> _categoryColor = {
  'Food': Color(0xFF2F9E8F),
  'Travel': Color(0xFFFF6452),
  'Rent': Color(0xFFC98A2C),
  'Utility': Color(0xFF6C63A6),
  'Other': Color(0xFF5A6472),
};

const Color _bg = Color(0xFFFAF8F3);
const Color _cardColor = Color(0xFFF1EEE5);
const Color _border = Color(0xFFE4E0D5);
const Color _ink = Color(0xFF17202B);
const Color _muted = Color(0xFF5A6472);
const Color _hint = Color(0xFF9AA2AC);
const Color _teal = Color(0xFF2F9E8F);
const Color _coral = Color(0xFFFF6452);

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

  final Map<String, TextEditingController> _splitControllers = {};
  final Set<String> _equalMembers = {}; // members included in the equal split

  @override
  void initState() {
    super.initState();
    paidById = currentUserId;
    for (final m in widget.members) {
      final userRecord = m['users'] as Map<String, dynamic>;
      _splitControllers[userRecord['id']] = TextEditingController();
      _equalMembers.add(userRecord['id']);
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

  double get _splitTotal => _splitControllers.values
      .fold(0.0, (sum, c) => sum + (double.tryParse(c.text.trim()) ?? 0));

  // ---------------- Save ----------------

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, double> splits = {};

    if (splitType == 'equal') {
      if (_equalMembers.isEmpty) {
        AppSnackBar.error(context, "Select at least one member to split with.");
        return;
      }
      final share = _amount / _equalMembers.length;
      for (final id in _equalMembers) {
        splits[id] = share;
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

  // ---------------- UI helpers ----------------

  InputDecoration _decoration(String label, {String? prefix, String? suffix, String? hint}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      labelText: label.isEmpty ? null : label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      hintStyle: const TextStyle(color: _hint, fontSize: 14),
      filled: true,
      fillColor: _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(_border),
      enabledBorder: border(_border),
      focusedBorder: border(_teal),
      errorBorder: border(_coral),
      focusedErrorBorder: border(_coral),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: _muted),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _categoryChip(String c) {
    final selected = selectedCategory == c;
    final color = _categoryColor[c]!;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_categoryEmoji[c]!, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 6),
            Text(
              c,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _splitSegment(String value, String label) {
    final selected = splitType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => splitType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _ink : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _muted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberRow(Map<String, dynamic> m) {
    final userRecord = m['users'] as Map<String, dynamic>;
    final id = userRecord['id'] as String;
    final isMe = id == currentUserId;
    final name = isMe ? "You" : (userRecord['name'] ?? 'Unknown').toString();
    final isEqual = splitType == 'equal';
    final included = _equalMembers.contains(id);

    Widget trailing;
    if (isEqual) {
      trailing = Text(
        included && _equalMembers.isNotEmpty
            ? "₹${(_amount / _equalMembers.length).toStringAsFixed(2)}"
            : "—",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: included ? _ink : _hint,
        ),
      );
    } else {
      trailing = SizedBox(
        width: 120,
        child: TextFormField(
          controller: _splitControllers[id],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: _decoration(
            "",
            hint: "0",
            prefix: splitType == 'percent' ? null : "₹ ",
            suffix: splitType == 'percent' ? "%" : null,
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isEqual
            ? () => setState(() {
                  included ? _equalMembers.remove(id) : _equalMembers.add(id);
                })
            : null,
        child: Opacity(
          opacity: isEqual && !included ? 0.5 : 1,
          child: Row(
            children: [
              if (isEqual)
                Checkbox(
                  value: included,
                  activeColor: _teal,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (v) => setState(() {
                    v == true ? _equalMembers.add(id) : _equalMembers.remove(id);
                  }),
                ),
              isMe
                  ? CurrentUserAvatar(name: userRecord['name']?.toString() ?? "", size: 36)
                  : UserAvatar(
                      imageUrl: userRecord['avatar_url'] as String?,
                      name: (userRecord['name'] ?? '').toString(),
                      size: 36,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _ink),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _splitTotalIndicator() {
    final isPercent = splitType == 'percent';
    final total = _splitTotal;
    final matched = isPercent ? (total - 100).abs() <= 0.5 : (total - _amount).abs() <= 0.01;
    final text = isPercent
        ? "Total: ${total.toStringAsFixed(1)}% of 100%"
        : "Total: ₹${total.toStringAsFixed(2)} of ₹${_amount.toStringAsFixed(2)}";
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: matched ? _teal : _coral,
        ),
      ),
    );
  }

  Widget _equalSelectionHeader() {
  final allSelected = _equalMembers.length == widget.members.length;
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "Splitting between ${_equalMembers.length} of ${widget.members.length}",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            if (allSelected) {
              _equalMembers.clear();
            } else {
              for (final m in widget.members) {
                _equalMembers.add((m['users'] as Map<String, dynamic>)['id']);
              }
            }
          }),
          child: Text(
            allSelected ? "Clear all" : "Select all",
            style: const TextStyle(color: _teal, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

  // ---------------- Build ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 22, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _ink),
                  ),
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- Details ----
                      _sectionLabel("DETAILS"),
                      const SizedBox(height: 10),
                      _sectionCard(
                        children: [
                          TextFormField(
                            controller: amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700, color: _ink),
                            decoration: _decoration("Amount", prefix: "₹ "),
                            validator: (value) {
                              final amount = double.tryParse(value?.trim() ?? '');
                              if (amount == null || amount <= 0) return "Enter a valid amount";
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionController,
                            decoration: _decoration("Description", hint: "e.g. Dinner"),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? "Enter a description"
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---- Category ----
                      _sectionLabel("CATEGORY"),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map(_categoryChip).toList(),
                      ),

                      const SizedBox(height: 24),

                      // ---- Paid by ----
                      _sectionLabel("PAID BY"),
                      const SizedBox(height: 10),
                      _sectionCard(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: paidById,
                            dropdownColor: _bg,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
                            decoration: _decoration("Who paid?"),
                            items: widget.members.map((m) {
                              final userRecord = m['users'] as Map<String, dynamic>;
                              final memberId = userRecord['id'] as String;
                              final label = memberId == currentUserId
                                  ? "You"
                                  : (userRecord['name'] ?? 'Unknown').toString();
                              return DropdownMenuItem(
                                value: memberId,
                                child: Text(label, style: const TextStyle(color: _ink)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => paidById = value!),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---- Split ----
                      _sectionLabel("SPLIT"),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            _splitSegment('equal', "Equally"),
                            _splitSegment('unequal', "Amounts"),
                            _splitSegment('percent', "Percent"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionCard(
                        children: [
                          if (splitType == 'equal') _equalSelectionHeader(),
                          ...widget.members.map(_memberRow),
                          if (splitType != 'equal') _splitTotalIndicator(),
                        ],
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ink,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _ink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const LoadingDots(color: Colors.white, size: 6, spacing: 6)
                              : const Text(
                                  "Save Expense",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}