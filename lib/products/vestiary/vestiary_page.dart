// THESIS: /vestiary is a pattern-maker's tissue sheet. Your closet is laid out
// as numbered pieces under crop marks, so the page shows what the app does by
// being one: pieces, a layout, a try-on.
// OWN-WORLD: the app's own ink tile and tissue sheet, Bodoni italic display,
// Sofia Sans Condensed labels, vermilion from the icon's dress. Pieces are
// drawn outlines, labelled as such: no screenshots exist for the site yet.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_icon.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import '../../data/products.dart';

class VSColors {
  VSColors._();
  static const night = Color(0xFF0E1220);
  static const night2 = Color(0xFF171C2C);
  static const tissue = Color(0xFFEDF0F6);
  static const sheet = Color(0xFFF8F9FD);
  static const ink = Color(0xFF12141C);
  static const ink2 = Color(0xFF474C60);
  static const nightInk = Color(0xFFECEFFA);
  static const nightMute = Color(0xFFB6BCD2);
  static const magenta = Color(0xFFD91E75);
  static const cobalt = Color(0xFF2457D6);
  static const vermilion = Color(0xFFFF7A45);
}

TextStyle vsDisplay(double size, {Color color = VSColors.nightInk}) =>
    GoogleFonts.bodoniModa(
      fontSize: size,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.02,
      letterSpacing: -0.01 * size,
    );

TextStyle vsLabel({Color color = VSColors.nightMute, double size = 12.5}) =>
    GoogleFonts.sofiaSansCondensed(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1.2,
    );

TextStyle vsBody(double size, {Color color = VSColors.nightMute}) =>
    GoogleFonts.hankenGrotesk(fontSize: size, color: color, height: 1.5);

class VestiaryPage extends StatelessWidget {
  const VestiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final product = productForRoute('/vestiary')!;
    return SiteShell(
      ground: VSColors.night,
      children: [
        SLPage(
          maxWidth: 1080,
          padding: EdgeInsets.fromLTRB(20, wide ? 56 : 32, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: _Hero(product: product, wide: wide),
              ),
              SizedBox(height: wide ? 88 : 56),
              FadeSlideIn(child: _Steps(wide: wide)),
              SizedBox(height: wide ? 88 : 56),
              FadeSlideIn(child: _Layout(wide: wide)),
              SizedBox(height: wide ? 88 : 56),
              const FadeSlideIn(child: _Privacy()),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final Product product;
  final bool wide;
  const _Hero({required this.product, required this.wide});

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon(product: product, size: 48, shadow: true),
            const SizedBox(width: 14),
            Text('VESTIARY · FOR IPHONE', style: vsLabel()),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Your closet,\nlaid out like\na pattern sheet.',
          style: vsDisplay(wide ? 76 : 48),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Photograph what you own and Vestiary cuts each piece out, traces its '
            'exact outline and hangs it on your rail. Lay pieces out into outfits, '
            'then see them on you with an AI try-on.',
            style: vsBody(17),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'IN PRIVATE TESTING ON TESTFLIGHT',
          style: vsLabel(color: VSColors.vermilion),
        ),
      ],
    );
    final sheet = const _PatternSheet();
    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: copy),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: sheet),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 40), sheet],
          );
  }
}

/// A tissue sheet with crop marks and three numbered pieces drawn as outlines.
class _PatternSheet extends StatelessWidget {
  const _PatternSheet();

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: Semantics(
      label: 'Illustration: three garment outlines on a pattern sheet',
      child: CustomPaint(painter: _SheetPainter()),
    ),
  );
}

class _SheetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = VSColors.tissue);
    final mark = Paint()
      ..color = VSColors.cobalt
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final m = s.width * 0.07;
    final l = s.width * 0.08;
    for (final (cx, cy, dx, dy) in [
      (m, m, 1.0, 1.0),
      (s.width - m, m, -1.0, 1.0),
      (m, s.height - m, 1.0, -1.0),
      (s.width - m, s.height - m, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx * l, cy), mark);
      canvas.drawLine(Offset(cx, cy), Offset(cx, cy + dy * l), mark);
    }
    final fill = Paint()..color = VSColors.vermilion;
    final edge = Paint()
      ..color = VSColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final u = s.width / 100;
    // Dress
    final dress = Path()
      ..moveTo(18 * u, 24 * u)
      ..lineTo(24 * u, 22 * u)
      ..quadraticBezierTo(30 * u, 30 * u, 36 * u, 22 * u)
      ..lineTo(42 * u, 24 * u)
      ..lineTo(38 * u, 46 * u)
      ..lineTo(48 * u, 78 * u)
      ..lineTo(12 * u, 78 * u)
      ..lineTo(22 * u, 46 * u)
      ..close();
    // Tee
    final tee = Path()
      ..moveTo(58 * u, 24 * u)
      ..lineTo(66 * u, 22 * u)
      ..quadraticBezierTo(72 * u, 28 * u, 78 * u, 22 * u)
      ..lineTo(86 * u, 24 * u)
      ..lineTo(90 * u, 36 * u)
      ..lineTo(82 * u, 40 * u)
      ..lineTo(82 * u, 52 * u)
      ..lineTo(62 * u, 52 * u)
      ..lineTo(62 * u, 40 * u)
      ..lineTo(54 * u, 36 * u)
      ..close();
    // Trousers
    final trousers = Path()
      ..moveTo(60 * u, 58 * u)
      ..lineTo(84 * u, 58 * u)
      ..lineTo(86 * u, 84 * u)
      ..lineTo(76 * u, 84 * u)
      ..lineTo(72 * u, 68 * u)
      ..lineTo(68 * u, 84 * u)
      ..lineTo(58 * u, 84 * u)
      ..close();
    for (final (p, c) in [
      (dress, VSColors.vermilion),
      (tee, VSColors.cobalt),
      (trousers, VSColors.magenta),
    ]) {
      canvas.drawPath(p, fill..color = c);
      canvas.drawPath(p, edge);
    }
    final tp = [
      ('No. 01  DRESS', Offset(12 * u, 84 * u)),
      ('No. 02  TEE', Offset(58 * u, 14 * u)),
      ('No. 03  TROUSERS', Offset(52 * u, 89 * u)),
    ];
    for (final (t, o) in tp) {
      final span = TextPainter(
        text: TextSpan(
          text: t,
          style: vsLabel(color: VSColors.ink2, size: s.width * 0.03),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      span.paint(canvas, o);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Steps extends StatelessWidget {
  final bool wide;
  const _Steps({required this.wide});

  static const _items = [
    (
      'Photograph',
      'Snap a piece. Vestiary finds the product online for clean data, or cuts out your own photo on the device.',
    ),
    (
      'Trace',
      'The cutout is cleaned and its exact outline traced, so every piece hangs on the rail as its own shape.',
    ),
    (
      'Hang',
      'Pieces are numbered and filed by type. Your closet stays on your account, private to you.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Three steps to a rail.', style: vsDisplay(wide ? 44 : 32)),
      const SizedBox(height: 28),
      Flex(
        direction: wide ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) SizedBox(width: 32, height: 28),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: VSColors.nightMute.withValues(alpha: .35),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'PIECE ${(i + 1).toString().padLeft(2, '0')} · ${_items[i].$1.toUpperCase()}',
                    style: vsLabel(color: VSColors.vermilion),
                  ),
                  const SizedBox(height: 10),
                  Text(_items[i].$2, style: vsBody(16)),
                ],
              ),
            ),
          ],
        ],
      ),
    ],
  );
}

class _Layout extends StatelessWidget {
  final bool wide;
  const _Layout({required this.wide});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(wide ? 40 : 24),
    color: VSColors.night2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Outfits are layouts.', style: vsDisplay(wide ? 44 : 32)),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Set a top, bottom, outerwear, shoes and a bag side by side, save the '
            'layout, and try it on yourself before you put anything on. Three or '
            'four combinations in a minute, no pile on the bed.',
            style: vsBody(17),
          ),
        ),
      ],
    ),
  );
}

class _Privacy extends StatelessWidget {
  const _Privacy();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Yours alone.', style: vsDisplay(32)),
      const SizedBox(height: 12),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Text(
          'Each person has their own account and a closet nobody else can see. '
          'Vestiary never tries to sell you anything.',
          style: vsBody(16),
        ),
      ),
      const SizedBox(height: 20),
      Text('FORMERLY DRESSMEUP', style: vsLabel(size: 11)),
    ],
  );
}
