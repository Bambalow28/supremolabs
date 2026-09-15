import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1A2D), // Top-left shadow blue
            Color(0xFF121827), // Slightly lighter intermediate
            Color(0xFF1D1D1D), // Center (matches background)
            Color(0xFF26123C), // Dark intermediate purple
            Color(0xFF2E0F4C), // Bottom-right shadow purple
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: child,
    );
  }
}
