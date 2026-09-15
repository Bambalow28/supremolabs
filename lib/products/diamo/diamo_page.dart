// THESIS: /diamo is a baby book pulled off the shelf and opened to today's
// page, not a feed of cards — it refuses the generic hero-plus-icon-grid
// every diary app ships.
// OWN-WORLD: Diamo's own dark rose stock (#1C1216 ground, #291A20/#34222A
// surfaces, #7A3145 seed) ported straight from app_theme.dart. Lora italic
// for the one thing a parent wrote by hand, IBM Plex Sans for everything the
// app prints. Fanned page tabs, a deckled diary-page edge, corkboard pins on
// the Discover cards — no gradients, no icon tiles.
// STORY: a visitor sees the shelf of dated pages a family has already kept,
// watches it fan open to today's entry, then the corkboard of other
// families' firsts. They believe Diamo already holds a life in progress and
// ask to join the beta.
// FIRST VIEWPORT: the spine of pages fans open on load — the book's one
// authored moment — settling with today's page in front, headline beside it.
// FORM: keepsake-shelf, ported OWN-WORLD candidate, seed key diamo-2a7f.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/site_shell.dart';

final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'Diamo TestFlight access'},
);

class DiaMoColors {
  DiaMoColors._();
  static const ground = Color(0xFF1C1216);
  static const surface = Color(0xFF291A20);
  static const surfaceHigh = Color(0xFF34222A);
  static const accent = Color(0xFF7A3145); // diaMoTheme seed color
  static const accentBright = Color(0xFFC97E93);
  static const ink = Color(0xFFF3E4E7);
  static const inkMuted = Color(0xFFC9A8B0);
  static const hairline = Color(0x33F3E4E7);
}

class _Page {
  final String date;
  final String tag;
  final String title;
  final String note;
  const _Page(this.date, this.tag, this.title, this.note);
}

const _shelf = <_Page>[
  _Page(
    'MAR 02',
    'Milestone',
    'First steps',
    'Three all on her own, then sat right down laughing.',
  ),
  _Page(
    'FEB 14',
    'Note',
    'Sleeps through the night',
    'Six hours straight for the first time. We both cried a little.',
  ),
  _Page(
    'JAN 30',
    'Milestone',
    'First word',
    '"Up." Said to the dog, not to either of us.',
  ),
];

class _Pinned {
  final String family;
  final String caption;
  final Color tint;
  const _Pinned(this.family, this.caption, this.tint);
}

const _corkboard = <_Pinned>[
  _Pinned(
    'The Alaniz family',
    'First haircut — braver than his dad.',
    Color(0xFFB6798C),
  ),
  _Pinned(
    'The Osei family',
    'First time swimming, unassisted.',
    Color(0xFF8C5C6E),
  ),
  _Pinned(
    'The Park family',
    'First birthday, cake and all.',
    Color(0xFFCB93A2),
  ),
];

class DiaMoPage extends StatefulWidget {
  final String? initialSection;
  const DiaMoPage({super.key, this.initialSection});

  @override
  State<DiaMoPage> createState() => _DiaMoPageState();
}

class _DiaMoPageState extends State<DiaMoPage>
    with SingleTickerProviderStateMixin {
  final _diaryKey = GlobalKey();
  final _discoverKey = GlobalKey();

  // The page's one authored moment: the shelf fans open once, page by page,
  // like a hand riffling through a kept book. Nothing else animates on load.
  late final AnimationController _fan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  Animation<double> _page(int order) => CurvedAnimation(
    parent: _fan,
    curve: Interval(
      order * 0.16,
      (order * 0.16 + 0.6).clamp(0, 1),
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _fan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final pad = isWide ? 64.0 : 22.0;
    switch (widget.initialSection) {
      case 'diary':
        scrollToSection(_diaryKey);
      case 'discover':
        scrollToSection(_discoverKey);
    }

    return SiteShell(
      ground: DiaMoColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, isWide ? 56 : 36, pad, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Headline(isWide: isWide),
                  SizedBox(height: isWide ? 56 : 36),
                  KeyedSubtree(
                    key: _diaryKey,
                    child: _Shelf(isWide: isWide, page: _page),
                  ),
                  SizedBox(height: isWide ? 72 : 48),
                  KeyedSubtree(
                    key: _discoverKey,
                    child: _Corkboard(isWide: isWide, entrance: _page(2)),
                  ),
                  SizedBox(height: isWide ? 72 : 48),
                  _Close(isWide: isWide),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Headline ────────────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  final bool isWide;
  const _Headline({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final headline = Text(
      'Every first,\nkept.',
      style: GoogleFonts.lora(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: isWide ? 64 : 38,
        color: DiaMoColors.ink,
        height: 1.08,
      ),
    );
    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 46, height: 2, color: DiaMoColors.accentBright),
        const SizedBox(height: 18),
        Text(
          'The words, the steps, the tooth that finally came in — logged the '
          'day they happen, private by default, kept in one book instead of '
          'six camera rolls.',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            color: DiaMoColors.inkMuted,
            height: 1.75,
          ),
        ),
      ],
    );
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [headline, const SizedBox(height: 24), aside],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 6, child: headline),
        const SizedBox(width: 48),
        Expanded(flex: 5, child: aside),
      ],
    );
  }
}

// ─── The shelf ───────────────────────────────────────────────────────────────

/// The kept book: a fan of dated pages, tabs peeking out behind the one in
/// front. Each page rotates and slides into the stack on the page's one
/// authored entrance — see `_fan` above.
class _Shelf extends StatelessWidget {
  final bool isWide;
  final Animation<double> Function(int) page;
  const _Shelf({required this.isWide, required this.page});

  @override
  Widget build(BuildContext context) {
    final height = isWide ? 420.0 : 340.0;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          for (var i = _shelf.length - 1; i >= 0; i--)
            _FannedPage(
              entry: _shelf[i],
              order: i,
              total: _shelf.length,
              isWide: isWide,
              entrance: page(i),
            ),
        ],
      ),
    );
  }
}

class _FannedPage extends StatelessWidget {
  final _Page entry;
  final int order;
  final int total;
  final bool isWide;
  final Animation<double> entrance;
  const _FannedPage({
    required this.entry,
    required this.order,
    required this.total,
    required this.isWide,
    required this.entrance,
  });

  @override
  Widget build(BuildContext context) {
    final isFront = order == 0;
    // Pages behind the front one peek out lower and further rotated, like a
    // hand of cards fanned from a spine — depth from stacking order alone,
    // no shadow gimmick.
    final restRotation = -0.06 - order * 0.05;
    final restOffsetY = order * 26.0;
    final restOffsetX = order * 14.0;

    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = entrance.value;
        // Enters from further behind and flatter, settles into its resting
        // fan position — the riffle motion, not a plain fade.
        final rotation = Tween(
          begin: restRotation * 2.4,
          end: restRotation,
        ).transform(t);
        final dy = Tween(
          begin: restOffsetY - 40,
          end: restOffsetY,
        ).transform(t);
        final dx = Tween(
          begin: restOffsetX + (isFront ? 0 : 30),
          end: restOffsetX,
        ).transform(t);
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(angle: rotation, child: child),
          ),
        );
      },
      child: SizedBox(
        width: isWide ? 560 : double.infinity,
        child: _PageCard(entry: entry, dimmed: !isFront, isWide: isWide),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final _Page entry;
  final bool dimmed;
  final bool isWide;
  const _PageCard({
    required this.entry,
    required this.dimmed,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(isWide ? 36 : 24, 22, isWide ? 36 : 24, 26),
      decoration: BoxDecoration(
        color: dimmed ? DiaMoColors.surface : DiaMoColors.surfaceHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: DiaMoColors.hairline),
      ),
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deckled top edge — a diary page's torn line, not a rule.
            SizedBox(
              height: 6,
              child: CustomPaint(
                painter: _DeckleEdge(color: DiaMoColors.accent),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  entry.date,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                    color: DiaMoColors.inkMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DiaMoColors.accent.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.tag.toUpperCase(),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: DiaMoColors.accentBright,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              entry.title,
              style: GoogleFonts.lora(
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: isWide ? 30 : 24,
                color: DiaMoColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.note,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                color: DiaMoColors.inkMuted,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dashed, slightly irregular top edge — cheaper and truer to a torn diary
/// page than a straight rule would be.
class _DeckleEdge extends CustomPainter {
  final Color color;
  const _DeckleEdge({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 7.0, gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dash, size.height / 2),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DeckleEdge oldDelegate) =>
      oldDelegate.color != color;
}

// ─── Discover corkboard ───────────────────────────────────────────────────────

class _Corkboard extends StatelessWidget {
  final bool isWide;
  final Animation<double> entrance;
  const _Corkboard({required this.isWide, required this.entrance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Discover',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
                color: DiaMoColors.inkMuted,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 1, color: DiaMoColors.hairline)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Other families keeping their own book, pinned where you can see them.',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13.5,
            color: DiaMoColors.inkMuted,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: entrance,
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              for (var i = 0; i < _corkboard.length; i++)
                _PinnedCard(
                  pinned: _corkboard[i],
                  tilt: (i.isEven ? -1 : 1) * (2.0 + i),
                  isWide: isWide,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PinnedCard extends StatefulWidget {
  final _Pinned pinned;
  final double tilt;
  final bool isWide;
  const _PinnedCard({
    required this.pinned,
    required this.tilt,
    required this.isWide,
  });

  @override
  State<_PinnedCard> createState() => _PinnedCardState();
}

class _PinnedCardState extends State<_PinnedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.isWide ? 280.0 : double.infinity;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..rotateZ((_hover ? 0 : widget.tilt) * 3.14159 / 180)
          ..translateByDouble(0.0, _hover ? -6.0 : 0.0, 0.0, 1.0),
        transformAlignment: Alignment.center,
        width: width,
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
        decoration: BoxDecoration(
          color: DiaMoColors.surface,
          border: Border.all(
            color: _hover ? widget.pinned.tint : DiaMoColors.hairline,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -34,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.pinned.tint,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.pinned.tint.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.pinned.family,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DiaMoColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pinned.caption,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: DiaMoColors.inkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Close ───────────────────────────────────────────────────────────────────

class _Close extends StatelessWidget {
  final bool isWide;
  const _Close({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: DiaMoColors.hairline),
        SizedBox(height: isWide ? 40 : 30),
        Text(
          'Diamo is in TestFlight.',
          style: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            fontSize: isWide ? 36 : 28,
            color: DiaMoColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'No App Store listing yet — the iOS beta is running now. Ask for '
            'a build and we’ll add you to the tester list.',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13.5,
              color: DiaMoColors.inkMuted,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerLeft, child: _RequestAccessButton()),
      ],
    );
  }
}

class _RequestAccessButton extends StatefulWidget {
  @override
  State<_RequestAccessButton> createState() => _RequestAccessButtonState();
}

class _RequestAccessButtonState extends State<_RequestAccessButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: 'Request Diamo TestFlight access by email',
        child: GestureDetector(
          onTap: () => launchUrl(_betaMailto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _hover ? DiaMoColors.accentBright : Colors.transparent,
              border: Border.all(color: DiaMoColors.accentBright, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REQUEST ACCESS',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: _hover
                        ? DiaMoColors.ground
                        : DiaMoColors.accentBright,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: _hover ? DiaMoColors.ground : DiaMoColors.accentBright,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
