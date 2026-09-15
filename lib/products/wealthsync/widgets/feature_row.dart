import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureRow extends StatefulWidget {
  const FeatureRow({super.key});

  @override
  State<FeatureRow> createState() => _FeatureRowState();
}

class _FeatureRowState extends State<FeatureRow> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow = constraints.maxWidth < 720;

        return SingleChildScrollView(
          scrollDirection: isNarrow ? Axis.vertical : Axis.horizontal,
          child: Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLiquidCard(
                context,
                index: 0,
                icon: Icons.dashboard_rounded,
                title: 'All-in-One Finance',
                description:
                    'Manage your accounts, debt, and spending from one clean dashboard.',
              ),
              SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 16 : 0),
              _buildLiquidCard(
                context,
                index: 1,
                icon: Icons.auto_awesome_rounded,
                title: 'Smart & Instant',
                description:
                    'Insights, updates, and automation that move as fast as you do.',
              ),
              SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 16 : 0),
              _buildLiquidCard(
                context,
                index: 2,
                icon: Icons.security,
                title: 'Secure & Private',
                description:
                    'Your wealth deserves protection — we keep it that way.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiquidCard(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hoveredIndex = index),
        onTapUp: (_) => setState(() => _hoveredIndex = -1),
        onTapCancel: () => setState(() => _hoveredIndex = -1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scaleByDouble(
              isHovered ? 1.03 : 1.0,
              isHovered ? 1.03 : 1.0,
              1.0,
              1.0,
            ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 220,
              maxWidth: 260,
              minHeight: 180,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: isHovered
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isHovered ? Colors.white : Colors.white70,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white54,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
