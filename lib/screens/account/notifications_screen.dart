import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AccountService accountService = AccountService();

  bool isLoading = true;
  Map<String, bool> settings = {
    'expense_added': true,
    'payment_due': true,
    'group_activity': true,
    'email_notifications': false,
  };

  final Map<String, String> _labels = {
    'expense_added': "New expense added",
    'payment_due': "Payment due reminders",
    'group_activity': "Group activity",
    'email_notifications': "Email notifications",
  };

  final Map<String, String> _subtitles = {
    'expense_added': "When someone adds an expense in your group",
    'payment_due': "Reminders for settlements you owe",
    'group_activity': "New members, group changes and updates",
    'email_notifications': "Get a copy of alerts sent to your email",
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await accountService.getNotificationSettings();

    if (!mounted) return;
    setState(() {
      if (loaded != null) settings = loaded;
      isLoading = false;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => settings[key] = value);
    final result = await accountService.updateNotificationSetting(key: key, value: value);

    if (!mounted) return;
    if (result != "True") {
      setState(() => settings[key] = !value);
      AppSnackBar.error(context, result ?? "Couldn't update that setting.");
    }
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
                    "Notifications",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                itemCount: settings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final key = settings.keys.elementAt(index);
                  final value = settings[key]!;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE4E0D5)),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: const Color(0xFF2F9E8F),
                      title: Text(
                        _labels[key] ?? key,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                      ),
                      subtitle: Text(
                        _subtitles[key] ?? "",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9AA2AC)),
                      ),
                      value: value,
                      onChanged: (v) => _toggle(key, v),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}