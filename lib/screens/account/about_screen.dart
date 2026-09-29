import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/services.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final AccountService accountService = AccountService();

  String version = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final fetchedVersion = await accountService.getAppVersion();

    if (!mounted) return;
    setState(() => version = fetchedVersion);
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                    "About FairShare",
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
                    const SizedBox(height: 20),

                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFF17202B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "FS",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF7FE0CC)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Center(
                      child: Text(
                        "FairShare",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                        version.isNotEmpty ? "Version $version" : " ",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9AA2AC)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "FairShare helps you split expenses, track group balances, and settle up with friends and family — without the awkward math.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF5A6472), height: 1.5),
                    ),

                    const SizedBox(height: 30),

                    _LegalRow(
                      title: "Privacy Policy",
                      onTap: () => _openLink("https://example.com/privacy"),
                    ),
                    const SizedBox(height: 12),
                    _LegalRow(
                      title: "Terms of Service",
                      onTap: () => _openLink("https://example.com/terms"),
                    ),
                    const SizedBox(height: 12),
                    _LegalRow(
                      title: "Open Source Licenses",
                      onTap: () => showLicensePage(context: context, applicationName: "FairShare"),
                    ),

                    const SizedBox(height: 30),

                    const Center(
                      child: Text(
                        "Made with care.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF9AA2AC)),
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

class _LegalRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EEE5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E0D5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF17202B)),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA2AC)),
          ],
        ),
      ),
    );
  }
}