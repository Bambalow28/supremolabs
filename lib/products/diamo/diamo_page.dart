// THESIS: /diamo is the app's own nursery mobile — felt charms hanging from a
// brass arm, swaying, one per memory — so a mom sees what opening the app
// feels like before she installs it.
// OWN-WORLD: the app's Dusk palette (indigo sky, five felt colours, brass
// string) and its Bricolage display voice, ported from app_theme.dart and
// widgets/charm.dart. The charms, sway and drop-in are the app's own.
// STORY: a tired mom lands here, taps a charm and it swings; the page reads
// as warm and low-pressure, and ends on one clear ask: join the TestFlight.
// FIRST VIEWPORT: the mobile drops in charm by charm beside the headline.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/site_shell.dart';
import 'charm.dart';
import 'dm_colors.dart';

final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'DiaMo TestFlight access'},
);

TextStyle _display(
  double size, {
  FontWeight weight = FontWeight.w800,
  Color color = DM.ink,
}) => GoogleFonts.bricolageGrotesque(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 1.02,
  letterSpacing: -0.03 * size,
);

TextStyle _body(double size, {Color color = DM.muted, bool bold = false}) =>
    GoogleFonts.hankenGrotesk(
      fontSize: size,
      color: color,
      height: 1.55,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );

class DiaMoPage extends StatefulWidget {
  final String? initialSection;
  const DiaMoPage({super.key, this.initialSection});

  @override
  State<DiaMoPage> createState() => _DiaMoPageState();
}

class _DiaMoPageState extends State<DiaMoPage> {
  final _howKey = GlobalKey();
  final _discoverKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final pad = isWide ? 64.0 : 22.0;
    switch (widget.initialSection) {
      case 'diary':
        scrollToSection(_howKey);
      case 'discover':
        scrollToSection(_discoverKey);
    }
    Widget section(Widget child, {Key? key, double top = 0}) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Padding(
          key: key,
          padding: EdgeInsets.fromLTRB(pad, top, pad, 0),
          child: child,
        ),
      ),
    );

    return SiteShell(
      ground: DM.background,
      children: [
        // The app's sky: a warm glow at the top fading to the deep tone.
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.1),
              radius: 1.35,
              colors: [DM.highlight, DM.background, DM.deep],
              stops: [0, 0.55, 1],
            ),
          ),
          child: Column(
            children: [
              section(_Hero(isWide: isWide), top: isWide ? 48 : 28),
              SizedBox(height: isWide ? 96 : 64),
              section(_How(isWide: isWide), key: _howKey),
              SizedBox(height: isWide ? 104 : 72),
              section(_Discover(isWide: isWide), key: _discoverKey),
              SizedBox(height: isWide ? 104 : 72),
              section(_Calm(isWide: isWide)),
              SizedBox(height: isWide ? 104 : 72),
              section(_Close(isWide: isWide)),
              SizedBox(height: isWide ? 112 : 80),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BABY DIARY FOR MOMS',
          style: _body(
            12,
            color: DM.butter,
            bold: true,
          ).copyWith(letterSpacing: 2.2),
        ),
        const SizedBox(height: 18),
        Text('Every first,\nkept.', style: _display(isWide ? 84 : 52)),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            'Hang a charm for every giggle, first step and tiny win. Thirty '
            "seconds, one hand, any hour — and your baby's whole story grows "
            'into a mobile you can watch sway.',
            style: _body(isWide ? 18 : 16.5),
          ),
        ),
        const SizedBox(height: 30),
        const _JoinButton(),
        const SizedBox(height: 14),
        Text('On iPhone, through TestFlight.', style: _body(13.5)),
      ],
    );
    const stage = _Mobile();
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [copy, const SizedBox(height: 36), stage],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: copy),
        const SizedBox(width: 48),
        const Expanded(flex: 5, child: stage),
      ],
    );
  }
}

class _Slot {
  final double cx, string, size;
  final CharmKind kind;
  final String label;
  const _Slot(this.cx, this.string, this.size, this.kind, this.label);
}

// Where each charm hangs, as a fraction of the stage width — the app's slots.
const _slots = [
  _Slot(0.15, 70, 76, CharmKind.star, 'First giggle'),
  _Slot(0.333, 150, 68, CharmKind.cloud, 'Slept through'),
  _Slot(0.5, 34, 74, CharmKind.sun, 'Mia'),
  _Slot(0.695, 120, 70, CharmKind.moon, 'First steps'),
  _Slot(0.84, 58, 56, CharmKind.leaf, 'Tried peas'),
];

/// The app's mobile: a brass arm with charms hanging from it. Tap one to
/// swing it.
class _Mobile extends StatelessWidget {
  const _Mobile();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'A baby mobile with five hanging felt charms',
      child: SizedBox(
        height: 320,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _ArmPainter(w / 2)),
                ),
                for (var i = 0; i < _slots.length; i++)
                  Positioned(
                    left: _slots[i].cx * w - 42,
                    top: 18,
                    width: 84,
                    child: HangingCharm(
                      kind: _slots[i].kind,
                      size: _slots[i].size,
                      string: _slots[i].string,
                      index: i,
                      label: _slots[i].label,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArmPainter extends CustomPainter {
  final double hubX;
  const _ArmPainter(this.hubX);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = DM.brass
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final inset = size.width * 44 / 390;
    canvas.drawLine(Offset(hubX, 0), Offset(hubX, 18), p);
    canvas.drawLine(Offset(inset, 18), Offset(size.width - inset, 18), p);
    canvas.drawCircle(Offset(hubX, 18), 5.5, Paint()..color = DM.brass);
  }

  @override
  bool shouldRepaint(_ArmPainter old) => old.hubX != hubX;
}

// ─── How it works ────────────────────────────────────────────────────────────

class _Step {
  final CharmKind kind;
  final String title;
  final String body;
  const _Step(this.kind, this.title, this.body);
}

const _steps = [
  _Step(
    CharmKind.star,
    'Hang a moment',
    'A photo, a few words, a milestone. Pick a charm and it joins the mobile — '
        'no forms, no fuss.',
  ),
  _Step(
    CharmKind.moon,
    'Watch it fill',
    'Each memory is a charm that sways in its own time. A little streak keeps '
        'you company without ever nagging.',
  ),
  _Step(
    CharmKind.leaf,
    'Share if you like',
    'Everything is private until you choose otherwise. Share a moment and '
        'other moms can see how you did it.',
  ),
];

/// Three equal cards across on wide screens, stacked on narrow ones.
Widget _cardRow(bool isWide, List<Widget> cards) {
  if (!isWide) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          cards[i],
        ],
      ],
    );
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < cards.length; i++) ...[
        if (i > 0) const SizedBox(width: 20),
        Expanded(child: cards[i]),
      ],
    ],
  );
}

class _How extends StatelessWidget {
  final bool isWide;
  const _How({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Made for tired hands.', style: _display(isWide ? 48 : 34)),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Newborn days are long and your hands are full. DiaMo keeps up.',
            style: _body(16.5),
          ),
        ),
        SizedBox(height: isWide ? 48 : 32),
        _cardRow(isWide, [
          for (var i = 0; i < _steps.length; i++)
            _StepCard(step: _steps[i], index: i),
        ]),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _Step step;
  final int index;
  const _StepCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
      decoration: BoxDecoration(
        color: DM.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DM.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Sway(
                phase: index * 0.3,
                degrees: 8,
                child: Charm(step.kind, size: 52),
              ),
              const Spacer(),
              Text('0${index + 1}', style: _display(22, color: DM.muted)),
            ],
          ),
          const SizedBox(height: 18),
          Text(step.title, style: _display(26, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(step.body, style: _body(15)),
        ],
      ),
    );
  }
}

// ─── Discover ────────────────────────────────────────────────────────────────

class _Sample {
  final CharmKind kind;
  final String who;
  final String line;
  const _Sample(this.kind, this.who, this.line);
}

const _samples = [
  _Sample(
    CharmKind.sun,
    'Priya · Leo, 7 months',
    'Baby-led weaning: avocado first, and a very large bib.',
  ),
  _Sample(
    CharmKind.cloud,
    'Dani · Ruth, 3 weeks',
    'The 3am playlist that finally got her back to sleep.',
  ),
  _Sample(
    CharmKind.star,
    'Amara · Kofi, 11 months',
    'Crawling happened overnight. Furniture is no longer safe.',
  ),
];

class _Discover extends StatelessWidget {
  final bool isWide;
  const _Discover({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("You're not doing this alone.", style: _display(isWide ? 48 : 34)),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Discover is a warm feed of moments other moms chose to share — '
            'ideas, reassurance, no scoreboard.',
            style: _body(16.5),
          ),
        ),
        SizedBox(height: isWide ? 44 : 28),
        _cardRow(isWide, [
          for (var i = 0; i < _samples.length; i++)
            _SampleCard(sample: _samples[i], index: i),
        ]),
        const SizedBox(height: 16),
        Text('Sample moments, shown for illustration.', style: _body(12.5)),
      ],
    );
  }
}

class _SampleCard extends StatelessWidget {
  final _Sample sample;
  final int index;
  const _SampleCard({required this.sample, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: DM.elevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DM.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sway(
            phase: 0.2 + index * 0.27,
            degrees: 7,
            child: Charm(sample.kind, size: 44),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sample.who, style: _body(13, color: DM.ink, bold: true)),
                const SizedBox(height: 6),
                Text(sample.line, style: _body(15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Calm assurances ─────────────────────────────────────────────────────────

class _Calm extends StatelessWidget {
  final bool isWide;
  const _Calm({required this.isWide});

  static const _items = [
    (CharmKind.moon, 'Light and dark', 'Easy on tired eyes at the 3am feed.'),
    (CharmKind.sun, 'One-handed', 'Everything within reach of a thumb.'),
    (
      CharmKind.cloud,
      'Private by default',
      'You choose what ever gets shared.',
    ),
    (
      CharmKind.leaf,
      'Built for iPhone',
      'Made for the phone already in your hand.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = isWide ? 4 : 1;
        const gap = 40.0;
        final w = (box.maxWidth - gap * (cols - 1)) / cols - 0.5;
        return Wrap(
          spacing: gap,
          runSpacing: 28,
          children: [
            for (final it in _items)
              SizedBox(
                width: w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Charm(it.$1, size: 34),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.$2,
                            style: _body(16, color: DM.ink, bold: true),
                          ),
                          const SizedBox(height: 2),
                          Text(it.$3, style: _body(14.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Close ───────────────────────────────────────────────────────────────────

class _Close extends StatelessWidget {
  final bool isWide;
  const _Close({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 26,
        vertical: isWide ? 64 : 40,
      ),
      decoration: BoxDecoration(
        color: DM.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: DM.border),
      ),
      child: Column(
        children: [
          Text(
            'Be one of the first moms\nto hang a charm.',
            textAlign: TextAlign.center,
            style: _display(isWide ? 44 : 30),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              "DiaMo is in TestFlight on iPhone. Ask for a build and you'll "
              'get an invite to try it before anyone else.',
              textAlign: TextAlign.center,
              style: _body(16),
            ),
          ),
          const SizedBox(height: 28),
          const _JoinButton(),
        ],
      ),
    );
  }
}

class _JoinButton extends StatefulWidget {
  const _JoinButton();

  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: 'Request DiaMo TestFlight access by email',
        child: GestureDetector(
          onTap: () => launchUrl(_betaMailto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFFFFDE85) : DM.butter,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Join the TestFlight',
                  style: _body(16, color: DM.onFelt, bold: true),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: DM.onFelt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
