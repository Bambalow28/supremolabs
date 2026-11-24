import 'package:flutter/material.dart';

const _segs = {
  '0': 'abcdef',
  '1': 'bc',
  '2': 'abdeg',
  '3': 'abcdg',
  '4': 'bcfg',
  '5': 'acdfg',
  '6': 'acdefg',
  '7': 'abc',
  '8': 'abcdefg',
  '9': 'abcdfg',
  '-': 'g',
};

/// Seven-segment readout. Unlit segments are drawn as ghost cells.
/// [cells] pads with ghost digits on the left, e.g. cells: 5 for "3700" → ghost 8 + 3700.
class HfSevenSeg extends StatelessWidget {
  const HfSevenSeg(
    this.text, {
    super.key,
    this.height = 36,
    this.color = const Color(0xFFFFB020),
    this.cells = 0,
  });
  final String text;
  final double height;
  final Color color;
  final int cells;

  @override
  Widget build(BuildContext context) {
    final p = _SegPainter(text.replaceAll(',', ''), color, cells);
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size(height * p.width / 100, height),
          painter: p,
        ),
      ),
    );
  }
}

class _SegPainter extends CustomPainter {
  _SegPainter(this.text, this.color, this.cells)
    : seq = [
        ...List.filled(
          (cells - text.split('').where((c) => _segs.containsKey(c)).length)
              .clamp(0, 99),
          ' ',
        ),
        ...text.split(''),
      ];
  final String text;
  final Color color;
  final int cells;
  final List<String> seq;

  double get width => seq.fold(
    0.0,
    (w, c) =>
        w +
        (c == ':'
            ? 30
            : c == '.'
            ? 24
            : 74),
  );

  Path _hz(double x1, double x2, double y) => Path()
    ..moveTo(x1, y + 5)
    ..lineTo(x1 + 5, y)
    ..lineTo(x2 - 5, y)
    ..lineTo(x2, y + 5)
    ..lineTo(x2 - 5, y + 10)
    ..lineTo(x1 + 5, y + 10)
    ..close();
  Path _vt(double x, double y1, double y2) => Path()
    ..moveTo(x + 5, y1)
    ..lineTo(x + 10, y1 + 5)
    ..lineTo(x + 10, y2 - 5)
    ..lineTo(x + 5, y2)
    ..lineTo(x, y2 - 5)
    ..lineTo(x, y1 + 5)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.height / 100);
    canvas.transform(
      (Matrix4.identity()..setEntry(0, 1, .105)).storage,
    ); // italic skew
    final on = Paint()..color = color;
    final off = Paint()..color = color.withValues(alpha: .1);
    final geo = {
      'a': _hz(6, 54, 0),
      'g': _hz(6, 54, 45),
      'd': _hz(6, 54, 90),
      'f': _vt(0, 6, 48),
      'b': _vt(50, 6, 48),
      'e': _vt(0, 52, 94),
      'c': _vt(50, 52, 94),
    };
    double x = 0;
    for (final ch in seq) {
      if (ch == ':') {
        canvas.drawRect(Rect.fromLTWH(x + 6, 26, 11, 11), on);
        canvas.drawRect(Rect.fromLTWH(x + 6, 62, 11, 11), on);
        x += 30;
      } else if (ch == '.') {
        canvas.drawRect(Rect.fromLTWH(x + 4, 90, 11, 10), on);
        x += 24;
      } else {
        final lit = _segs[ch] ?? '';
        geo.forEach(
          (k, path) => canvas.drawPath(
            path.shift(Offset(x, 0)),
            lit.contains(k) ? on : off,
          ),
        );
        x += 74;
      }
    }
  }

  @override
  bool shouldRepaint(_SegPainter o) =>
      o.text != text || o.color != color || o.cells != cells;
}
