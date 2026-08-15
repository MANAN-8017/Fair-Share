import 'package:fair_share/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'auth_option.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    NavigationService.navigateAfterDelay(context, const AuthOptionScreen(), 3);
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF17202B),
              Color(0xFF0C1119),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Teal glow
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.45),
                  radius: 0.9,
                  colors: [
                    Color(0x242F9E8F),
                    Color(0x00101B19),
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Builder(
                    builder: (context) {
                      final logoSize =
                          MediaQuery.of(context).size.width * 0.25;

                      return SizedBox(
                        width: logoSize,
                        height: logoSize,
                        child: Stack(
                          children: [
                            Positioned(
                              left: logoSize * 0.08,
                              top: logoSize * 0.32,
                              child: Container(
                                width: logoSize * 0.70,
                                height: logoSize * 0.40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F9E8F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              left: logoSize * 0.32,
                              top: logoSize * 0.32,
                              child: Container(
                                width: logoSize * 0.70,
                                height: logoSize * 0.40,
                                decoration: const BoxDecoration(
                                  color: Color(0xE0FF6452),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // App name
                  Text(
                    "Fair Share",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.085,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF3F1E9),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    "SETTLING THE MATH…",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                      color: const Color(0x8CF3F1E9),
                      letterSpacing: 1.2,
                      fontFamily: "monospace",
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Three-dot loader
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDot(0),
                          const SizedBox(width: 8),
                          _buildDot(1),
                          const SizedBox(width: 8),
                          _buildDot(2),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    double progress =
        (_dotController.value - (index * 0.125)) % 1.0;

    double opacity;

    if (progress < 0.4) {
      opacity = 0.25 + (progress / 0.4) * 0.75;
    } else {
      opacity = 1.0 - ((progress - 0.4) / 0.6) * 0.75;
    }

    double scale = 0.85 + (opacity - 0.25) / 0.75 * 0.15;

    final double dotSize =
        MediaQuery.of(context).size.width * 0.025;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: const BoxDecoration(
            color: Color(0xFFFF6452),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}