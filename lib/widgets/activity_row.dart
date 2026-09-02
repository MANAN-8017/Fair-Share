import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivityRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color iconColor;
  final VoidCallback? onTap;

  const ActivityRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE4E0D5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF17202B),
                    ),
                  ),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA2AC),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              amount,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}