import 'package:flutter/material.dart';

import 'es_colors.dart';

enum Tone {
  volt(ESColors.voltDim, ESColors.volt),
  amber(Color(0xFFA85F00), ESColors.amber),
  red(Color(0xFFB23316), ESColors.over),
  go(Color(0xFF1D8A5C), ESColors.go);

  final Color dim;
  final Color bright;
  const Tone(this.dim, this.bright);
}

/// The app's lit ladder: [n] segments, the first `frac * n` glowing from dim
/// to bright, an optional white peak marker. Fills from zero on first build,
/// each segment catching in turn.
class Ladder extends StatelessWidget {
  final double frac;
  final double? peak;
  final int n;
  final double h;
  final Tone tone;
  const Ladder(
    this.frac, {
    super.key,
    this.n = 40,
    this.h = 22,
    this.peak,
    this.tone = Tone.volt,
  });

  @override
  Widget build(BuildContext context) {
    final f = frac.clamp(0.0, 1.0);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? f : 0, end: f),
      duration: Duration(milliseconds: 500 + n * 14),
      curve: esEase,
      builder: (_, v, _) => SizedBox(
        height: h,
        width: double.infinity,
        child: CustomPaint(painter: _Ladder(v, f, n, peak, tone)),
      ),
    );
  }
}

class _Ladder extends CustomPainter {
  final double v, target;
  final int n;
  final double? peak;
  final Tone tone;
  _Ladder(this.v, this.target, this.n, this.peak, this.tone);

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 2.0;
    final w = (size.width - gap * (n - 1)) / n;
    final on = (v * n).round();
    final pk = peak == null ? -1 : (peak! * n).round().clamp(0, n - 1);
    final q = target <= 0 ? 1.0 : (v / target).clamp(0.0, 1.0);
    final peakVis = q * q * q;
    for (var i = 0; i < n; i++) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (w + gap), 0, w, size.height),
        const Radius.circular(2),
      );
      if (i == pk) {
        canvas.drawRRect(
          r,
          Paint()
            ..color = Color.fromRGBO(255, 255, 255, .6 * peakVis)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawRRect(
          r,
          Paint()..color = Color.fromRGBO(255, 255, 255, peakVis),
        );
      } else if (i < on) {
        final c = Color.lerp(tone.dim, tone.bright, i / (n - 1))!;
        canvas.drawRRect(
          r,
          Paint()
            ..color = c.withValues(alpha: .45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
        );
        canvas.drawRRect(r, Paint()..color = c);
      } else {
        canvas.drawRRect(
          r,
          Paint()..color = tone.bright.withValues(alpha: .10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Ladder o) => o.v != v || o.target != target;
}

/// A column chart in the same segments: each bar of [values] (0–1) fills from
/// the bottom, bars catching one after another; the tallest gets the peak.
class LedColumns extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double h;
  const LedColumns({
    super.key,
    required this.values,
    required this.labels,
    this.h = 150,
  });

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.linear,
      builder: (_, t, _) => Column(
        children: [
          SizedBox(
            height: h,
            width: double.infinity,
            child: CustomPaint(painter: _Cols(values, t)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final l in labels)
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: esText(
                      11,
                      color: ESColors.ink2,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cols extends CustomPainter {
  final List<double> values;
  final double t;
  _Cols(this.values, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 16, gap = 2.0, colGap = 8.0;
    final n = values.length;
    final cw = (size.width - colGap * (n - 1)) / n;
    final sh = (size.height - gap * (rows - 1)) / rows;
    final top = values.indexOf(values.reduce((a, b) => a > b ? a : b));
    for (var c = 0; c < n; c++) {
      // Each column starts a beat after the last.
      final local = esEase.transform(((t * 1.6 - c * 0.12)).clamp(0.0, 1.0));
      final on = (values[c] * rows * local).round();
      for (var r = 0; r < rows; r++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            c * (cw + colGap),
            size.height - (r + 1) * sh - r * gap,
            cw,
            sh,
          ),
          const Radius.circular(2),
        );
        if (r < on) {
          final isPeak = c == top && r == on - 1 && local >= 1;
          final col = isPeak
              ? Colors.white
              : Color.lerp(ESColors.voltDim, ESColors.volt, r / (rows - 1))!;
          canvas.drawRRect(
            rect,
            Paint()
              ..color = col.withValues(alpha: .45)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
          canvas.drawRRect(rect, Paint()..color = col);
        } else {
          canvas.drawRRect(
            rect,
            Paint()..color = ESColors.volt.withValues(alpha: .10),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_Cols o) => o.t != t;
}
