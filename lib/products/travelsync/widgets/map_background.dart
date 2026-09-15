import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../ts_colors.dart';

/// Subtle travel-map backdrop echoing the card back — faint grid, compass
/// roses, dashed flight-path arcs and location nodes. Drawn in low-opacity
/// blue so it adds texture without competing with content.
class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawArcs(canvas, size);
    // Compass roses anchored to opposite corners.
    _drawCompass(canvas, Offset(size.width * 0.82, size.height * 0.18), 150);
    _drawCompass(canvas, Offset(size.width * 0.14, size.height * 0.82), 120);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.6;
    const step = 46.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawArcs(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fractional node positions — endpoints of "routes".
    final nodes = <Offset>[
      Offset(w * 0.12, h * 0.30),
      Offset(w * 0.46, h * 0.16),
      Offset(w * 0.80, h * 0.40),
      Offset(w * 0.30, h * 0.66),
      Offset(w * 0.66, h * 0.78),
      Offset(w * 0.90, h * 0.70),
    ];

    final line = Paint()
      ..color = primaryBlue.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Connect a few node pairs with gently curved, dashed arcs.
    const links = [
      [0, 1],
      [1, 2],
      [0, 3],
      [3, 4],
      [2, 5],
      [4, 5],
    ];
    for (final link in links) {
      final a = nodes[link[0]];
      final b = nodes[link[1]];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      // Bow the arc perpendicular to the segment.
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = len == 0 ? 0.0 : -dy / len;
      final ny = len == 0 ? 0.0 : dx / len;
      final bow = len * 0.18;
      final ctrl = Offset(mid.dx + nx * bow, mid.dy + ny * bow);

      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);
      _drawDashed(canvas, path, line);
    }

    // Location nodes — a filled dot with a ring.
    final ring = Paint()
      ..color = primaryBlue.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final dot = Paint()
      ..color = primaryBlue.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    for (final n in nodes) {
      canvas.drawCircle(n, 2.5, dot);
      canvas.drawCircle(n, 7, ring);
    }
  }

  void _drawCompass(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryBlue.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final r in [radius * 0.25, radius * 0.5, radius * 0.75, radius]) {
      canvas.drawCircle(center, r, paint);
    }

    paint.strokeWidth = 0.8;
    canvas.drawLine(
      Offset(center.dx - radius * 1.1, center.dy),
      Offset(center.dx + radius * 1.1, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 1.1),
      Offset(center.dx, center.dy + radius * 1.1),
      paint,
    );

    paint.strokeWidth = 0.6;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * radius * 0.86,
          center.dy + math.sin(angle) * radius * 0.86,
        ),
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        paint,
      );
    }
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dash = 7,
    double gap = 6,
  }) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final len = math.min(dash, metric.length - dist);
        canvas.drawPath(metric.extractPath(dist, dist + len), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapBackgroundPainter oldDelegate) => false;
}
