// THESIS: /hundredfold is the 3 a.m. punch-clock. Every number that matters (shift clock, pay, the 100x, the estate debt) is a seven-segment cell,
// lit or ghosted, exactly as in the game. The page argues the premise in one glance (a live shift clock next to the pay it earns) and then
// shows what hunts you, what you owe, and how you hide.
// OWN-WORLD: the game's own palette (hf_colors.dart): matte near-black, tube green for safe, LED red for the clock, amber for pay,
// carbon-copy paper only on the debt statement. The hunters are the game's real 12 x 16 sprites, not illustrations.
// STORY: the visitor learns it is a survival-puzzle game for iPhone, sees the six hunters, understands the money pressure, and finds
// the privacy policy, terms and support the App Store needs.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/motion.dart';
import '../../app/site_shell.dart';
import 'hf_colors.dart';
import 'hf_monsters.dart';
import 'hf_segments.dart';

class HundredFoldPage extends StatelessWidget {
  /// `/hundredfold/hunters` and `/hundredfold/debt` scroll to that part of the page.
  final String? initialSection;
  final _huntersKey = GlobalKey();
  final _debtKey = GlobalKey();

  HundredFoldPage({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    switch (initialSection) {
      case 'hunters':
        scrollToSection(_huntersKey);
      case 'debt':
        scrollToSection(_debtKey);
    }
    return SiteShell(
      ground: HFColors.ground,
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
                  FadeSlideIn(index: 0, child: _Hero(isWide: isWide)),
                  const SizedBox(height: 72),
                  FadeSlideIn(index: 1, child: _Steps(isWide: isWide)),
                  const SizedBox(height: 72),
                  KeyedSubtree(
                    key: _huntersKey,
                    child: FadeSlideIn(
                      index: 2,
                      child: _Hunters(isWide: isWide),
                    ),
                  ),
                  const SizedBox(height: 72),
                  KeyedSubtree(
                    key: _debtKey,
                    child: FadeSlideIn(index: 3, child: _Debt(isWide: isWide)),
                  ),
                  const SizedBox(height: 72),
                  FadeSlideIn(index: 4, child: _Hide(isWide: isWide)),
                  const SizedBox(height: 72),
                  FadeSlideIn(index: 5, child: _Board(isWide: isWide)),
                  const SizedBox(height: 64),
                  FadeSlideIn(index: 6, child: const _Close()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.eyebrow, this.title, {this.body});
  final String eyebrow, title;
  final String? body;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(eyebrow, style: hfLabel(color: HFColors.tube)),
      const SizedBox(height: 10),
      Text(title, style: hfDisplay(44)),
      if (body != null) ...[
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(body!, style: hfBody(16)),
        ),
      ],
    ],
  );
}

// ---------- hero ----------

class _Hero extends StatelessWidget {
  const _Hero({required this.isWide});
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/hundredfold.png',
                width: 40,
                height: 40,
                filterQuality: FilterQuality.none,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'HUNDREDFOLD · FOR IPHONE',
              style: hfLabel(color: HFColors.amber),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'THEY PAY A\nHUNDREDFOLD.\nYOU ONLY HAVE\nTO LIVE.',
          style: hfDisplay(isWide ? 76 : 52),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'You are broke and buried in your family\'s debt. Hundredfold Staffing posts temp jobs that pay 100 times the going wage. '
            'Each one is a generated, haunted workplace. Solve the floor, stay out of the dark, clock out alive. Die, and the shift pays nothing.',
            style: hfBody(17),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const _Pill('COMING TO THE APP STORE', filled: true),
            _Pill(
              'MEET THE HUNTERS',
              onTap: () => context.go('/hundredfold/hunters'),
            ),
            // Static page under web/, outside the router: load it, don't navigate to it.
            _Pill(
              'READ THE GAME BIBLE',
              onTap: () => launchUrl(
                Uri.parse('/hundredfold/bible/'),
                webOnlyWindowName: '_self',
              ),
            ),
          ],
        ),
      ],
    );
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 40),
              const Expanded(flex: 2, child: _PunchClock()),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 36), const _PunchClock()],
          );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.filled = false, this.onTap});
  final String text;
  final bool filled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? HFColors.amber : Colors.transparent,
          border: Border.all(color: filled ? HFColors.amber : HFColors.rule),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: hfLabel(
            color: filled ? const Color(0xFF150E00) : HFColors.ink,
          ),
        ),
      ),
    ),
  );
}

/// A shift clock that is really counting down, beside the pay it is counting toward.
class _PunchClock extends StatefulWidget {
  const _PunchClock();
  @override
  State<_PunchClock> createState() => _PunchClockState();
}

class _PunchClockState extends State<_PunchClock> {
  int left = 3 * 3600 - 19;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => left = left <= 0 ? 3 * 3600 : left - 1),
    );
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String get _hms =>
      '${(left ~/ 3600).toString().padLeft(2, '0')}:${((left % 3600) ~/ 60).toString().padLeft(2, '0')}:${(left % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: HFColors.panel,
      border: Border.all(color: HFColors.rule),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SHIFT CLOCK', style: hfLabel()),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: HfSevenSeg(_hms, height: 54, color: HFColors.red, cells: 6),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Text('NORMAL WAGE', style: hfLabel()),
            const SizedBox(width: 10),
            const HfSevenSeg('45', height: 18, color: HFColors.dim, cells: 3),
          ],
        ),
        const SizedBox(height: 12),
        Text('PAYS, ON CLOCK-OUT', style: hfLabel(color: HFColors.amber)),
        const SizedBox(height: 8),
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: HfSevenSeg(
            '4500',
            height: 60,
            color: HFColors.amber,
            cells: 5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Die on the floor and the second number is \$0.',
          style: hfBody(14),
        ),
      ],
    ),
  );
}

// ---------- the shift ----------

class _Steps extends StatelessWidget {
  const _Steps({required this.isWide});
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'CLOCK IN',
        'Take a call from the agency and pick one of three generated shifts. 60 kinds of job across 12 kinds of workplace: hospitals, hotels, warehouses, theatres, tunnels.',
      ),
      (
        '02',
        'SURVIVE',
        'Cross the floor in the dark. Solve the terminals (17 kinds of puzzle, every one provably solvable) while something hunts you. Hide in a locker. Throw a noise to pull it away.',
      ),
      (
        '03',
        'CLOCK OUT',
        'Reach the exit alive and you are paid a hundredfold. Rent and the family debt come due every three shifts, whatever happens on the floor.',
      ),
    ];
    final cards = [
      for (final (n, h, b) in steps)
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: HFColors.panel,
            border: Border.all(color: HFColors.rule),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HfSevenSeg(n, height: 22, color: HFColors.tube, cells: 2),
              const SizedBox(height: 16),
              Text(h, style: hfDisplay(30)),
              const SizedBox(height: 10),
              Text(b, style: hfBody(15)),
            ],
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Section('THE SHIFT', 'ONE NIGHT. THREE STEPS.'),
        const SizedBox(height: 28),
        isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              )
            : Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    cards[i],
                  ],
                ],
              ),
      ],
    );
  }
}

// ---------- hunters ----------

class _Hunters extends StatefulWidget {
  const _Hunters({required this.isWide});
  final bool isWide;
  @override
  State<_Hunters> createState() => _HuntersState();
}

class _HuntersState extends State<_Hunters> {
  bool hunting = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(
      const Duration(milliseconds: 1400),
      (_) => setState(() => hunting = !hunting),
    ); // eyes flick red as they do in the game
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cols = widget.isWide ? 3 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Section(
          'THE HUNTERS',
          'EVERY WORKPLACE HAS ITS OWN.',
          body:
              'The job decides what is hunting you. Each hunter moves, sees and listens differently, and its face is the last thing you see if it catches you.',
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, box) {
            final w = (box.maxWidth - 14 * (cols - 1)) / cols;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final m in hfMonsters)
                  SizedBox(
                    width: w,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: HFColors.panel,
                        border: Border.all(color: HFColors.rule),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: widget.isWide ? 150 : 110,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: HFColors.ground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: AspectRatio(
                              aspectRatio: 12 / 16,
                              child: CustomPaint(
                                painter: HfSprite(m, hunting: hunting),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(m.name.toUpperCase(), style: hfDisplay(28)),
                          const SizedBox(height: 4),
                          Text(
                            m.haunts.toUpperCase(),
                            style: hfLabel(color: HFColors.tube),
                          ),
                          const SizedBox(height: 8),
                          Text(m.trait, style: hfBody(14)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------- the debt ----------

class _Debt extends StatelessWidget {
  const _Debt({required this.isWide});
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    const ink = HFColors.paperInk;
    Widget row(String a, String b, {bool bold = false, Color? c}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            a,
            style: hfBody(
              15,
              color: ink,
              weight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            b,
            style: hfBody(15, color: c ?? ink, weight: FontWeight.w700),
          ),
        ],
      ),
    );
    final paper = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HFColors.paper,
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATEMENT OF ACCOUNT', style: hfDisplay(26, color: ink)),
          const Divider(color: ink, thickness: 2),
          row('Rent', '\$1,200'),
          row('Estate minimum', '\$2,400'),
          row('Mum: care home', '\$480', c: const Color(0xFFB3200F)),
          row('Dad: medication', '\$420', c: const Color(0xFFB3200F)),
          const Divider(color: ink),
          row('Family estate debt, still owed', '\$60,000', bold: true),
          const SizedBox(height: 4),
          Text(
            '3% interest every rent day. The minimum barely outruns it.',
            style: hfBody(12, color: const Color(0xFF6B6656)),
          ),
        ],
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Section(
          'THE DEBT',
          'YOU START UNDER \$60,000.',
          body:
              'A hospital, a funeral, a mortgage nobody paid. Rent and a minimum payment come out every three shifts, interest keeps growing, '
              'and new bills slide under the door: your mum\'s care home, your dad\'s medication, a sister who wants her loan back. '
              'You cannot afford a quiet week. Miss the rent and you are evicted, and the debt starts over.',
        ),
      ],
    );
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 48),
              Expanded(flex: 2, child: paper),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 28), paper],
          );
  }
}

// ---------- hiding ----------

class _Hide extends StatelessWidget {
  const _Hide({required this.isWide});
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    Widget card(String tag, Color c, String title, String body) => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: HFColors.panel,
        border: Border.all(color: c.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: hfLabel(color: c)),
          const SizedBox(height: 10),
          Text(title, style: hfDisplay(30)),
          const SizedBox(height: 10),
          Text(body, style: hfBody(15)),
        ],
      ),
    );
    final a = card(
      'MICROPHONE',
      HFColors.tube,
      'STAY SILENT.',
      'Duck into a locker and the game goes first person. When a hunter presses its face to the door, the microphone listens for loudness only. Nothing is recorded or sent anywhere. Stay quiet and it leaves. Make noise twice and it finds you.',
    );
    final b = card(
      'CROWD MODE',
      HFColors.amber,
      'OR HOLD YOUR BREATH.',
      'Somewhere loud, or just playing with the mic off? Crowd mode swaps the microphone for a button. Hold it to hold your breath. Your breath runs out, so you still have to time it. A room too loud for the mic switches over by itself.',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Section('THE LOCKER', 'HIDING IS THE WHOLE GAME.'),
        const SizedBox(height: 28),
        isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: a),
                    const SizedBox(width: 16),
                    Expanded(child: b),
                  ],
                ),
              )
            : Column(children: [a, const SizedBox(height: 14), b]),
      ],
    );
  }
}

// ---------- the board ----------

class _Board extends StatelessWidget {
  const _Board({required this.isWide});
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    const rows = [
      ('1', 'SAMPLE NAME', '\$412,300'),
      ('2', 'SAMPLE NAME', '\$388,950'),
      ('3', 'SAMPLE NAME', '\$301,120'),
    ];
    final list = Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('SAMPLE BOARD · NOT REAL PLAYERS', style: hfLabel()),
          ),
        ),
        for (final (r, n, v) in rows)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: HFColors.panel,
              border: Border.all(
                color: r == '1' ? HFColors.amber : HFColors.rule,
                width: r == '1' ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    r,
                    style: hfDisplay(
                      26,
                      color: r == '1' ? HFColors.amber : HFColors.dim,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    n,
                    style: hfBody(
                      14,
                      color: HFColors.ink,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  v,
                  style: hfBody(
                    14,
                    color: HFColors.ink,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    final copy = const _Section(
      'THE BOARD',
      'YOUR OWN PROGRESS. YOUR OWN NAME.',
      body:
          'Make an account with a unique display name and your shifts, debts and gear follow you. The live board ranks real players by money earned, '
          'fastest clean shift, jobs survived, depth and the week. Prefer to play alone? The whole game works offline with no account.',
    );
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 48),
              Expanded(flex: 2, child: list),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 28), list],
          );
  }
}

// ---------- close ----------

class _Close extends StatelessWidget {
  const _Close();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: HFColors.panel,
      border: Border.all(color: HFColors.rule),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMING TO THE APP STORE', style: hfDisplay(40)),
        const SizedBox(height: 10),
        Text(
          'HundredFold is made by Supremo Labs for iPhone. Questions or bugs: use Support.',
          style: hfBody(15),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Pill('SUPPORT', onTap: () => context.go('/hundredfold/support')),
            _Pill('PRIVACY', onTap: () => context.go('/hundredfold/privacy')),
            _Pill('TERMS', onTap: () => context.go('/hundredfold/terms')),
          ],
        ),
      ],
    ),
  );
}
