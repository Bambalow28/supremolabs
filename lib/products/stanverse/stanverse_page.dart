// THESIS: /stanverse is a ticket printing at the door of a world you're
// about to enter — it refuses the generic hero-plus-feature-grid every
// community app ships, and puts the app's own name (Stan Ticker) to work as
// an actual running ticker, not just a label.
// OWN-WORLD: dark stage ground (#0E0D10), paper ticket stock (#F5F2EC),
// uppercase tracked mono labels — ported straight from
// stanverse/lib/theme/stanverse_theme.dart's StanTicker. Perforated tear
// line splits the one ticket into its two halves; no gradients or glass.
// STORY: a visitor watches the live ticker of real worlds scroll by, then a
// ticket prints in and tears open along its perforation into Community and
// Marketplace. They believe every artist already has a running world here
// and pick one.
// FIRST VIEWPORT: ticker banner top, then the ticket prints upward into
// place and tears open — the page's one authored moment.
// FORM: torn-ticket, ported OWN-WORLD candidate, seed key stanverse-9c1e.
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/site_shell.dart';
import 'sv_colors.dart';

final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'Stanverse TestFlight access'},
);

class StanversePage extends StatefulWidget {
  final String? initialSection;
  const StanversePage({super.key, this.initialSection});

  @override
  State<StanversePage> createState() => _StanversePageState();
}

class _StanversePageState extends State<StanversePage>
    with TickerProviderStateMixin {
  final _communityKey = GlobalKey();
  final _marketplaceKey = GlobalKey();

  // The page's one authored moment: the ticket prints up from the bottom,
  // then tears open along its perforation. Nothing else animates on load.
  late final AnimationController _print = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _printIn = CurvedAnimation(
    parent: _print,
    curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _tear = CurvedAnimation(
    parent: _print,
    curve: const Interval(0.55, 1, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _print.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    switch (widget.initialSection) {
      case 'community':
        scrollToSection(_communityKey);
      case 'marketplace':
        scrollToSection(_marketplaceKey);
    }

    return SiteShell(
      ground: SVColors.ink,
      children: [
        _LiveTicker(vsync: this),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 64 : 22,
                isWide ? 56 : 36,
                isWide ? 64 : 22,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Headline(isWide: isWide, entrance: _printIn),
                  SizedBox(height: isWide ? 56 : 36),
                  _PrintedTicket(
                    isWide: isWide,
                    printIn: _printIn,
                    tear: _tear,
                    communityKey: _communityKey,
                    marketplaceKey: _marketplaceKey,
                  ),
                  SizedBox(height: isWide ? 56 : 36),
                  _WorldChips(isWide: isWide),
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

// ─── Live ticker ─────────────────────────────────────────────────────────────

const _chipWidth = 220.0;

/// A genuinely running ticker of live worlds — Stan Ticker's own name put to
/// work, not a static banner. Loops seamlessly: three copies of the world
/// list scroll left, and the offset wraps by exactly one copy's width so the
/// seam never shows.
class _LiveTicker extends StatefulWidget {
  final TickerProvider vsync;
  const _LiveTicker({required this.vsync});

  @override
  State<_LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<_LiveTicker> {
  final _controller = ScrollController();
  late final Ticker _ticker;
  final _contentWidth = _chipWidth * svWorlds.length;

  @override
  void initState() {
    super.initState();
    _ticker = widget.vsync.createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    if (!_controller.hasClients) return;
    const pxPerSecond = 36.0;
    final offset =
        (elapsed.inMilliseconds / 1000) * pxPerSecond % _contentWidth;
    _controller.jumpTo(offset);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SVColors.paper,
      height: 40,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: svWorlds.length * 3,
        itemBuilder: (context, i) {
          final w = svWorlds[i % svWorlds.length];
          return SizedBox(
            width: _chipWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: w.color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  w.name,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: SVColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${w.liveCount} LIVE',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: SVColors.mono,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Headline ────────────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  final bool isWide;
  final Animation<double> entrance;
  const _Headline({required this.isWide, required this.entrance});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: entrance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR FANDOM',
            style: GoogleFonts.ibmPlexMono(
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: SVColors.mono,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Live.',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 0.95,
              fontSize: isWide ? 88 : 54,
              color: SVColors.paper,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              'Every artist gets a world: a board, a marketplace, and a calendar of '
              'dates — one ticket admits you to all three.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: isWide ? 16 : 14,
                color: SVColors.mono,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── The printed, torn ticket ─────────────────────────────────────────────────

class _PrintedTicket extends StatelessWidget {
  final bool isWide;
  final Animation<double> printIn;
  final Animation<double> tear;
  final GlobalKey communityKey;
  final GlobalKey marketplaceKey;
  const _PrintedTicket({
    required this.isWide,
    required this.printIn,
    required this.tear,
    required this.communityKey,
    required this.marketplaceKey,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: printIn,
      builder: (context, child) {
        // Prints up from the bottom edge, like a receipt printer, rather
        // than a plain fade.
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: printIn.value.clamp(0.0001, 1),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: tear,
        builder: (context, child) {
          // The two halves separate slightly along the perforation once the
          // ticket has finished printing in.
          final gap = 10 * tear.value;
          final community = KeyedSubtree(
            key: communityKey,
            child: _TicketHalf(
              label: 'COMMUNITY',
              title: 'One board\nper world.',
              body:
                  'Pin posts, trade takes, keep the timeline that matters to a '
                  "fandom out of a feed that doesn't.",
              isWide: isWide,
            ),
          );
          final marketplace = KeyedSubtree(
            key: marketplaceKey,
            child: _TicketHalf(
              label: 'MARKETPLACE',
              title: 'Merch, direct\nfrom fans.',
              body:
                  'List, browse, and check out fan-made and official merch '
                  "inside the world it belongs to, not a storefront that isn't.",
              isWide: isWide,
            ),
          );
          if (!isWide) {
            return Column(
              children: [
                Transform.translate(
                  offset: Offset(0, -gap / 2),
                  child: community,
                ),
                _Perforation(axis: Axis.horizontal),
                Transform.translate(
                  offset: Offset(0, gap / 2),
                  child: marketplace,
                ),
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Transform.translate(
                    offset: Offset(-gap / 2, 0),
                    child: community,
                  ),
                ),
                const _Perforation(axis: Axis.vertical),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(gap / 2, 0),
                    child: marketplace,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  final Axis axis;
  const _Perforation({required this.axis});

  @override
  Widget build(BuildContext context) {
    final dashes = List.generate(
      18,
      (_) => axis == Axis.vertical
          ? Container(
              width: 2,
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 3),
              color: SVColors.ink.withValues(alpha: 0.2),
            )
          : Container(
              width: 6,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: SVColors.ink.withValues(alpha: 0.2),
            ),
    );
    return SizedBox(
      width: axis == Axis.vertical ? 20 : double.infinity,
      height: axis == Axis.vertical ? null : 20,
      child: axis == Axis.vertical
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dashes,
            )
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: dashes),
    );
  }
}

class _TicketHalf extends StatelessWidget {
  final String label;
  final String title;
  final String body;
  final bool isWide;
  const _TicketHalf({
    required this.label,
    required this.title,
    required this.body,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SVColors.paper,
      padding: EdgeInsets.all(isWide ? 32 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: SVColors.mono,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: isWide ? 28 : 22,
              color: SVColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13.5,
              color: SVColors.ink.withValues(alpha: 0.72),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── World chips ─────────────────────────────────────────────────────────────

class _WorldChips extends StatelessWidget {
  final bool isWide;
  const _WorldChips({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORLDS ALREADY LIVE',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final w in svWorlds) _WorldChip(world: w)],
        ),
      ],
    );
  }
}

class _WorldChip extends StatefulWidget {
  final SVWorld world;
  const _WorldChip({required this.world});

  @override
  State<_WorldChip> createState() => _WorldChipState();
}

class _WorldChipState extends State<_WorldChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: _hover ? widget.world.color : SVColors.line,
            width: _hover ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.world.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.world.name,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 12,
                color: SVColors.paper,
                fontWeight: FontWeight.w600,
              ),
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
        Container(height: 1, color: SVColors.line),
        SizedBox(height: isWide ? 40 : 30),
        Text(
          'Stanverse is in TestFlight.',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isWide ? 34 : 26,
            color: SVColors.paper,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'No App Store listing yet — the iOS beta is running now. Ask for a '
            'build and we’ll add you to the tester list.',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13.5,
              color: SVColors.mono,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: _RequestAccessButton(),
        ),
      ],
    );
  }
}

class _RequestAccessButton extends StatefulWidget {
  const _RequestAccessButton();

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
        label: 'Request Stanverse TestFlight access by email',
        child: GestureDetector(
          onTap: () => launchUrl(_betaMailto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _hover ? SVColors.paper : Colors.transparent,
              border: Border.all(color: SVColors.paper, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REQUEST ACCESS',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: _hover ? SVColors.ink : SVColors.paper,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: _hover ? SVColors.ink : SVColors.paper,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
