import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final Color color;
  final double size;
  final double spacing;

  const LoadingDots({
    super.key,
    this.color = Colors.white,
    this.size = 8,
    this.spacing = 8,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacity(int index) {
    double progress =
        (_controller.value - (index * 0.125)) % 1.0;

    if (progress < 0.4) {
      return 0.25 + (progress / 0.4) * 0.75;
    }

    return 1.0 - ((progress - 0.4) / 0.6) * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            SizedBox(width: widget.spacing),
            _dot(1),
            SizedBox(width: widget.spacing),
            _dot(2),
          ],
        );
      },
    );
  }

  Widget _dot(int index) {
    final opacity = _opacity(index);

    final scale =
        0.85 + (opacity - 0.25) / 0.75 * 0.15;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}