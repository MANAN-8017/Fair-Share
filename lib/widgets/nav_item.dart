import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavItem(
      this.icon,
      this.label,
      this.selected,
      this.onTap, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected
                ? const Color(0xFFE3492F)
                : const Color(0xFF9AA2AC),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFE3492F)
                  : const Color(0xFF9AA2AC),
            ),
          ),
        ],
      ),
    );
  }
}