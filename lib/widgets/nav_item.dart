import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem(
      this.icon,
      this.label,
      this.active,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: active
              ? const Color(0xFFE3492F)
              : const Color(0xFF9AA2AC),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: active
                ? const Color(0xFFE3492F)
                : const Color(0xFF9AA2AC),
          ),
        ),
      ],
    );
  }
}