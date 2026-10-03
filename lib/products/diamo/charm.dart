import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dm_colors.dart';

/// The felt charms. Each diary entry type is one shape, so type reads from
/// silhouette and not only colour.
enum CharmKind { star, moon, cloud, leaf, sun }

extension CharmKindStyle on CharmKind {
  Color get color => switch (this) {
    CharmKind.star => DM.berry,
    CharmKind.moon => DM.butter,
    CharmKind.cloud => DM.lilac,
    CharmKind.leaf => DM.mint,
    CharmKind.sun => DM.sky,
  };

  double get _fatten => this == CharmKind.star ? 9 : 6;
}

// Paths are authored in a 100x100 box and cached; the painter scales them.
final Map<CharmKind, Path> _paths = {
  CharmKind.moon: Path()
    ..moveTo(58, 6)
    ..cubicTo(30, 10, 10, 32, 10, 58)
    ..cubicTo(10, 80, 24, 96, 44, 98)
    ..cubicTo(64, 100, 82, 90, 90, 74)
    ..cubicTo(64, 80, 38, 64, 38, 36)
    ..cubicTo(38, 24, 44, 14, 58, 6)
    ..close(),
  CharmKind.star: Path()
    ..addPolygon(const [
      Offset(50, 8),
      Offset(61, 38),
      Offset(92, 39),
      Offset(67, 58),
      Offset(76, 89),
      Offset(50, 71),
      Offset(24, 89),
      Offset(33, 58),
      Offset(8, 39),
      Offset(39, 38),
    ], true),
  CharmKind.cloud: Path()
    ..moveTo(28, 80)
    ..arcToPoint(const Offset(25, 40), radius: const Radius.circular(20))
    ..arcToPoint(const Offset(72, 31), radius: const Radius.circular(25))
    ..arcToPoint(const Offset(80, 80), radius: const Radius.circular(22))
    ..close(),
  CharmKind.leaf: Path()
    ..moveTo(16, 84)
    ..cubicTo(10, 42, 38, 14, 86, 14)
    ..cubicTo(90, 60, 64, 88, 16, 84)
    ..close(),
  CharmKind.sun: Path()
    ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 40)),
};

/// Y (in the 100-box, including the fattened edge) of the charm's top edge
/// at its horizontal centre: where a string must end to look attached.
double charmTopAt(CharmKind k) {
  final path = _paths[k]!;
  final half = k._fatten / 2;
  for (var y = 0.0; y < 100; y += 0.5) {
    if (path.contains(Offset(50, y + half))) {
      return y;
    }
  }
  return 0;
}

// Wool grain: a fixed scatter so every charm looks alike and the painter
// never re-rolls between frames.
final List<Offset> _grain = () {
  final r = math.Random(7);
  return List.generate(
    110,
    (_) => Offset(r.nextDouble() * 100, r.nextDouble() * 100),
  );
}();

Path _dashed(Path source, double dash, double gap) {
  final out = Path();
  for (final metric in source.computeMetrics()) {
    var d = 0.0;
    while (d < metric.length) {
      out.addPath(
        metric.extractPath(d, math.min(d + dash, metric.length)),
        Offset.zero,
      );
      d += dash + gap;
    }
  }
  return out;
}

class CharmPainter extends CustomPainter {
  final CharmKind kind;
  final Color color;
  const CharmPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 100;
    canvas.save();
    canvas.translate((size.width - 100 * k) / 2, (size.height - 100 * k) / 2);
    canvas.scale(k);
    final path = _paths[kind]!;

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = kind._fatten
        ..strokeJoin = StrokeJoin.round,
    );

    // Grain, clipped to the silhouette.
    canvas.save();
    canvas.clipPath(path);
    final dot = Paint();
    for (var i = 0; i < _grain.length; i++) {
      dot.color = (i.isEven ? Colors.black : Colors.white).withValues(
        alpha: 0.09,
      );
      canvas.drawCircle(_grain[i], 0.5 + (i % 3) * 0.3, dot);
    }
    canvas.restore();

    // Stitching: the silhouette shrunk toward its centre, dashed.
    final b = path.getBounds();
    final m = Matrix4.identity()
      ..translateByDouble(b.center.dx, b.center.dy, 0, 1)
      ..scaleByDouble(0.74, 0.74, 1, 1)
      ..translateByDouble(-b.center.dx, -b.center.dy, 0, 1);
    canvas.clipPath(path);
    canvas.drawPath(
      _dashed(path.transform(m.storage), 3, 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(CharmPainter old) =>
      old.kind != kind || old.color != color;
}

/// A single felt charm at [size].
class Charm extends StatelessWidget {
  final CharmKind kind;
  final double size;
  final Color? color;
  const Charm(this.kind, {super.key, this.size = 48, this.color});

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      size: Size.square(size),
      painter: CharmPainter(kind, color ?? kind.color),
    ),
  );
}

/// Hangs [child] from its top-centre and lets it sway slowly like a mobile.
/// Tapping kicks it into a damped swing. Stays still under Reduce Motion.
class Sway extends StatefulWidget {
  final Widget child;
  final Duration period;
  final double phase;
  final double degrees;
  final VoidCallback? onTap;
  const Sway({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 5400),
    this.phase = 0,
    this.degrees = 5,
    this.onTap,
  });

  @override
  State<Sway> createState() => _SwayState();
}

class _SwayState extends State<Sway> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: widget.period,
    value: widget.phase % 1,
  );
  late final AnimationController _kick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
    value: 1,
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _kick.dispose();
    super.dispose();
  }

  void _tap() {
    if (!_still) _kick.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _kick]),
        child: widget.child,
        builder: (context, child) {
          final idle = _still
              ? 0.0
              : Curves.easeInOut.transform(_idle.value) * 2 - 1;
          final t = _kick.value;
          final kick = math.pow(1 - t, 2) * math.sin(t * math.pi * 5) * 16;
          final deg = idle * widget.degrees + kick;
          return Transform.rotate(
            angle: deg * math.pi / 180,
            alignment: Alignment.topCenter,
            child: child,
          );
        },
      ),
    );
  }
}

/// String + charm: the unit that hangs from the mobile arm.
class HangingCharm extends StatelessWidget {
  final CharmKind kind;
  final double size;
  final double string;
  final String? label;
  final int index;
  final VoidCallback? onTap;
  const HangingCharm({
    super.key,
    required this.kind,
    required this.size,
    required this.string,
    this.label,
    this.index = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const periods = [5400, 6600, 4800, 7200, 5900];
    final still = MediaQuery.disableAnimationsOf(context);
    final body = SizedBox(
      width: math.max(size, 84),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 1.5, height: string, color: DM.brass),
          // Pull the charm up so the string ends inside its top edge, whatever
          // the silhouette (a leaf's top-centre is empty).
          Transform.translate(
            offset: Offset(0, -(charmTopAt(kind) * size / 100 + 1.5)),
            child: Charm(kind, size: size),
          ),
          if (label != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: DM.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: DM.border),
              ),
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DM.ink,
                  height: 1,
                ),
              ),
            ),
        ],
      ),
    );
    final swaying = Semantics(
      button: onTap != null,
      label: label,
      child: Sway(
        period: Duration(milliseconds: periods[index % periods.length]),
        phase: (index * 0.37) % 1,
        onTap: onTap,
        child: body,
      ),
    );
    // Drops in once, staggered, when first shown.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? 1 : 0, end: 1),
      duration: Duration(milliseconds: 750 + index * 120),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * -60),
          child: child,
        ),
      ),
      child: swaying,
    );
  }
}

/// Dashed vertical line: the memory "thread".
class DashedLinePainter extends CustomPainter {
  final Color color;
  const DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    for (var d = 0.0; d < size.height; d += 9) {
      canvas.drawLine(Offset(x, d), Offset(x, math.min(d + 5, size.height)), p);
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter old) => old.color != color;
}
