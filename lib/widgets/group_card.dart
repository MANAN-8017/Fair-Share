import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String icon;
  final String groupName;
  final String amount;
  final Color iconColor;

  const GroupCard({
    super.key,
    required this.icon,
    required this.groupName,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E0D5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(9),
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

          const SizedBox(height: 9),

          Text(
            groupName,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17202B),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF9AA2AC),
            ),
          ),
        ],
      ),
    );
  }
}