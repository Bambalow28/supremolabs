// The Wall: the catalog as a salon hang. Every release is a pixel-art painting
// in a brass frame with a plaque (catalog number, name, status); forthcoming
// releases hang as an empty keyline frame. Paintings are drawn on a tiny grid
// and scaled with no smoothing, so they stay crisp at any width.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/motion.dart';
import '../app/site_shell.dart';
import '../data/products.dart';
import '../theme/sl_theme.dart';

const _brass = Color(0xFFB8862E);
const _brassDark = Color(0xFF5C3F12);
const _mat = Color(0xFFE6DFCD);
const _plaque = Color(0xFFD8CBA7);
const _plaqueInk = Color(0xFF1B140A);

const _bayer = [
  [0, 8, 2, 10],
  [12, 4, 14, 6],
  [3, 11, 1, 9],
  [15, 7, 13, 5],
];

Color _c(int v) => Color(0xFF000000 | v);

/// A fixed-size grid of colored cells with the few drawing primitives the
/// paintings need.
class Px {
  final int w, h;
  final List<Color?> cells;
  Px(this.w, this.h) : cells = List.filled(w * h, null);

  void p(num x, num y, Color c) {
    final i = x.round(), j = y.round();
    if (i < 0 || j < 0 || i >= w || j >= h) return;
    cells[j * w + i] = c;
  }

  void r(num x, num y, int ww, int hh, Color c) {
    for (var j = 0; j < hh; j++) {
      for (var i = 0; i < ww; i++) {
        p(x + i, y + j, c);
      }
    }
  }

  void l(num x0, num y0, num x1, num y1, Color c) {
    var a = x0.round(), b = y0.round();
    final e1 = x1.round(), f1 = y1.round();
    final dx = (e1 - a).abs(), dy = -(f1 - b).abs();
    final sx = a < e1 ? 1 : -1, sy = b < f1 ? 1 : -1;
    var err = dx + dy;
    for (;;) {
      p(a, b, c);
      if (a == e1 && b == f1) break;
      final e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        a += sx;
      }
      if (e2 <= dx) {
        err += dx;
        b += sy;
      }
    }
  }

  void d(int cx, int cy, int rad, Color c) {
    for (var j = -rad; j <= rad; j++) {
      for (var i = -rad; i <= rad; i++) {
        if (i * i + j * j <= rad * rad + rad) p(cx + i, cy + j, c);
      }
    }
  }

  void grad(Color c1, Color c2) {
    for (var j = 0; j < h; j++) {
      for (var i = 0; i < w; i++) {
        p(i, j, j / h > (_bayer[j & 3][i & 3] + .5) / 16 ? c2 : c1);
      }
    }
  }

  void tri(int cx, int base, int hh, Color c) {
    for (var i = 0; i < hh; i++) {
      r(cx - i, base - hh + i, i * 2 + 1, 1, c);
    }
  }

  void poly(List<List<num>> pts, Color c, [int w = 1]) {
    for (var i = 0; i < pts.length - 1; i++) {
      for (var k = 0; k < w; k++) {
        l(pts[i][0], pts[i][1] + k, pts[i + 1][0], pts[i + 1][1] + k, c);
      }
    }
  }
}

class _Scene {
  final int w, h;
  final void Function(Px) draw;
  const _Scene(this.w, this.h, this.draw);
}

/// One scene per release, in that release's own palette. Keyed by name.
final _scenes = <String, _Scene>{
  'WorkIt': _Scene(48, 36, (g) {
    g.grad(_c(0x0b0c0e), _c(0x17375c));
    g.r(0, 28, 48, 8, _c(0x0b0c0e));
    g.r(0, 28, 48, 1, _c(0x4A9DFF));
    g.r(5, 18, 38, 2, _c(0xc9d3df));
    for (final (a, s) in [(7, 1), (40, -1)]) {
      g.r(a - (s > 0 ? 0 : 2), 9, 3, 20, _c(0x4A9DFF));
      g.r(a + (s > 0 ? 3 : -4), 12, 2, 14, _c(0x2b6fc0));
      g.r(a + (s > 0 ? 5 : -6), 15, 1, 8, _c(0xc9d3df));
    }
    g.r(10, 29, 28, 1, _c(0x17375c));
    for (var i = 0; i < 4; i++) {
      g.r(33 + i * 3, 4, 1, 6, _c(0x4A9DFF));
    }
    g.l(32, 9, 43, 5, _c(0x4A9DFF));
  }),
  'TravelSync': _Scene(48, 36, (g) {
    g.grad(_c(0x4B76FA), _c(0xc6d6ff));
    g.d(37, 9, 4, _c(0xfff3c4));
    g.tri(10, 28, 13, _c(0x27408f));
    g.tri(22, 28, 18, _c(0x1c2f6e));
    g.tri(36, 28, 11, _c(0x27408f));
    g.r(0, 27, 48, 9, _c(0x0B0F1A));
    for (var t = 0.0; t <= 1; t += .045) {
      g.p(4 + t * 38, 26 - math.sin(t * math.pi) * 17, _c(0xffffff));
    }
    g.r(20, 6, 6, 1, _c(0xffffff));
    g.r(23, 4, 1, 5, _c(0xffffff));
    g.r(21, 7, 2, 1, _c(0xffffff));
    g.d(43, 25, 2, _c(0xff5a4f));
    g.p(43, 28, _c(0xff5a4f));
  }),
  'PlanSync': _Scene(36, 48, (g) {
    g.grad(_c(0x0A0E14), _c(0x0f3b38));
    g.r(7, 12, 22, 30, _c(0x2DD4BF));
    g.r(7, 9, 10, 4, _c(0x2DD4BF));
    g.r(10, 6, 16, 28, _c(0xe8fbf8));
    for (var i = 0; i < 5; i++) {
      g.r(12, 10 + i * 5, 12 - (i % 2) * 4, 1, _c(0x2DD4BF));
    }
    g.r(7, 22, 22, 20, _c(0x1fa593));
    g.r(7, 22, 22, 1, _c(0x7ef0e0));
    g.d(24, 31, 2, _c(0x0A0E14));
    g.p(24, 31, _c(0x2DD4BF));
  }),
  'NoteSync': _Scene(36, 48, (g) {
    g.grad(_c(0x000000), _c(0x0a1c38));
    g.r(7, 7, 22, 36, _c(0xf4f6fa));
    g.r(7, 7, 22, 5, _c(0x0A84FF));
    for (var i = 0; i < 4; i++) {
      g.r(11 + i * 5, 5, 1, 4, _c(0xcfe3ff));
    }
    for (var i = 0; i < 6; i++) {
      g.r(10, 16 + i * 4, i == 5 ? 8 : 16, 1, _c(0xc3cfe2));
    }
    g.r(10, 15, 3, 3, _c(0x0A84FF));
    g.l(26, 40, 32, 30, _c(0xFFD35C));
    g.l(27, 40, 33, 30, _c(0xe0a92a));
  }),
  'Diamo': _Scene(36, 48, (g) {
    g.grad(_c(0x211C4D), _c(0x44307a));
    g.r(4, 5, 28, 2, _c(0xFFD35C));
    for (final (x, n) in [(8, 12), (18, 20), (28, 8)]) {
      g.r(x, 7, 1, n, _c(0xd9c58a));
    }
    g.d(8, 22, 4, _c(0xFFD35C));
    g.d(10, 21, 3, _c(0x2e2766));
    g.r(16, 27, 5, 1, _c(0xFFD35C));
    g.r(18, 25, 1, 5, _c(0xFFD35C));
    g.r(17, 26, 3, 3, _c(0xFFD35C));
    g.d(26, 19, 2, _c(0xf5ecff));
    g.d(30, 19, 2, _c(0xf5ecff));
    g.d(28, 17, 2, _c(0xf5ecff));
    g.r(25, 19, 7, 3, _c(0xf5ecff));
    for (var i = 0; i < 8; i++) {
      g.p((i * 13) % 34 + 1, (i * 17) % 20 + 30, _c(0x8e7cd0));
    }
  }),
  'Stanverse': _Scene(40, 40, (g) {
    g.grad(_c(0x0E0D10), _c(0x241f2a));
    g.r(4, 12, 32, 16, _c(0xF5F2EC));
    g.d(4, 20, 2, _c(0x17141b));
    g.d(35, 20, 2, _c(0x17141b));
    for (var y = 13; y < 28; y += 2) {
      g.p(26, y, _c(0x9a948a));
    }
    const star = [
      '...X...',
      '...X...',
      'XXXXXXX',
      '.XXXXX.',
      '..XXX..',
      '.XX.XX.',
      '.X...X.',
    ];
    for (var j = 0; j < star.length; j++) {
      for (var i = 0; i < 7; i++) {
        if (star[j][i] == 'X') g.p(9 + i, 16 + j, _c(0x0E0D10));
      }
    }
    g.r(29, 16, 5, 1, _c(0x0E0D10));
    g.r(29, 19, 4, 1, _c(0x0E0D10));
    g.r(29, 22, 5, 1, _c(0x0E0D10));
    for (final (x, y) in [(6, 6), (33, 5), (20, 34), (8, 33), (31, 35)]) {
      g.p(x, y, _c(0xF5F2EC));
    }
  }),
  'FamFi': _Scene(40, 40, (g) {
    g.grad(_c(0x0C0E12), _c(0x16307a));
    g.d(15, 20, 10, _c(0x2E5BE8));
    g.d(15, 20, 7, _c(0x0C0E12));
    g.d(15, 20, 6, _c(0x2E5BE8));
    g.d(26, 20, 10, _c(0x9db9ff));
    g.d(26, 20, 7, _c(0x16307a));
    g.d(26, 20, 6, _c(0x9db9ff));
    g.r(13, 16, 4, 8, _c(0x0C0E12));
    g.r(24, 16, 4, 8, _c(0x16307a));
    g.r(5, 33, 30, 2, _c(0x2E5BE8));
    g.r(8, 35, 24, 1, _c(0x1a2d70));
  }),
  'ESYNC': _Scene(48, 36, (g) {
    g.grad(_c(0x05080B), _c(0x0b3039));
    g.r(0, 28, 48, 8, _c(0x10171c));
    for (var x = 2; x < 48; x += 8) {
      g.r(x, 32, 4, 1, _c(0x2EE6FF));
    }
    g.r(10, 21, 28, 6, _c(0x2EE6FF));
    g.r(15, 16, 17, 5, _c(0x2EE6FF));
    g.r(17, 17, 6, 3, _c(0x05080B));
    g.r(25, 17, 5, 3, _c(0x05080B));
    g.d(16, 27, 3, _c(0x05080B));
    g.d(33, 27, 3, _c(0x05080B));
    g.d(16, 27, 1, _c(0xc9f7ff));
    g.d(33, 27, 1, _c(0xc9f7ff));
    g.r(4, 12, 3, 17, _c(0x1b2a33));
    g.r(3, 10, 5, 3, _c(0xFFE14D));
    g.l(7, 20, 10, 23, _c(0xFFE14D));
    g.poly(
      [
        [40, 3],
        [37, 9],
        [40, 9],
        [37, 15],
      ],
      _c(0xFFE14D),
      2,
    );
  }),
  'HoopSync': _Scene(36, 48, (g) {
    g.grad(_c(0x09090B), _c(0x2d1407));
    g.r(8, 5, 20, 13, _c(0xe9e9ec));
    g.r(14, 10, 8, 1, _c(0xFF6A1F));
    g.r(14, 16, 8, 1, _c(0xFF6A1F));
    g.r(14, 10, 1, 7, _c(0xFF6A1F));
    g.r(21, 10, 1, 7, _c(0xFF6A1F));
    g.r(12, 18, 12, 2, _c(0xFF6A1F));
    for (var i = 0; i < 6; i++) {
      for (var x = 13 + (i >> 1); x < 23 - (i >> 1); x++) {
        if ((x + i) % 2 == 0) g.p(x, 20 + i, _c(0xf4f4f5));
      }
    }
    g.d(18, 37, 5, _c(0xFF6A1F));
    g.l(13, 37, 23, 37, _c(0x09090B));
    g.l(18, 32, 18, 42, _c(0x09090B));
    for (var t = 0.0; t <= 1; t += .07) {
      g.p(
        8 + t * 10,
        34 - math.sin(t * math.pi * .9) * 14 * t * 1.2,
        _c(0xFFC53D),
      );
    }
    g.r(0, 44, 36, 4, _c(0x3a1f0e));
  }),
  'HundredFold': _Scene(36, 48, (g) {
    g.r(0, 0, 36, 48, _c(0x050806));
    final rail = _c(0x1f4a2a);
    g.l(0, 0, 12, 14, rail);
    g.l(36, 0, 24, 14, rail);
    g.l(0, 48, 12, 34, rail);
    g.l(36, 48, 24, 34, rail);
    g.r(12, 14, 12, 20, _c(0x0b1a10));
    g.r(15, 19, 6, 15, _c(0xFFB020));
    g.r(16, 20, 4, 13, _c(0xffd36a));
    for (var i = 0; i < 5; i++) {
      g.l(3 + i * 2, 46 - i * 2, 15 + i, 35, _c(0x0e2615));
    }
    final red = _c(0xff2a2a);
    for (final (x, y) in [(5, 28), (9, 28), (27, 31), (31, 31)]) {
      g.r(x, y, 2, 2, red);
    }
    for (var i = 0; i < 4; i++) {
      if (i != 1) g.r(10 + i * 4, 4, 3, 5, red);
    }
  }),
  'Vestiary': _Scene(36, 48, (g) {
    final bg = _c(0x0E1220);
    g.r(0, 0, 36, 48, bg);
    final crop = _c(0x6f9bff);
    for (final (x, y, a, b) in [
      (3, 3, 1, 1),
      (32, 3, -1, 1),
      (3, 44, 1, -1),
      (32, 44, -1, -1),
    ]) {
      g.r(math.min(x, x + a * 6), y, 7, 1, crop);
      g.r(x, math.min(y, y + b * 6), 1, 7, crop);
    }
    num hw(int y) => y < 14
        ? 7
        : y < 22
        ? 7 - (y - 14) * 0.5
        : y < 24
        ? 3
        : 3 + (y - 24) * 0.56;
    void row(int y, int half, Color c) => g.r(18 - half, y, half * 2, 1, c);
    for (var y = 9; y <= 40; y++) {
      row(y, hw(y).round() + 1, _c(0xEDF0F6));
    }
    for (var y = 10; y <= 39; y++) {
      row(y, hw(y).round(), _c(0xFF7A45));
    }
    g.r(13, 9, 10, 2, bg);
    g.r(14, 11, 8, 1, bg);
    g.r(15, 12, 6, 1, bg);
    g.r(8, 9, 1, 3, bg);
    g.r(27, 9, 1, 3, bg);
    g.r(16, 15, 4, 1, bg);
    g.p(16, 14, bg);
    g.p(19, 14, bg);
    for (var x = 7; x < 30; x += 3) {
      g.r(x, 38, 2, 1, bg);
    }
  }),
  'MarketPulse': _Scene(48, 36, (g) {
    g.grad(_c(0x07101C), _c(0x0e2a47));
    final grid = _c(0x14304c);
    for (var x = 0; x < 48; x += 8) {
      for (var y = 0; y < 36; y += 2) {
        g.p(x, y, grid);
      }
    }
    for (var y = 6; y < 36; y += 8) {
      for (var x = 0; x < 48; x += 2) {
        g.p(x, y, grid);
      }
    }
    const pts = [
      [2, 24],
      [14, 24],
      [18, 16],
      [22, 30],
      [27, 6],
      [33, 24],
      [46, 24],
    ];
    g.poly(
      [
        for (final p in pts) [p[0], p[1] + 2],
      ],
      _c(0x14704a),
      2,
    );
    g.poly(pts, _c(0x2ED68B), 2);
  }),
  'Jarvis': _Scene(36, 48, (g) {
    g.grad(_c(0x13161B), _c(0x0d0f13));
    g.poly([
      [6, 6],
      [18, 8],
      [30, 6],
      [34, 40],
      [4, 42],
      [6, 6],
    ], _c(0x1b1f26));
    for (final (a, b, c, d) in [
      (10, 8, 9, 36),
      (18, 9, 17, 40),
      (26, 8, 27, 38),
    ]) {
      g.l(a, b, c, d, _c(0x232832));
    }
    g.r(14, 2, 8, 1, _c(0x3a414c));
  }),
};

class _PixelPainter extends CustomPainter {
  final Px px;
  _PixelPainter(this.px);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / px.w;
    final paint = Paint()..isAntiAlias = false;
    for (var j = 0; j < px.h; j++) {
      for (var i = 0; i < px.w; i++) {
        final c = px.cells[j * px.w + i];
        if (c == null) continue;
        paint.color = c;
        // Overdraw by a hair so adjacent cells never leave a seam.
        canvas.drawRect(Rect.fromLTWH(i * s, j * s, s + 0.6, s + 0.6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter old) => false;
}

class Wall extends StatelessWidget {
  const Wall({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 760;
    final cols = width >= 1000 ? 4 : (narrow ? 2 : 3);
    final gap = narrow ? 20.0 : 44.0;

    // Greedy hang: each painting goes in the shortest column, so catalog
    // numbers still read roughly left to right while heights stay uneven.
    final columns = List.generate(cols, (_) => <Product>[]);
    final heights = List<double>.filled(cols, 0);
    for (final p in products) {
      final s = _scenes[p.name]!;
      var k = 0;
      for (var i = 1; i < cols; i++) {
        if (heights[i] < heights[k]) k = i;
      }
      columns[k].add(p);
      heights[k] += s.h / s.w + 0.55;
    }

    return SLPage(
      padding: EdgeInsets.fromLTRB(24, narrow ? 56 : 80, 24, narrow ? 56 : 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text('The Wall', style: SLType.display(narrow ? 44 : 64)),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Every release, framed and hung. Step up to a painting to open the app.',
              style: SLType.body(16),
            ),
          ),
          SizedBox(height: narrow ? 28 : 36),
          Container(
            color: const Color(0xFF12151B),
            padding: EdgeInsets.fromLTRB(
              narrow ? 16 : 48,
              narrow ? 44 : 72,
              narrow ? 16 : 48,
              0,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var k = 0; k < cols; k++) ...[
                      if (k > 0) SizedBox(width: gap),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: k.isOdd ? (narrow ? 28 : 40) : 0,
                          ),
                          child: Column(
                            children: [
                              for (final p in columns[k]) _Painting(product: p),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Chair rail and skirting: the floor line of the room.
                const SizedBox(height: 24),
                Container(height: 6, color: const Color(0xFF2A2118)),
                Container(
                  height: narrow ? 40 : 56,
                  color: const Color(0xFF0D0F13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Painting extends StatefulWidget {
  final Product product;
  const _Painting({required this.product});

  @override
  State<_Painting> createState() => _PaintingState();
}

class _PaintingState extends State<_Painting> {
  late final Px _px;
  late final _Scene _scene;

  @override
  void initState() {
    super.initState();
    _scene = _scenes[widget.product.name]!;
    _px = Px(_scene.w, _scene.h);
    _scene.draw(_px);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final live = p.live;
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Semantics(
        button: live,
        enabled: live,
        label: live
            ? 'Open ${p.name}. ${p.tagline}'
            : '${p.name}, forthcoming. ${p.tagline}',
        child: ExcludeSemantics(
          child: Hover(
            onTap: live ? () => context.push(p.route!) : null,
            builder: (context, hovered) => Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutExpo,
                  transform: Matrix4.translationValues(0, hovered ? -4 : 0, 0),
                  margin: const EdgeInsets.fromLTRB(9, 9, 9, 0),
                  padding: const EdgeInsets.all(8),
                  decoration: live
                      ? const BoxDecoration(
                          color: Color(0xFF17120D),
                          boxShadow: [
                            BoxShadow(color: _brass, spreadRadius: 3),
                            BoxShadow(color: _brassDark, spreadRadius: 6),
                            BoxShadow(
                              color: Color(0x73000000),
                              offset: Offset(8, 8),
                              spreadRadius: 6,
                            ),
                          ],
                        )
                      : BoxDecoration(
                          border: Border.all(
                            color: SLColors.hairline,
                            width: 2,
                          ),
                        ),
                  child: Container(
                    color: live ? _mat : Colors.transparent,
                    padding: const EdgeInsets.all(7),
                    child: AspectRatio(
                      aspectRatio: _scene.w / _scene.h,
                      child: CustomPaint(painter: _PixelPainter(_px)),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                _Plaque(product: p, hovered: hovered),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Plaque extends StatelessWidget {
  final Product product;
  final bool hovered;
  const _Plaque({required this.product, required this.hovered});

  @override
  Widget build(BuildContext context) {
    final live = product.live;
    final ink = live ? _plaqueInk : SLColors.inkMuted;
    final no =
        'SL ${(products.indexOf(product) + 1).toString().padLeft(3, '0')}';
    return Container(
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      decoration: live
          ? const BoxDecoration(
              color: _plaque,
              boxShadow: [
                BoxShadow(color: Color(0xFF7A5B22), spreadRadius: 2),
                BoxShadow(
                  color: Color(0x80000000),
                  offset: Offset(3, 3),
                  spreadRadius: 2,
                ),
              ],
            )
          : BoxDecoration(border: Border.all(color: SLColors.hairline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            no,
            style: GoogleFonts.silkscreen(
              fontSize: 12,
              color: ink.withValues(alpha: .75),
            ),
          ),
          Text(
            product.name,
            style: SLType.display(
              20,
              weight: FontWeight.w800,
            ).copyWith(color: ink, letterSpacing: .8),
          ),
          Text(
            live ? 'OUT NOW' : 'FORTHCOMING',
            style: SLType.label(ink).copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
