import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final AccountService accountService = AccountService();

  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _upiController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final details = await accountService.getPaymentDetails();

    if (!mounted) return;
    setState(() {
      _upiController.text = details?['upi_id'] ?? "";
      _bankNameController.text = details?['bank_name'] ?? "";
      _accountNumberController.text = details?['account_number'] ?? "";
      _ifscController.text = details?['ifsc_code'] ?? "";
      isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
      errorText = null;
    });

    final result = await accountService.updatePaymentDetails(
      upiId: _upiController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscController.text.trim(),
    );

    if (!mounted) return;

    if (result == "True") {
      Navigator.pop(context, true);
    } else {
      setState(() {
        isSaving = false;
        errorText = result ?? "Something went wrong. Please try again.";
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
                    "Payment Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: Text(
                "Used so group members know where to settle up with you.",
                style: TextStyle(fontSize: 13, color: Color(0xFF5A6472)),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _upiController,
                        decoration: _decoration("UPI ID"),
                        validator: (value) => ValidationService.validate(
                          value ?? "",
                          type: ValidationType.required,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "BANK DETAILS (OPTIONAL)",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: Color(0xFF5A6472)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _bankNameController,
                        decoration: _decoration("Bank Name"),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _decoration("Account Number"),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ifscController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _decoration("IFSC Code"),
                      ),

                      if (errorText != null) ...[
                        const SizedBox(height: 14),
                        Text(errorText!, style: const TextStyle(color: Color(0xFFFF6452), fontSize: 13)),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17202B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: isSaving
                              ? const LoadingDots(color: Colors.white, size: 6, spacing: 6)
                              : const Text("Save Details", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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