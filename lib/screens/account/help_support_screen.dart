import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final AccountService accountService = AccountService();

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool isSubmitting = false;
  String? errorText;

  static const List<Map<String, String>> _faqs = [
    {
      "q": "How do I settle up with someone?",
      "a": "Open the group, tap on the balance with that person, and mark it as settled once the payment is made.",
    },
    {
      "q": "Can I edit an expense after adding it?",
      "a": "Tap the expense from Recent Activity or the group's expense list to edit or delete it.",
    },
    {
      "q": "How are splits calculated?",
      "a": "You can split equally, unequally, or by percentage — choose this when adding an expense.",
    },
    {
      "q": "Is my payment info shared with everyone?",
      "a": "Only group members you settle up with can see the UPI or bank details you've added.",
    },
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
      errorText = null;
    });

    final result = await accountService.submitSupportRequest(
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (!mounted) return;

    if (result == "True") {
      _subjectController.clear();
      _messageController.clear();
      setState(() => isSubmitting = false);
      AppSnackBar.success(context, "Your message has been sent.");
    } else {
      setState(() {
        isSubmitting = false;
        errorText = result ?? "Couldn't send your message. Please try again.";
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF5A6472), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1EEE5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E0D5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E0D5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F9E8F)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF17202B)),
                  ),
                  const Text(
                    "Help & Support",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "FREQUENTLY ASKED",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ..._faqs.map(
                          (faq) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEE5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4E0D5)),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            title: Text(
                              faq["q"]!,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                            ),
                            iconColor: const Color(0xFF5A6472),
                            collapsedIconColor: const Color(0xFF5A6472),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  faq["a"]!,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF5A6472), height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "CONTACT US",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _subjectController,
                            decoration: _decoration("Subject"),
                            validator: (value) => ValidationService.validate(
                              value ?? "",
                              type: ValidationType.required,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _messageController,
                            maxLines: 5,
                            decoration: _decoration("How can we help?"),
                            validator: (value) => ValidationService.validate(
                              value ?? "",
                              type: ValidationType.required,
                            ),
                          ),

                          if (errorText != null) ...[
                            const SizedBox(height: 14),
                            Text(errorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                          ],

                          const SizedBox(height: 20),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF17202B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const LoadingDots(color: Colors.white, size: 6, spacing: 6)
                                  : const Text("Send Message", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}