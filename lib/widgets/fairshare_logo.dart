import 'package:flutter/material.dart';

class FairShareLogo extends StatelessWidget {
  final double size;

  const FairShareLogo({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.08,
            top: size * 0.32,
            child: Container(
              width: size * 0.70,
              height: size * 0.40,
              decoration: const BoxDecoration(
                color: Color(0xFF2F9E8F),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.32,
            top: size * 0.32,
            child: Container(
              width: size * 0.70,
              height: size * 0.40,
              decoration: const BoxDecoration(
                color: Color(0xE0FF6452),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}