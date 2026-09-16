// THESIS: /workit shows the app itself. The page used to argue by
// reconstruction — mock readouts standing in for screens nobody had
// captured yet. WorkIt now has real App Store screenshots
// (workit/marketing/), so the spine of this page is five actual screens in
// the app's own frame, and the drawn instruments survive only where a still
// image genuinely can't make the claim: a rest timer that is really
// counting, and a form score that builds itself.
// OWN-WORLD: WorkIt's own near-black (#0B0C0E), surface #1B1C1F, tint
// #4A9DFF, IWF plate colors (red/blue/gold/green) reserved for real
// numbers — mirrored from WorkItColors.dark(), not approximated. System/SF
// text stack, tabular figures on every number, matching the app's own
// Cupertino-driven type. Each screen in the rail is captioned in the color
// that screen actually uses in the app, so the rail reads as one
// instrument with five faces rather than a gallery.
// STORY: the visitor sees that WorkIt is a five-tab app that now covers
// training, form, nutrition and a shared gym — recognizes those screens
// when they open it — and leaves with the App Store listing one tap away.
// FORM: hero with a live session card, the real-screen rail, the one
// capability no screenshot can prove (Form Checker), an instrument readout
// list of what shipped, the on-device promise, Pro, then the App Store close.
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/motion.dart';
import '../../app/site_shell.dart';
import 'wi_colors.dart';

const workItAppStoreUrl =
    'https://apps.apple.com/ca/app/workit-workout-planner/id6797370721';

class WorkItPage extends StatelessWidget {
  /// `/workit/features` and `/workit/screens` scroll to that part of the
  /// page — real sub-routes, not separate pages. `/workit/progress` is the
  /// old name for the screens rail (it used to land on a drawn training-load
  /// chart, now shown as the real Today screen) and is kept alive rather
  /// than left to 404.
  final String? initialSection;
  final _featuresKey = GlobalKey();
  final _screensKey = GlobalKey();

  WorkItPage({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    switch (initialSection) {
      case 'features':
        scrollToSection(_featuresKey);
      case 'screens':
      case 'progress':
        scrollToSection(_screensKey);
    }

    return SiteShell(
      ground: WIColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 0 : 20,
                isWide ? 32 : 20,
                isWide ? 0 : 20,
                80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    index: 0,
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _Hero(isWide: isWide)),
                              const SizedBox(width: 40),
                              const Expanded(flex: 2, child: _SessionCard()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Hero(isWide: isWide),
                              const SizedBox(height: 40),
                              const _SessionCard(),
                            ],
                          ),
                  ),
                  const SizedBox(height: 56),
                  KeyedSubtree(
                    key: _screensKey,
                    child: FadeSlideIn(
                      index: 1,
                      child: _ScreenRail(isWide: isWide),
                    ),
                  ),
                  const SizedBox(height: 56),
                  KeyedSubtree(
                    key: _featuresKey,
                    child: FadeSlideIn(
                      index: 2,
                      child: _Readouts(isWide: isWide),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeSlideIn(index: 3, child: _OnDevice(isWide: isWide)),
                  const SizedBox(height: 36),
                  FadeSlideIn(index: 4, child: const _Pro()),
                  const SizedBox(height: 52),
                  FadeSlideIn(index: 5, child: _Close(isWide: isWide)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The app's own header mark — a tinted instrument tile, not a logo.
class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WIColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: WIColors.rule),
          ),
          child: const Icon(
            CupertinoIcons.gauge,
            color: WIColors.tint,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text('WorkIt', style: wiText(24, weight: FontWeight.w700)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppHeader(),
        const SizedBox(height: 28),
        Text(
          'Every set,\nmeasured.',
          style: wiText(isWide ? 44 : 32, weight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Five tabs that read like calibrated gym equipment rather than a '
            'wellness app: what you lifted, what you plan to, what you ate, '
            'one honest number over both, and the gym you train with. '
            'Nothing rounded, nothing softened.',
            style: wiText(15, color: WIColors.inkMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        const _AppStoreButton(),
      ],
    );
  }
}

/// A stylized version of the live session screen — exercise, working set in
/// tabular figures, and the rest-timer ring that keeps ticking via a Live
/// Activity when the screen locks. The countdown actually counts down, once
/// a second, rather than sitting frozen on a screenshot — the one thing a
/// static mock could never show is a timer that's actually alive, which is
/// the entire claim this card is making.
class _SessionCard extends StatefulWidget {
  const _SessionCard();

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  static const _startSeconds = 107; // 1:47, matching the readout below
  int _remaining = _startSeconds;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(
        () => _remaining = _remaining > 0 ? _remaining - 1 : _startSeconds,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _clock {
    final m = _remaining ~/ 60;
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WIColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WIColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PulseDot(color: WIColors.plate15, size: 7),
              const SizedBox(width: 8),
              Text(
                'LIVE ACTIVITY · RESTING',
                style: wiText(
                  11,
                  weight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: WIColors.plate15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Back Squat',
                      style: wiText(20, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set 4 of 5',
                      style: wiText(13, color: WIColors.inkFaint),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '225',
                          style: wiText(
                            30,
                            weight: FontWeight.w700,
                            tabularFigures: true,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'lb × 5',
                          style: wiText(14, color: WIColors.inkMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    _clock,
                    style: wiText(
                      26,
                      weight: FontWeight.w700,
                      color: WIColors.plate15,
                      tabularFigures: true,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('rest', style: wiText(11, color: WIColors.inkFaint)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One real screen from the shipped app, framed the way the site frames an
/// instrument face: hairline rule, the phone's own corner radius, and a
/// caption in the color that screen actually uses inside the app.
class _Screen extends StatefulWidget {
  final String asset;
  final String name;
  final String description;
  final Color tint;
  const _Screen({
    required this.asset,
    required this.name,
    required this.description,
    required this.tint,
  });

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: 258,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _hovered ? widget.tint : WIColors.rule,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.55),
                    blurRadius: _hovered ? 34 : 20,
                    offset: Offset(0, _hovered ? 14 : 8),
                  ),
                ],
              ),
              // Inset by the border so the screenshot's own corners sit
              // inside the frame rather than under it.
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  widget.asset,
                  width: 250,
                  fit: BoxFit.fitWidth,
                  // The screens are cropped at the device's own screen edge,
                  // so they carry no bezel and no marketing background — the
                  // frame above is the site's, not Apple's.
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.name,
              style: wiText(16, weight: FontWeight.w700, color: widget.tint),
            ),
            const SizedBox(height: 6),
            Text(
              widget.description,
              style: wiText(13, color: WIColors.inkMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// The five tabs, as they actually look. Scrolls horizontally at every width
/// rather than reflowing into a grid — the tabs have an order in the app's
/// own bottom bar, and a rail keeps it.
class _ScreenRail extends StatelessWidget {
  final bool isWide;
  const _ScreenRail({required this.isWide});

  static const _screens = <_Screen>[
    _Screen(
      asset: 'assets/workit/today.png',
      name: 'Today',
      description:
          'Training load for the last seven days, read against your own '
          'four-week average — not a generic target.',
      tint: WIColors.plate20,
    ),
    _Screen(
      asset: 'assets/workit/plan.png',
      name: 'Plan',
      description:
          'Your routines, each carrying the muscles it actually hits. '
          'Start one, or edit it in place.',
      tint: WIColors.tint,
    ),
    _Screen(
      asset: 'assets/workit/fithealth.png',
      name: 'Fit Health',
      description:
          'One reading out of 100 from how you train and what you eat — '
          'and it says which half it had the data to score.',
      tint: WIColors.plate10,
    ),
    _Screen(
      asset: 'assets/workit/nutrition.png',
      name: 'Nutrition',
      description:
          'Photograph a meal or describe it. Calories and macros come '
          'back filled in, yours to correct, and graded.',
      tint: WIColors.plate15,
    ),
    _Screen(
      asset: 'assets/workit/discover.png',
      name: 'Discover',
      description:
          'Public routines, coach programs, and the opt-in form '
          'leaderboard — the only parts that leave your phone.',
      tint: WIColors.plate25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Five tabs. This is all of them.',
          style: wiText(isWide ? 26 : 20, weight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Real screens from the shipped build — nothing staged, nothing '
            'rendered for a store listing.',
            style: wiText(14, color: WIColors.inkMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        // Bleeds past the measure on wide so the rail visibly continues off
        // the right edge instead of ending in a tidy gutter.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _screens.length; i++) ...[
                if (i > 0) const SizedBox(width: 24),
                _screens[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One shipped capability as an instrument row — icon tile, name, one-line
/// description, and a real-shaped readout on the right, exactly how the
/// app itself pairs a label with a number. Deliberately not a same-size
/// icon+heading+text card grid.
class _Readout extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String description;
  final String value;
  final String unit;
  const _Readout({
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // The fixed height and 2-line clamp exist only to make the wide 2-up
    // grid line up. In the single mobile column there is no neighbour to
    // line up with, so clipping there would be pure lost copy.
    final gridded = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      height: gridded ? 96 : null,
      decoration: BoxDecoration(
        color: WIColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WIColors.rule),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // Washed in the readout's own tint rather than a flat neutral
              // tile — six identical gray squares was the tell that no one
              // had actually looked at these six things separately.
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: wiText(16, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: gridded ? 2 : null,
                  overflow: gridded ? TextOverflow.ellipsis : TextOverflow.clip,
                  style: wiText(12, color: WIColors.inkMuted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: wiText(
                  16,
                  weight: FontWeight.w700,
                  color: tint,
                  tabularFigures: true,
                ),
              ),
              Text(unit, style: wiText(10, color: WIColors.inkFaint)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Form Checker gets its own panel instead of a seventh identical row — it's
/// the one capability the screen rail genuinely can't demonstrate (pose
/// estimation happening live, on-device), so it earns more than an icon and
/// a number. The fill bar below the score is a real 94/100 reading in the
/// same plate language as the readout rows, not a decorative meter.
class _FeaturedReadout extends StatefulWidget {
  const _FeaturedReadout();

  @override
  State<_FeaturedReadout> createState() => _FeaturedReadoutState();
}

class _FeaturedReadoutState extends State<_FeaturedReadout> {
  static const _score = 94;

  // Starts at 0 and animates to the real score a beat after the panel
  // appears — the fill bar builds itself the way the score would tick up
  // in the app, instead of sitting there already full.
  double _fillFraction = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _fillFraction = _score / 100);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WIColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WIColors.plate10.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WIColors.plate10.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.videocam_fill,
              size: 22,
              color: WIColors.plate10,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Checker',
                  style: wiText(18, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grades a lift live, on-device, mid-set — video is '
                  'analyzed on your phone and never recorded, saved, or '
                  'uploaded. Only the score below ever leaves it.',
                  style: wiText(13, color: WIColors.inkMuted, height: 1.5),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_score',
                              style: wiText(
                                32,
                                weight: FontWeight.w700,
                                color: WIColors.plate10,
                                tabularFigures: true,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 100 form score',
                              style: wiText(12, color: WIColors.inkFaint),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: WIColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              height: 6,
                              width: constraints.maxWidth * _fillFraction,
                              decoration: BoxDecoration(
                                color: WIColors.plate10,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Readouts extends StatelessWidget {
  final bool isWide;
  const _Readouts({required this.isWide});

  static const _items = <_Readout>[
    _Readout(
      icon: CupertinoIcons.gauge,
      tint: WIColors.plate10,
      title: 'Fit Health',
      description:
          'Train hard but never log a meal and the number stays '
          'honest about being half the picture.',
      value: '74',
      unit: 'out of 100',
    ),
    _Readout(
      icon: CupertinoIcons.sparkles,
      tint: WIColors.plate15,
      title: 'Meals, graded',
      description:
          'Photograph a meal or describe it; it comes back scored out of '
          '10, with the reasoning — not just a calorie count.',
      value: '9',
      unit: 'meal grade',
    ),
    _Readout(
      icon: CupertinoIcons.person_3_fill,
      tint: WIColors.plate25,
      title: 'Gym Groups & coaching',
      description:
          'Invite your crew by code. Own the group and you get every '
          'member\'s load, trends, and your notes on them.',
      value: '12',
      unit: 'members',
    ),
    _Readout(
      icon: CupertinoIcons.timer,
      tint: WIColors.plate20,
      title: 'Rest timer, Dynamic Island',
      description:
          'Keeps ticking on the Lock Screen and Dynamic Island — '
          'the audio session survives a locked phone.',
      value: '1:47',
      unit: 'remaining',
    ),
    _Readout(
      icon: CupertinoIcons.hourglass,
      tint: WIColors.tint,
      title: 'Discipline Mode',
      description:
          'Schedule your training days. Optional Screen Time integration '
          'holds distracting apps back until you start.',
      value: '14',
      unit: 'day streak',
    ),
    _Readout(
      icon: CupertinoIcons.arrow_2_circlepath,
      tint: WIColors.inkMuted,
      title: 'Apple Health & Hevy import',
      description:
          'Heart rate in, workouts back out. Bring your history from '
          'a Hevy CSV — nothing starts at zero.',
      value: '146',
      unit: 'bpm',
    ),
    _Readout(
      icon: CupertinoIcons.square_grid_2x2_fill,
      tint: WIColors.plate15,
      title: 'Home Screen widgets',
      description:
          'New in 1.4: your streak, this week\'s sessions, and Fit Health, '
          'without opening the app.',
      value: '6',
      unit: 'week streak',
    ),
    _Readout(
      icon: CupertinoIcons.bolt_fill,
      tint: WIColors.plate25,
      title: 'Quick Workout',
      description:
          'No routine needed: start a session and add exercises as you go, '
          'with your own weight increments.',
      value: '2.5',
      unit: 'lb step',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The thing no screenshot can prove, first.',
          style: wiText(isWide ? 26 : 20, weight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        const _FeaturedReadout(),
        const SizedBox(height: 16),
        if (isWide)
          // Two columns, dealt alternately, so the container's extra width
          // goes to more visible readouts instead of a wider empty gutter.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _items.length; i += 2) _items[i],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 1; i < _items.length; i += 2) _items[i],
                  ],
                ),
              ),
            ],
          )
        else
          Column(children: _items),
      ],
    );
  }
}

class _OnDevice extends StatelessWidget {
  final bool isWide;
  const _OnDevice({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: WIColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WIColors.rule),
          ),
          child: const Icon(
            CupertinoIcons.lock_shield,
            color: WIColors.tint,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your training stays on your phone.',
                style: wiText(isWide ? 24 : 20, weight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Routines, sessions and meals live on the device, not on a '
                  'server. Form Checker\'s pose estimation runs live while '
                  'you lift and the video is never recorded, saved, or '
                  'uploaded. A meal photo you ask AI to read is sent for '
                  'that one estimate and never stored. Beyond that, only the '
                  'parts that are social by definition — Discover, your gym '
                  'groups, the form leaderboard — leave the phone, and only '
                  'once you join them.',
                  style: wiText(14, color: WIColors.inkMuted, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pro named plainly rather than sold. The "is this a real company"
/// visitor wants to know there's a subscription before they install, and
/// the lifter wants to know what the free app still does.
class _Pro extends StatelessWidget {
  const _Pro();

  // Mirrors the app's own paywall list (paywall_screen.dart _FeatureList),
  // which names only what a real premium check gates.
  static const _included = [
    'AI meal logging and nutrition grades',
    'Every Discover routine and coach program',
    'Unlimited gym groups and the full form leaderboard',
    'Your full Fit Health report',
    'Discipline Mode every day of the week',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WIColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WIColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WorkIt Pro', style: wiText(18, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Logging, the rest timer, Form Checker, training-load trends '
              'and Fit Health are free, along with two gym groups, two '
              'Discipline Mode days and three AI meal scans. Pro is a weekly, '
              'monthly or yearly subscription covering:',
              style: wiText(13, color: WIColors.inkMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              for (final item in _included)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 15,
                      color: WIColors.tint,
                    ),
                    const SizedBox(width: 8),
                    Text(item, style: wiText(13)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Close extends StatelessWidget {
  final bool isWide;
  const _Close({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WorkIt is on the App Store.',
          style: wiText(isWide ? 30 : 24, weight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Text(
            'Free on iPhone, with an optional Pro subscription. '
            'Requires iOS 15 or later.',
            style: wiText(14, color: WIColors.inkMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        const _AppStoreButton(),
        const SizedBox(height: 28),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            _LegalLink(label: 'Privacy Policy', route: '/workit/privacy'),
            _LegalLink(label: 'Terms of Service', route: '/workit/terms'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Session and score figures drawn above are illustrative; the five '
          'screens are real.',
          style: wiText(11, color: WIColors.inkFaint, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

/// Opens the live App Store listing in a new tab — the page's one primary
/// action, in the app's own tint rather than Apple's black badge.
class _AppStoreButton extends StatelessWidget {
  const _AppStoreButton();

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: () =>
          launchUrl(Uri.parse(workItAppStoreUrl), webOnlyWindowName: '_blank'),
      builder: (context, hovered) => Semantics(
        link: true,
        label: 'Download WorkIt on the App Store',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFF6BB0FF) : WIColors.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Download on the App Store',
                style: wiText(
                  15,
                  weight: FontWeight.w600,
                  color: WIColors.ground,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                CupertinoIcons.arrow_up_right,
                size: 16,
                color: WIColors.ground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String route;
  const _LegalLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Text(
          label,
          style: wiText(
            13,
            weight: FontWeight.w600,
            color: WIColors.tint,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
