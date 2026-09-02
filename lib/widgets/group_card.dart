import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String icon;
  final String groupName;
  final String amount;
  final Color iconColor;
  final Color amountColor;

  const GroupCard({
    super.key,
    required this.icon,
    required this.groupName,
    required this.amount,
    required this.iconColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const Spacer(),
          Text(
            groupName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF17202B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}