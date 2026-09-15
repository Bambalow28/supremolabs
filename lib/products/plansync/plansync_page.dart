// THESIS: /plansync is a trip folder laid open on a desk — one sheet per
// thing PlanSync replaces. It refuses the alternating screenshot-and-copy
// scroll every planner app ships, and refuses the feature-card grid.
// OWN-WORLD: PlanSync's own dark stock (#0A0E14 ground, #121821 sheets),
// teal→emerald ink (#2DD4BF/#34D399) used only for field labels, rules and
// perforations. Crimson Text for the two things a human wrote; Anonymous
// Pro for everything a document prints. Punched binding edges, dashed tear
// lines, rubber-stamped endorsements. Flat panels, hairline edges, no
// gradient text, no icon tiles.
// STORY: a visitor sees the paper a trip normally scatters across email,
// wallet and camera roll — pass, itinerary, receipt tape, place cards,
// attachment sleeve — all filed in one folder with PlanSync on the tab.
// They believe it replaces the folder, and they ask for beta access.
// FIRST VIEWPORT: folder tab top-left, Crimson headline at 64 beside a mono
// route line, then the boarding pass at full width — real fields left, the
// request-access stub past the perforation on the right.
// FORM: travel-document stack, candidate 3 of my ordered structures, surface
// seed key 5a8d7339.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/site_shell.dart';
import 'ps_colors.dart';
import 'widgets/document.dart';

/// Beta access request. PlanSync has no public App Store listing yet, so the
/// page says so rather than pointing at a listing that does not exist.
final _betaMailto = Uri(
  scheme: 'mailto',
  path: 'joshalanis28@gmail.com',
  queryParameters: const {'subject': 'PlanSync TestFlight access'},
);

class PlanSyncPage extends StatefulWidget {
  /// `/plansync/itinerary` and `/plansync/places` scroll to that sheet on
  /// this same folder — real sub-routes, not separate pages.
  final String? initialSection;
  const PlanSyncPage({super.key, this.initialSection});

  @override
  State<PlanSyncPage> createState() => _PlanSyncPageState();
}

class _PlanSyncPageState extends State<PlanSyncPage>
    with SingleTickerProviderStateMixin {
  final _itineraryKey = GlobalKey();
  final _placesKey = GlobalKey();

  // The page's one authored moment: the sheets settle into the folder once,
  // in filing order. Nothing else on the page animates on its own.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  Animation<double> _sheet(int order) => CurvedAnimation(
    parent: _settle,
    curve: Interval(
      order * 0.11,
      (order * 0.11 + 0.5).clamp(0, 1),
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final pad = isWide ? 64.0 : 22.0;
    switch (widget.initialSection) {
      case 'itinerary':
        scrollToSection(_itineraryKey);
      case 'places':
        scrollToSection(_placesKey);
    }

    return SiteShell(
      ground: PSColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, isWide ? 56 : 36, pad, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Headline(isWide: isWide),
                  SizedBox(height: isWide ? 44 : 32),
                  _BoardingPass(isWide: isWide, entrance: _sheet(0)),
                  SizedBox(height: isWide ? 28 : 20),
                  KeyedSubtree(
                    key: _itineraryKey,
                    child: _ItinerarySheet(isWide: isWide, entrance: _sheet(1)),
                  ),
                  SizedBox(height: isWide ? 28 : 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _ReceiptTape(entrance: _sheet(2)),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          flex: 6,
                          child: KeyedSubtree(
                            key: _placesKey,
                            child: _PlacesSheet(entrance: _sheet(3)),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _ReceiptTape(entrance: _sheet(2)),
                    const SizedBox(height: 20),
                    KeyedSubtree(
                      key: _placesKey,
                      child: _PlacesSheet(entrance: _sheet(3)),
                    ),
                  ],
                  SizedBox(height: isWide ? 28 : 20),
                  _AttachmentSleeve(isWide: isWide, entrance: _sheet(4)),
                  SizedBox(height: isWide ? 56 : 40),
                  _Endorsements(isWide: isWide),
                  SizedBox(height: isWide ? 64 : 44),
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

// ─── Folder ──────────────────────────────────────────────────────────────────

/// The tab on the folder everything below is filed in.
class _Headline extends StatelessWidget {
  final bool isWide;
  const _Headline({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final headline = Text(
      'One trip.\nOne folder.',
      style: GoogleFonts.crimsonText(
        fontSize: isWide ? 68 : 42,
        fontWeight: FontWeight.bold,
        color: PSColors.ink,
        height: 1.02,
      ),
    );

    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 46, height: 2, color: PSColors.accent),
        const SizedBox(height: 18),
        Text(
          'Itinerary, places, expenses, attachments and flights stop living '
          'in six different apps. PlanSync files them under one trip, and '
          'they stay there — on the plane, in the tunnel, offline.',
          style: GoogleFonts.anonymousPro(
            fontSize: 14,
            color: PSColors.inkSecondary,
            height: 1.75,
          ),
        ),
      ],
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [headline, const SizedBox(height: 26), aside],
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

// ─── Sheet 1 · the pass ──────────────────────────────────────────────────────

class _BoardingPass extends StatelessWidget {
  final bool isWide;
  final Animation<double> entrance;
  const _BoardingPass({required this.isWide, required this.entrance});

  @override
  Widget build(BuildContext context) {
    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            psFieldLabel('Flight lookup'),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 1, color: PSColors.hairline)),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const PSField(label: 'From', value: 'YYZ', valueSize: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Text(
                      'TS 742',
                      style: GoogleFonts.anonymousPro(
                        fontSize: 11,
                        color: PSColors.accent,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const PSPerforation(),
                  ],
                ),
              ),
            ),
            const PSField(
              label: 'To',
              value: 'LIS',
              valueSize: 40,
              align: CrossAxisAlignment.end,
            ),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 44,
          runSpacing: 20,
          children: const [
            PSField(label: 'Departs', value: '14 Sep · 21:40'),
            PSField(label: 'Arrives', value: '15 Sep · 09:25'),
            PSField(label: 'Gate', value: 'D28'),
            PSField(label: 'Seat', value: '17A'),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Type a flight number; PlanSync fills in the rest and pins it to '
          'the right day of the trip.',
          style: GoogleFonts.anonymousPro(
            fontSize: 13,
            color: PSColors.inkMuted,
            height: 1.7,
          ),
        ),
        // IntrinsicHeight measures this column a fraction short of what it
        // lays out to; the slack absorbs the rounding. Wide enough to cover
        // a whole extra wrapped line of the caption above (~22px at this
        // text style), since it wraps a different number of lines at
        // different page widths, not just a rounding pixel.
        const SizedBox(height: 28),
      ],
    );

    final stub = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // `spaceBetween` needs a bounded height to distribute into. The wide
      // layout gives it one (IntrinsicHeight, inside the Row below); the
      // narrow layout stacks it straight into the page's scroll view, which
      // is unbounded — sizing to content there instead of trying to stretch
      // into infinity is what was overflowing this sheet on mobile.
      mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            psFieldLabel('Status'),
            const SizedBox(height: 8),
            psValue('TESTFLIGHT', size: 15, color: PSColors.accentAlt),
            const SizedBox(height: 6),
            Text(
              'Beta, iOS',
              style: GoogleFonts.anonymousPro(
                fontSize: 12,
                color: PSColors.inkMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _RequestAccessButton(),
      ],
    );

    return PSDocument(
      entrance: entrance,
      tilt: -0.35,
      padding: EdgeInsets.fromLTRB(
        isWide ? 48 : 40,
        isWide ? 34 : 26,
        isWide ? 34 : 22,
        isWide ? 34 : 26,
      ),
      child: isWide
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 7, child: main),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26),
                    child: PSPerforation(axis: Axis.vertical),
                  ),
                  // 180 clipped "REQUEST ACCESS →" by ~2px at bold weight —
                  // a hair more room than the button's own content needs.
                  SizedBox(width: 190, child: stub),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                main,
                const SizedBox(height: 24),
                const PSPerforation(),
                const SizedBox(height: 24),
                stub,
              ],
            ),
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
        label: 'Request PlanSync TestFlight access by email',
        child: GestureDetector(
          onTap: () => launchUrl(_betaMailto),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _hover ? PSColors.accent : Colors.transparent,
              border: Border.all(color: PSColors.accent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'REQUEST ACCESS',
                  style: GoogleFonts.anonymousPro(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _hover ? PSColors.ground : PSColors.accent,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: _hover ? PSColors.ground : PSColors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sheet 2 · the itinerary ─────────────────────────────────────────────────

class _ItineraryItem {
  final String time;
  final String title;
  final String note;
  const _ItineraryItem(this.time, this.title, this.note);
}

class _ItinerarySheet extends StatelessWidget {
  final bool isWide;
  final Animation<double> entrance;
  const _ItinerarySheet({required this.isWide, required this.entrance});

  // Illustrative trip data — see the sample notice at the foot of the folder.
  static const _day2 = <_ItineraryItem>[
    _ItineraryItem('09:30', 'Time Out Market', 'Breakfast before the crowd'),
    _ItineraryItem(
      '11:00',
      'Tram 28 · Martim Moniz',
      'Ride to Graça, walk back down',
    ),
    _ItineraryItem(
      '14:15',
      'Miradouro da Senhora do Monte',
      'Best light late afternoon',
    ),
    _ItineraryItem('19:45', 'Taberna da Rua das Flores', 'Booked · 4 people'),
  ];

  @override
  Widget build(BuildContext context) {
    return PSDocument(
      entrance: entrance,
      tilt: 0.28,
      padding: EdgeInsets.fromLTRB(
        isWide ? 48 : 40,
        isWide ? 34 : 26,
        isWide ? 40 : 22,
        isWide ? 34 : 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              psFieldLabel('Itinerary · Day 2 of 5'),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: PSColors.hairline)),
              const SizedBox(width: 10),
              Text(
                'LISBON',
                style: GoogleFonts.anonymousPro(
                  fontSize: 11,
                  color: PSColors.inkMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          for (var i = 0; i < _day2.length; i++)
            _ItineraryRow(
              item: _day2[i],
              isLast: i == _day2.length - 1,
              isWide: isWide,
            ),
          const SizedBox(height: 20),
          Text(
            'Every day is its own page. Drag an item to another day and '
            'everything attached to it — the place, the booking, the receipt '
            '— moves with it.',
            style: GoogleFonts.anonymousPro(
              fontSize: 13,
              color: PSColors.inkMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

/// A timed row on the itinerary, hung off the day's rail. Hovering it lights
/// the rail dot and warms the title — the only motion here beyond the
/// folder's one authored settle, and it only runs on an actual point.
class _ItineraryRow extends StatefulWidget {
  final _ItineraryItem item;
  final bool isLast;
  final bool isWide;
  const _ItineraryRow({
    required this.item,
    required this.isLast,
    required this.isWide,
  });

  @override
  State<_ItineraryRow> createState() => _ItineraryRowState();
}

class _ItineraryRowState extends State<_ItineraryRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isLast = widget.isLast;
    final isWide = widget.isWide;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isWide ? 66 : 56,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  item.time,
                  style: GoogleFonts.anonymousPro(
                    fontSize: 13,
                    color: PSColors.accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            // The day's rail: a mark on the hour, a hairline between hours.
            SizedBox(
              width: 26,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    width: _hover ? 9 : 7,
                    height: _hover ? 9 : 7,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: _hover ? PSColors.accentAlt : PSColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: PSColors.accent.withValues(alpha: 0.28),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      style: GoogleFonts.crimsonText(
                        fontSize: isWide ? 22 : 19,
                        fontWeight: FontWeight.bold,
                        color: _hover ? PSColors.accentAlt : PSColors.ink,
                        height: 1.15,
                      ),
                      child: Text(item.title),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.note,
                      style: GoogleFonts.anonymousPro(
                        fontSize: 12.5,
                        color: PSColors.inkMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet 3 · the receipt tape ──────────────────────────────────────────────

class _ReceiptTape extends StatelessWidget {
  final Animation<double> entrance;
  const _ReceiptTape({required this.entrance});

  static const _lines = <(String, String)>[
    ('Flights', '\$812.40'),
    ('Stays', '\$640.00'),
    ('Food', '\$318.75'),
    ('Transit', '\$86.20'),
    ('Tickets', '\$54.00'),
  ];

  @override
  Widget build(BuildContext context) {
    return PSDocument(
      entrance: entrance,
      tilt: -0.4,
      punched: false,
      color: PSColors.stockLow,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          psFieldLabel('Expenses'),
          const SizedBox(height: 22),
          for (final (label, amount) in _lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.anonymousPro(
                      fontSize: 13.5,
                      color: PSColors.inkSecondary,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(height: 1, color: PSColors.hairline),
                    ),
                  ),
                  Text(
                    amount,
                    style: GoogleFonts.anonymousPro(
                      fontSize: 13.5,
                      color: PSColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          const PSPerforation(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              psFieldLabel('Trip total'),
              psValue('\$1,911.35', size: 24, color: PSColors.accentAlt),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Logged as you go, split by category, totalled per trip.',
            style: GoogleFonts.anonymousPro(
              fontSize: 12.5,
              color: PSColors.inkMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet 4 · pinned places ─────────────────────────────────────────────────

class _PlacesSheet extends StatelessWidget {
  final Animation<double> entrance;
  const _PlacesSheet({required this.entrance});

  static const _places = <(String, String)>[
    ('Belém Tower', 'Av. Brasília · Day 3'),
    ('LX Factory', 'Alcântara · Day 4'),
    ('Pastéis de Belém', 'R. de Belém 84 · Day 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return PSDocument(
      entrance: entrance,
      tilt: 0.3,
      punched: false,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          psFieldLabel('Places'),
          const SizedBox(height: 22),
          for (final (name, where) in _places)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.push_pin_outlined,
                      size: 15,
                      color: PSColors.accent.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.crimsonText(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: PSColors.ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          where,
                          style: GoogleFonts.anonymousPro(
                            fontSize: 12,
                            color: PSColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Search a place, pin it to the day it belongs to, and it carries '
            'its address, hours and map link with it.',
            style: GoogleFonts.anonymousPro(
              fontSize: 12.5,
              color: PSColors.inkMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet 5 · the attachment sleeve ─────────────────────────────────────────

class _AttachmentSleeve extends StatelessWidget {
  final bool isWide;
  final Animation<double> entrance;
  const _AttachmentSleeve({required this.isWide, required this.entrance});

  static const _files = <(String, String)>[
    ('booking-confirmation.pdf', '184 KB'),
    ('rental-agreement.pdf', '96 KB'),
    ('museum-tickets.pdf', '212 KB'),
    ('travel-insurance.pdf', '340 KB'),
  ];

  @override
  Widget build(BuildContext context) {
    return PSDocument(
      entrance: entrance,
      tilt: -0.22,
      padding: EdgeInsets.fromLTRB(isWide ? 48 : 40, 32, isWide ? 40 : 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              psFieldLabel('Attachments'),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: PSColors.hairline)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final (name, size) in _files)
                _AttachmentChip(name: name, size: size),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Confirmations, tickets and agreements live in the trip, not in '
            'your inbox — and they open with no signal.',
            style: GoogleFonts.anonymousPro(
              fontSize: 13,
              color: PSColors.inkMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

/// One filed document in the sleeve. Hovering lifts its border and icon to
/// full accent, like a paper you could actually pull out.
class _AttachmentChip extends StatefulWidget {
  final String name;
  final String size;
  const _AttachmentChip({required this.name, required this.size});

  @override
  State<_AttachmentChip> createState() => _AttachmentChipState();
}

class _AttachmentChipState extends State<_AttachmentChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: PSColors.stockHigh,
          border: Border.all(
            color: _hover ? PSColors.accent : PSColors.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 15,
              color: _hover
                  ? PSColors.accent
                  : PSColors.accent.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: GoogleFonts.anonymousPro(
                fontSize: 12.5,
                color: PSColors.ink,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.size,
              style: GoogleFonts.anonymousPro(
                fontSize: 11,
                color: PSColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Endorsements ────────────────────────────────────────────────────────────

/// What the folder records but does not print: the app's shipped behaviours
/// with no document of their own.
class _Endorsements extends StatelessWidget {
  final bool isWide;
  const _Endorsements({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: const [
            PSStamp(label: 'Export to PDF'),
            PSStamp(label: 'Share a trip', tilt: 3),
            PSStamp(label: 'Works offline', tilt: -2.2),
            PSStamp(label: 'Lock screen live activity', tilt: 2),
          ],
        ),
        SizedBox(height: isWide ? 28 : 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Hand the whole folder to whoever is travelling with you, or '
            'print it flat as a PDF. On the day, the next thing on the '
            'itinerary sits on your lock screen.',
            style: GoogleFonts.anonymousPro(
              fontSize: 13.5,
              color: PSColors.inkSecondary,
              height: 1.8,
            ),
          ),
        ),
      ],
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
        Container(height: 1, color: PSColors.hairline),
        SizedBox(height: isWide ? 40 : 30),
        Text(
          'PlanSync is in TestFlight.',
          style: GoogleFonts.crimsonText(
            fontSize: isWide ? 40 : 30,
            fontWeight: FontWeight.bold,
            color: PSColors.ink,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'No App Store listing yet — the iOS beta is running now. Ask for '
            'a build and we will add you to the tester list.',
            style: GoogleFonts.anonymousPro(
              fontSize: 13.5,
              color: PSColors.inkSecondary,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Align(
          alignment: Alignment.centerLeft,
          child: _RequestAccessButton(),
        ),
        SizedBox(height: isWide ? 48 : 36),
        Text(
          'Trip contents shown above are a sample, not a real itinerary.',
          style: GoogleFonts.anonymousPro(
            fontSize: 11,
            color: PSColors.inkMuted,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
