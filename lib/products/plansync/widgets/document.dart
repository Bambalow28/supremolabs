import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ps_colors.dart';

/// Mono field label — every real travel document sets its fields this way:
/// a small tracked caps label over the value it names.
Widget psFieldLabel(String text) => Text(
  text.toUpperCase(),
  style: GoogleFonts.anonymousPro(
    fontSize: 9.5,
    fontWeight: FontWeight.bold,
    color: PSColors.accent,
    letterSpacing: 1.8,
  ),
);

Widget psValue(String text, {double size = 17, Color? color}) => Text(
  text,
  style: GoogleFonts.anonymousPro(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color ?? PSColors.ink,
    height: 1.2,
  ),
);

/// Label above value, the pair every document field is made of.
class PSField extends StatelessWidget {
  final String label;
  final String value;
  final double valueSize;
  final CrossAxisAlignment align;

  const PSField({
    super.key,
    required this.label,
    required this.value,
    this.valueSize = 17,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        psFieldLabel(label),
        const SizedBox(height: 6),
        psValue(value, size: valueSize),
      ],
    );
  }
}

/// One sheet in the folder. Flat stock, teal hairline, punched down the left,
/// set a fraction off square so the stack reads as paper rather than as a
/// grid of cards. [entrance] drives the one authored moment on the page: the
/// sheets settle into the folder once, in order.
class PSDocument extends StatelessWidget {
  final Widget child;

  /// Degrees off square. Kept under 1° — enough to read as handled paper.
  final double tilt;

  /// 0 → not yet settled, 1 → resting. Owned by the page.
  final Animation<double> entrance;

  final EdgeInsets padding;
  final Color color;
  final bool punched;

  const PSDocument({
    super.key,
    required this.child,
    required this.entrance,
    this.tilt = 0,
    this.padding = const EdgeInsets.fromLTRB(44, 32, 32, 32),
    this.color = PSColors.stock,
    this.punched = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, sheet) {
        final t = entrance.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 26),
            child: Transform.rotate(
              angle: tilt * math.pi / 180 * t,
              child: sheet,
            ),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: PSColors.hairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(padding: padding, child: child),
            if (punched)
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 30,
                child: CustomPaint(painter: _PunchHoles()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filing punches down the binding edge.
class _PunchHoles extends CustomPainter {
  const _PunchHoles();

  @override
  void paint(Canvas canvas, Size size) {
    final hole = Paint()..color = PSColors.ground;
    final rim = Paint()
      ..color = PSColors.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const spacing = 46.0;
    final count = math.max(2, (size.height - 40) ~/ spacing);
    final start = (size.height - (count - 1) * spacing) / 2;
    for (var i = 0; i < count; i++) {
      final c = Offset(15, start + i * spacing);
      canvas.drawCircle(c, 4.5, hole);
      canvas.drawCircle(c, 4.5, rim);
    }
  }

  @override
  bool shouldRepaint(_PunchHoles oldDelegate) => false;
}

/// The tear line across a boarding pass or off the end of a receipt.
class PSPerforation extends StatelessWidget {
  final Axis axis;
  const PSPerforation({super.key, this.axis = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PerforationPainter(axis),
      size: axis == Axis.horizontal
          ? const Size(double.infinity, 1)
          : const Size(1, double.infinity),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  final Axis axis;
  const _PerforationPainter(this.axis);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PSColors.accent.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 5.0;
    final length = axis == Axis.horizontal ? size.width : size.height;
    for (var d = 0.0; d < length; d += dash + gap) {
      final end = math.min(d + dash, length);
      canvas.drawLine(
        axis == Axis.horizontal ? Offset(d, 0.5) : Offset(0.5, d),
        axis == Axis.horizontal ? Offset(end, 0.5) : Offset(0.5, end),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) => false;
}

/// A rubber-stamped endorsement — the way a folder records that something
/// already happened. Used for the app's shipped, non-visual capabilities.
class PSStamp extends StatelessWidget {
  final String label;
  final double tilt;
  final Color color;

  const PSStamp({
    super.key,
    required this.label,
    this.tilt = -4,
    this.color = PSColors.accentAlt,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt * math.pi / 180,
      // Double rule, ink at stamp-pad strength, no icon and no fill on
      // hover — everything that separates a rubber stamp from a button.
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.anonymousPro(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.62),
              letterSpacing: 2.8,
            ),
          ),
        ),
      ),
    );
  }
}
