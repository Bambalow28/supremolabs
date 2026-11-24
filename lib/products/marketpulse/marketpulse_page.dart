// THESIS: /marketpulse is a news wire with a pulse. A headline arrives, the
// page shows the read on it, and the line that carries it is the app's icon.
// The app itself runs at /marketpulse/personal; this page describes it.
// OWN-WORLD: deep navy ground, signal green, Sora, ported from the app's own
// widgets.dart. Rows are sample headlines labelled as samples, never live
// quotes. Signals are framed as model output, not advice.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_icon.dart';
import '../../app/motion.dart';
import '../../app/site_shell.dart';
import '../../data/products.dart';

class MPColors {
  MPColors._();
  static const ground = Color(0xFF07101C);
  static const panel = Color(0xFF0E1B2D);
  static const rule = Color(0xFF1B2D44);
  static const text = Color(0xFFE8F0F8);
  static const mute = Color(0xFF93A5BA);
  static const pulse = Color(0xFF2ED68B);
  static const warn = Color(0xFFFFB454);
  static const down = Color(0xFFFF6B78);
}

TextStyle mpTitle(double size, {Color color = MPColors.text}) =>
    GoogleFonts.sora(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.08,
      letterSpacing: -0.02 * size,
    );

TextStyle mpBody(
  double size, {
  Color color = MPColors.mute,
  FontWeight weight = FontWeight.w400,
}) => GoogleFonts.sora(
  fontSize: size,
  color: color,
  height: 1.6,
  fontWeight: weight,
);

const _kPanel = Color(0xFF13243A);

class MarketPulsePage extends StatelessWidget {
  const MarketPulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final product = productForRoute('/marketpulse')!;
    return SiteShell(
      ground: MPColors.ground,
      children: [
        SLPage(
          maxWidth: 1000,
          padding: EdgeInsets.fromLTRB(20, wide ? 40 : 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: _Hero(product: product, wide: wide),
              ),
              _Row(
                wide: wide,
                title: 'A wire that does the first read.',
                body: [
                  'Headlines are clustered across outlets, scored for source reliability, and given an AI read: what it likely touches and how hard. One non-primary source is labelled a rumour until a second outlet or the filing confirms it.',
                ],
                facts: const [
                  ('Sources', '~35 feeds, switch any off'),
                  ('Reliability', 'Primary filings outrank wire copy'),
                  ('No AI key', 'Keyword read still works'),
                  (
                    'Noise',
                    'Single-outlet trade press must pass a relevance test',
                  ),
                  ('Strip', 'Indices, then most active, refreshed live'),
                ],
                visual: const _SourceCheck(),
              ),
              _Row(
                wide: wide,
                flip: true,
                title: 'What happened last time something like this did.',
                body: [
                  'Pick a stock and the app finds past days where its price moved more than a set number of sigmas, then shows the strategy that bought the next open, after costs, against simply holding.',
                  'There is no news archive behind it, so event days are price moves. It says so on screen.',
                ],
                facts: const [
                  ('Entry', 'Next open'),
                  ('Costs', '0.1% a side'),
                  ('Result shown', 'Profit per \$1,000'),
                ],
                visual: const _ScenarioPanel(),
              ),
              _Row(
                wide: wide,
                flip: true,
                title: 'The whole market on one screen.',
                body: const [
                  'A heatmap of the S&P 500 by sector and by stock. Tile size is a rough weight, colour is the live day change, and any tile opens that stock: a price chart you can flip between line and candles, with trend and volume layers.',
                ],
                facts: const [
                  ('Size', 'Approximate sector and market-cap weight'),
                  ('Colour', 'Live day change'),
                  ('Stock page', 'Line or candles, trend, volume'),
                ],
                visual: const _HeatmapPanel(),
              ),
              _Row(
                wide: wide,
                title: 'Movers, scored and ranked.',
                body: [
                  'Gainers, losers and most-active names are scanned and scored out of 100 on volume, move size, trend, breakout and news. Each signal shows a target, a stop and a projected win rate, and a risk slider trades win rate for size.',
                ],
                facts: const [
                  ('Prices', 'LIVE, beside each target and stop'),
                  ('Watchlists', 'Search popular stocks, save to a folder'),
                  ('Tracked', 'Up to 10 trading days'),
                  ('Alerts', 'When a new one appears'),
                  ('Past tab', 'Same rules on real history'),
                ],
                visual: const _SignalsPanel(),
              ),
              _Row(
                wide: wide,
                flip: true,
                title: 'Learn to trade on paper first.',
                body: [
                  'Eight levels of drills on simulated charts, then a real-chart exam on a random liquid stock and day from ten years of history, graded against what the market did. Paper trades run on live charts and fill at the next open. The playbook covers chart strategies and option structures, each with a drawn example.',
                ],
                facts: const [
                  ('Pass mark', '70% average over 5 drills'),
                  ('Stored', 'On this device only'),
                ],
                visual: const _AcademyPanel(),
              ),
              _Row(
                wide: wide,
                title: 'Lives on the phone. No account.',
                body: [
                  'No backend. API keys stay in the iOS Keychain, news comes straight from public feeds, and everything else is stored on the device. Alerts check every 2 minutes while the app is open; when closed, iOS decides when to wake it.',
                ],
                facts: const [
                  ('Headline AI', 'Claude Haiku, your own key'),
                  ('Prices', 'Unofficial public feed'),
                  ('Closed-app alerts', 'Best effort'),
                  ('Account', 'None'),
                ],
              ),
              const _Cta(),
              const SizedBox(height: 56),
              const _Disclosure(),
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
            Text('MarketPulse', style: mpTitle(22)),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'The news,\nand what it\ncould move.',
          style: mpTitle(wide ? 76 : 44),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Live market headlines from about 35 public feeds, an AI read on likely impact, look-alike days from price history, and a ranked list of movers. Built for my own screen first.',
            style: mpBody(16),
          ),
        ),
        const SizedBox(height: 24),
        const _Pulse(),
        const SizedBox(height: 24),
        _Btn(
          'Open my console',
          onTap: () => context.go('/marketpulse/personal'),
        ),
        const SizedBox(height: 14),
        Text(
          'FOR IPHONE · NOT YET ON THE APP STORE',
          style: mpBody(
            11.5,
            color: MPColors.pulse,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.4),
        ),
      ],
    );
    if (!wide) {
      return Column(
        children: [copy, const SizedBox(height: 40), const _Phone()],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 115, child: copy),
        const SizedBox(width: 48),
        const Expanded(flex: 85, child: Center(child: _Phone())),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: MPColors.pulse,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: mpBody(
                15,
                color: const Color(0xFF04130C),
                weight: FontWeight.w700,
              ),
            ),
            ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Color(0xFF04130C),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// The app's News tab, in a phone frame. Sample headlines, never live quotes.
class _Phone extends StatelessWidget {
  const _Phone();

  static const _rows = [
    (
      'BREAKING',
      'Fed · primary',
      'Central bank holds rates, drops "further progress" language',
      [
        ('Yields ↓', MPColors.down),
        ('TLT ↑', MPColors.pulse),
        ('High impact', MPColors.warn),
      ],
    ),
    (
      '',
      'Reuters + 2 confirm',
      'Chipmaker beats on data-centre revenue, guides above consensus',
      [('NVDA +4.1%', MPColors.pulse), ('Medium', MPColors.warn)],
    ),
    (
      '',
      'BLS · primary',
      'US CPI 0.2% m/m vs 0.3% expected',
      [('SPX ↑', MPColors.pulse), ('USD ↓', MPColors.down)],
    ),
    (
      '',
      '1 source · unconfirmed',
      'Report: OPEC+ weighing deeper output cut',
      <(String, Color)>[],
    ),
  ];

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Sample News screen of the MarketPulse app',
    child: Container(
      width: 300,
      height: 600,
      decoration: BoxDecoration(
        color: MPColors.ground,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: const Color(0xFF16263B), width: 7),
        boxShadow: const [
          BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 80,
            offset: Offset(0, 40),
            spreadRadius: -30,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('News', style: mpTitle(24)),
              Text(
                '● LIVE · 14 NEW',
                style: mpBody(
                  10.5,
                  color: MPColors.pulse,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final r in _rows)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: MPColors.rule)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${r.$1.isEmpty ? '' : '${r.$1} · '}${r.$2}',
                    style: mpBody(
                      10.5,
                      color: r.$1.isEmpty ? MPColors.mute : MPColors.down,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.$3,
                    style: mpBody(
                      12.5,
                      color: MPColors.text,
                      weight: FontWeight.w500,
                    ).copyWith(height: 1.4),
                  ),
                  if (r.$4.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [for (final t in r.$4) _Tag(t.$1, t.$2)],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: _kPanel,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: MPColors.rule),
    ),
    child: Text(
      text,
      style: mpBody(
        10.5,
        color: color,
        weight: FontWeight.w600,
      ).copyWith(height: 1),
    ),
  );
}

/// The icon's line, drawn once on load; reduced motion shows it complete.
class _Pulse extends StatelessWidget {
  const _Pulse();

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Decorative pulse line',
      child: SizedBox(
        height: 72,
        width: double.infinity,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: still ? 1 : 0, end: 1),
          duration: const Duration(milliseconds: 1600),
          curve: Curves.easeOutExpo,
          builder: (_, t, _) => CustomPaint(painter: _PulsePainter(t)),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double t;
  _PulsePainter(this.t);

  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height;
    final p = Path()..moveTo(0, h * .7);
    final w = s.width;
    p
      ..lineTo(w * .30, h * .7)
      ..lineTo(w * .36, h * .45)
      ..lineTo(w * .42, h * .95)
      ..lineTo(w * .50, h * .05)
      ..lineTo(w * .58, h * .7)
      ..lineTo(w, h * .7);
    final metric = p.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * t),
      Paint()
        ..color = MPColors.pulse
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.t != t;
}

/// One text-and-picture row. Text on one side, a real screen on the other.
class _Row extends StatelessWidget {
  final bool wide, flip;
  final String title;
  final List<String> body;
  final List<(String, String)> facts;
  final Widget? visual;
  const _Row({
    required this.wide,
    this.flip = false,
    required this.title,
    required this.body,
    required this.facts,
    this.visual,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: mpTitle(wide ? 40 : 28)),
        const SizedBox(height: 18),
        for (final b in body) ...[
          Text(b, style: mpBody(15)),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 12),
        for (final f in facts)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: MPColors.rule)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.$1, style: mpBody(13.5)),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    f.$2,
                    textAlign: TextAlign.right,
                    style: mpBody(13.5, color: MPColors.text),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    final v = visual;
    return Container(
      margin: EdgeInsets.only(top: wide ? 88 : 56),
      padding: EdgeInsets.only(top: wide ? 88 : 56),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: MPColors.rule)),
      ),
      child: FadeSlideIn(
        child: v == null || !wide
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  txt,
                  if (v != null) ...[const SizedBox(height: 32), v],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: flip
                    ? [
                        Expanded(child: v),
                        const SizedBox(width: 64),
                        Expanded(child: txt),
                      ]
                    : [
                        Expanded(child: txt),
                        const SizedBox(width: 64),
                        Expanded(child: v),
                      ],
              ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String head, trail;
  final Widget child;
  const _Panel({required this.head, this.trail = '', required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: MPColors.panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: MPColors.rule),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: MPColors.rule)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(head, style: mpBody(12, weight: FontWeight.w600)),
              ),
              if (trail.isNotEmpty)
                Text(trail, style: mpBody(12, weight: FontWeight.w600)),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.all(20), child: child),
      ],
    ),
  );
}

class _SourceCheck extends StatelessWidget {
  const _SourceCheck();

  Widget _ok(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        const Icon(Icons.check_rounded, size: 17, color: MPColors.pulse),
        const SizedBox(width: 10),
        Text(s, style: mpBody(13.5, color: MPColors.text)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => _Panel(
    head: 'Chipmaker beats Q3 revenue by 6%',
    trail: '14:29',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ok('Primary filing found (SEC 8-K)'),
        _ok('3 independent outlets'),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reliability', style: mpBody(13.5)),
            Text(
              '94 / 100',
              style: mpBody(
                13.5,
                color: MPColors.text,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: const LinearProgressIndicator(
            value: .94,
            minHeight: 6,
            backgroundColor: MPColors.rule,
            color: MPColors.pulse,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'AI READ · NOT ADVICE',
          style: mpBody(
            11,
            color: MPColors.mute,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          'Results and guidance both above consensus. Beats this size have moved the stock up in 9 of the last 12 reactions; peers follow about 60% of the time.',
          style: mpBody(13.5, color: MPColors.text),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag('NVDA', MPColors.pulse),
            _Tag('AMD', MPColors.pulse),
            _Tag('TSM', MPColors.pulse),
            _Tag('INTC?', MPColors.down),
          ],
        ),
      ],
    ),
  );
}

class _ScenarioPanel extends StatelessWidget {
  const _ScenarioPanel();

  @override
  Widget build(BuildContext context) => _Panel(
    head: 'NVDA · after costs vs buy & hold · log scale',
    trail: '2015–2026',
    child: Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(painter: _LinesPainter()),
        ),
        const SizedBox(height: 12),
        for (final r in const [
          ('● Strategy', '+\$1,380', MPColors.pulse),
          ('○ Buy & hold', '+\$960', MPColors.text),
          ('Event days', '41', MPColors.text),
        ])
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: MPColors.rule)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.$1,
                  style: mpBody(
                    13.5,
                    color: r.$3 == MPColors.pulse
                        ? MPColors.pulse
                        : MPColors.mute,
                  ),
                ),
                Text(
                  r.$2,
                  style: mpBody(13.5, color: r.$3, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final grid = Paint()..color = MPColors.rule;
    for (final f in [.22, .5, .78]) {
      c.drawLine(Offset(0, s.height * f), Offset(s.width, s.height * f), grid);
    }
    Path curve(List<double> ys) {
      final p = Path()..moveTo(0, s.height * ys.first);
      for (var i = 1; i < ys.length; i++) {
        p.lineTo(s.width * i / (ys.length - 1), s.height * ys[i]);
      }
      return p;
    }

    c.drawPath(
      curve([.86, .84, .8, .72, .64, .55, .42, .3, .18, .12]),
      Paint()
        ..color = MPColors.pulse
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    c.drawPath(
      curve([.86, .85, .8, .76, .7, .64, .56, .5, .44, .38]),
      Paint()
        ..color = MPColors.mute
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SignalsPanel extends StatelessWidget {
  const _SignalsPanel();

  static const _rows = [
    (
      'NVDA',
      'Earnings beat · volume 3.1× · breakout',
      '82',
      '\$146.20',
      '+4.1% today',
      MPColors.pulse,
    ),
    (
      'TLT',
      'Rate-cut repricing · trend up',
      '74',
      '\$93.80',
      '+1.2% today',
      MPColors.pulse,
    ),
    (
      'XOM',
      'Move unconfirmed · volume normal',
      '51',
      '\$112.40',
      '−0.6% today',
      MPColors.warn,
    ),
  ];

  @override
  Widget build(BuildContext context) => _Panel(
    head: 'Signals · Market',
    trail: 'Risk · Balanced',
    child: Column(
      children: [
        for (final r in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: r.$6, width: 1.5),
                  ),
                  child: Text(
                    r.$3,
                    style: mpBody(
                      12,
                      color: r.$6,
                      weight: FontWeight.w800,
                    ).copyWith(height: 1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.$1,
                        style: mpBody(
                          14.5,
                          color: MPColors.text,
                          weight: FontWeight.w600,
                        ).copyWith(height: 1.3),
                      ),
                      Text(r.$2, style: mpBody(12).copyWith(height: 1.3)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      r.$4,
                      style: mpBody(
                        13.5,
                        color: MPColors.text,
                      ).copyWith(height: 1.3),
                    ),
                    Text(
                      r.$5,
                      style: mpBody(
                        11.5,
                        color: r.$5.startsWith('−')
                            ? MPColors.down
                            : MPColors.pulse,
                      ).copyWith(height: 1.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.only(top: 14),
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: MPColors.rule)),
          ),
          child: Text(
            'NVDA: target +6.2% · stop −3.1% · projected win rate ~58%. Per \$1,000 after costs.',
            style: mpBody(12.5),
          ),
        ),
      ],
    ),
  );
}

class _AcademyPanel extends StatelessWidget {
  const _AcademyPanel();

  @override
  Widget build(BuildContext context) => _Panel(
    head: 'Drill · breakout · level 4',
    trail: 'Stop −2.0% · Target +5.0%',
    child: Column(
      children: [
        SizedBox(
          height: 190,
          width: double.infinity,
          child: CustomPaint(painter: _CandlesPainter()),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 1; i <= 8; i++)
              Expanded(
                child: Container(
                  height: 36,
                  margin: EdgeInsets.only(right: i == 8 ? 0 : 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i <= 3 ? const Color(0xFF0F3426) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: i <= 3
                          ? const Color(0xFF14543B)
                          : i == 4
                          ? MPColors.pulse
                          : MPColors.rule,
                    ),
                  ),
                  child: Text(
                    '$i',
                    style: mpBody(
                      12,
                      color: i <= 3
                          ? MPColors.pulse
                          : i == 4
                          ? MPColors.text
                          : MPColors.mute,
                      weight: FontWeight.w700,
                    ).copyWith(height: 1),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _CandlesPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final target = s.height * .22, stop = s.height * .8;
    void dash(double y, Color col) {
      final p = Paint()
        ..color = col.withValues(alpha: .7)
        ..strokeWidth = 1.2;
      for (double x = 0; x < s.width; x += 10) {
        c.drawLine(Offset(x, y), Offset(x + 5, y), p);
      }
    }

    dash(target, MPColors.pulse);
    dash(stop, MPColors.down);
    // (open, close) as fractions of height; a rising run, then the hidden future.
    const bars = [
      (.72, .66),
      (.66, .7),
      (.7, .62),
      (.62, .66),
      (.66, .56),
      (.56, .6),
      (.6, .5),
      (.5, .54),
      (.54, .46),
    ];
    final w = s.width * .62 / bars.length;
    for (var i = 0; i < bars.length; i++) {
      final up = bars[i].$2 < bars[i].$1;
      final col = up ? MPColors.pulse : MPColors.down;
      final x = i * w + w / 2;
      final top = s.height * (up ? bars[i].$2 : bars[i].$1),
          bot = s.height * (up ? bars[i].$1 : bars[i].$2);
      c.drawLine(
        Offset(x, top - 8),
        Offset(x, bot + 8),
        Paint()
          ..color = MPColors.mute
          ..strokeWidth = 1.4,
      );
      c.drawRect(
        Rect.fromLTWH(x - w * .3, top, w * .6, (bot - top).clamp(3, 99)),
        Paint()..color = col,
      );
    }
    final fog = Rect.fromLTWH(s.width * .66, 0, s.width * .34, s.height);
    c.drawRect(fog, Paint()..color = MPColors.ground.withValues(alpha: .9));
    final tp = TextPainter(
      text: TextSpan(text: 'future hidden', style: mpBody(11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      c,
      Offset(fog.center.dx - tp.width / 2, s.height / 2 - tp.height / 2),
    );
    void lab(String t, Color col, double y) {
      final p = TextPainter(
        text: TextSpan(
          text: t,
          style: mpBody(10.5, color: col, weight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p.paint(c, Offset(4, y));
    }

    lab('TARGET', MPColors.pulse, target - 16);
    lab('STOP', MPColors.down, stop + 4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Cta extends StatelessWidget {
  const _Cta();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 88),
    padding: const EdgeInsets.only(top: 80),
    width: double.infinity,
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: MPColors.rule)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text('Want it all on a big screen?', style: mpTitle(40)),
        ),
        const SizedBox(height: 22),
        _Btn(
          'Open my console',
          onTap: () => context.go('/marketpulse/personal'),
        ),
      ],
    ),
  );
}

class _Disclosure extends StatelessWidget {
  const _Disclosure();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(top: 20),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: MPColors.rule)),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Text(
        'Signals and scenarios are model output, not investment advice. '
        'Prices come from an unofficial public feed and can be wrong or late.',
        style: mpBody(13),
      ),
    ),
  );
}

class _HeatmapPanel extends StatelessWidget {
  const _HeatmapPanel();

  // (label, share, day change %) — sample values, sized like the app's sectors.
  static const _tiles = [
    ('Technology', 32.0, 1.4),
    ('Financials', 13.0, 0.4),
    ('Communication', 10.0, 0.9),
    ('Consumer Disc.', 10.5, -0.6),
    ('Health Care', 9.5, -0.3),
    ('Industrials', 8.5, 0.2),
    ('Staples', 5.5, -0.1),
    ('Energy', 3.0, -1.8),
  ];

  @override
  Widget build(BuildContext context) => _Panel(
    head: 'Heatmap · sectors',
    trail: 'Sample day',
    child: Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final t in _tiles)
          Container(
            width: (t.$2 / 32 * 150).clamp(96, 260),
            height: 74,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (t.$3 >= 0 ? MPColors.pulse : MPColors.down).withValues(
                alpha: (.14 + t.$3.abs() / 2.2 * .5).clamp(.14, .6),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.$1,
                  style: mpBody(
                    12,
                    color: MPColors.text,
                    weight: FontWeight.w600,
                  ).copyWith(height: 1.2),
                ),
                const Spacer(),
                Text(
                  '${t.$3 >= 0 ? '+' : '−'}${t.$3.abs().toStringAsFixed(1)}%',
                  style: mpBody(12, color: MPColors.text).copyWith(height: 1),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
