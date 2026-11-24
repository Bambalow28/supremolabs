// Live-feeling recreations of the HoopSync home screen's own mini screens
// (marketing_screen.dart: _SampleSheet, _DraftMini, _InvitesMini,
// _RecordsMini). Sample data throughout.
import 'dart:async';

import 'package:flutter/material.dart';

import 'hs_colors.dart';

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: HSColors.surface,
        border: Border.all(color: HSColors.border.withValues(alpha: .6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    ),
  );
}

TextStyle _label(Color c) =>
    hsBody(11, color: c, weight: FontWeight.w700).copyWith(letterSpacing: 1.2);

/// A ticking clock for the minis; static under reduced motion.
mixin _Ticker<T extends StatefulWidget> on State<T> {
  Timer? _timer;
  void tick(VoidCallback f) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(f);
    });
  }

  bool get still => MediaQuery.disableAnimationsOf(context);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// The courtside stat sheet: score, clock, and a player row you can tap.
class StatSheet extends StatefulWidget {
  const StatSheet({super.key});

  @override
  State<StatSheet> createState() => _StatSheetState();
}

class _StatSheetState extends State<StatSheet> with _Ticker {
  int _a = 54, _b = 51, _reed = 14, _secs = 252;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || still) return;
    _started = true;
    tick(() {
      _secs = _secs > 0 ? _secs - 1 : 252;
      if (_secs % 4 == 0) _secs.isEven ? _a += 2 : _b += 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('7', 'T. Reyes', 9, 2, 5),
      ('11', 'D. Singh', 11, 4, 1),
      ('3', 'J. Park', 8, 1, 2),
      ('32', 'L. Brandt', 12, 9, 0),
    ];
    Widget num(String s, {double w = 44, bool bold = false}) => SizedBox(
      width: w,
      child: Text(
        s,
        textAlign: TextAlign.right,
        style: hsBody(
          14,
          color: HSColors.text,
          weight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
    Widget step(IconData i, VoidCallback f) => InkResponse(
      onTap: f,
      radius: 18,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: HSColors.hot, width: 1.5),
        ),
        child: Icon(i, size: 16, color: HSColors.hot),
      ),
    );
    final mmss = '${_secs ~/ 60}:${(_secs % 60).toString().padLeft(2, '0')}';
    return Semantics(
      label: 'Sample live stat sheet, not real data',
      child: _Shell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: HSColors.ink,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NORTHSIDE',
                          style: hsDisplay(16, color: HSColors.mute),
                        ),
                        Text('$_a', style: hsDisplay(52, color: HSColors.gold)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text('Q3', style: hsDisplay(16, color: HSColors.hot)),
                      Text(mmss, style: hsDisplay(22, color: HSColors.hot)),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EASTEND',
                          style: hsDisplay(16, color: HSColors.mute),
                        ),
                        Text('$_b', style: hsDisplay(52, color: HSColors.gold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('ON COURT', style: _label(HSColors.mute)),
                  ),
                  SizedBox(
                    width: 104,
                    child: Text(
                      'PTS',
                      textAlign: TextAlign.right,
                      style: _label(HSColors.mute),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      'REB',
                      textAlign: TextAlign.right,
                      style: _label(HSColors.mute),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      'AST',
                      textAlign: TextAlign.right,
                      style: _label(HSColors.mute),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: HSColors.hot.withValues(alpha: .1),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '#23 M. Reed',
                      style: hsBody(
                        14,
                        color: HSColors.text,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 104,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        step(
                          Icons.remove,
                          () =>
                              setState(() => _reed = (_reed - 1).clamp(0, 99)),
                        ),
                        SizedBox(
                          width: 34,
                          child: Center(
                            child: Text(
                              '$_reed',
                              style: hsBody(
                                16,
                                color: HSColors.text,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        step(
                          Icons.add,
                          () => setState(() {
                            _reed++;
                            _a++;
                          }),
                        ),
                      ],
                    ),
                  ),
                  num('6'),
                  num('3'),
                ],
              ),
            ),
            for (final r in rows)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: .08)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${r.$1} ${r.$2}',
                        style: hsBody(
                          14,
                          color: HSColors.text,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    num('${r.$3}', w: 104),
                    num('${r.$4}'),
                    num('${r.$5}'),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Sample data. Tap + to score.', style: hsBody(12)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draft night: the pick clock runs and the pool empties into two teams.
class DraftBoard extends StatefulWidget {
  const DraftBoard({super.key});

  @override
  State<DraftBoard> createState() => _DraftBoardState();
}

class _DraftBoardState extends State<DraftBoard> with _Ticker {
  static const _pool = [
    'K. Adeyemi',
    'R. Tran',
    'S. Moreau',
    'B. Ito',
    'C. Wells',
    'N. Duarte',
  ];
  int _picked = 2, _clock = 45;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || still) return;
    _started = true;
    tick(() {
      _clock--;
      if (_clock <= 40) {
        _clock = 45;
        _picked = _picked >= _pool.length ? 0 : _picked + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final harbour = [for (var i = 0; i < _picked; i += 2) _pool[i]];
    final mill = [for (var i = 1; i < _picked; i += 2) _pool[i]];
    final left = _pool.skip(_picked).toList();
    Widget col(String t, Color c, List<String> names) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: hsDisplay(20, color: c)),
            const SizedBox(height: 8),
            for (final n in names)
              TweenAnimationBuilder<double>(
                key: ValueKey('$t$n'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutExpo,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset((1 - v) * 30, 0),
                    child: child,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    n,
                    style: hsBody(
                      13,
                      color: HSColors.text,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return Semantics(
      label: 'Sample draft board, not real data',
      child: _Shell(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(gradient: HSColors.heat),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    _picked.isEven
                        ? 'ON THE CLOCK: HARBOUR'
                        : 'ON THE CLOCK: MILL ST.',
                    style: hsDisplay(20, color: HSColors.ink),
                  ),
                  const Spacer(),
                  Text(
                    '0:${_clock.toString().padLeft(2, '0')}',
                    style: hsDisplay(24, color: HSColors.ink),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  col('HARBOUR', HSColors.hot, harbour),
                  col('MILL ST.', HSColors.ember, mill),
                  col('POOL · ${left.length}', HSColors.gold, left),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One link per coach, and who has paid.
class CoachLinks extends StatelessWidget {
  const CoachLinks({super.key});

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, bool ok) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? HSColors.hot : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: ok ? null : Border.all(color: HSColors.hot, width: 1.5),
      ),
      child: Text(
        t.toUpperCase(),
        style: _label(ok ? HSColors.ink : HSColors.hot),
      ),
    );
    const rows = [
      ('Harbour Hawks · 9 players', true, 'Paid'),
      ('Mill St. Lions · 8 players', false, 'Unpaid'),
      ('Eastend Kings · invite sent', false, 'Waiting'),
    ];
    return _Shell(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COACH LINKS', style: _label(HSColors.hot)),
            const SizedBox(height: 14),
            for (final r in rows)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .16),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.$1,
                        style: hsBody(
                          14,
                          color: HSColors.text,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    chip(r.$3, r.$2),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The record book: a gold record, a top-three, and the badges.
class RecordBook extends StatelessWidget {
  const RecordBook({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('2', 'J. Park', 'Harbour', '41'),
      ('3', 'T. Reyes', 'Mill St.', '38'),
    ];
    Widget badge(String f, double s) => Image.asset(
      'assets/hoopsync/$f.png',
      width: s,
      height: s,
      semanticLabel: 'Stat badge',
    );
    return _Shell(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('RECORD BOOK', style: hsDisplay(26)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A2412), Color(0xFF14131C)],
                ),
                border: Border.all(color: HSColors.gold.withValues(alpha: .5)),
              ),
              child: Row(
                children: [
                  badge('pts_record', 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOST POINTS IN A GAME',
                          style: _label(HSColors.gold),
                        ),
                        const SizedBox(height: 4),
                        Text('M. REED', style: hsDisplay(26)),
                      ],
                    ),
                  ),
                  Text('47', style: hsDisplay(52, color: HSColors.gold)),
                ],
              ),
            ),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        r.$1,
                        style: hsDisplay(20, color: HSColors.mute),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.$2} · ${r.$3}',
                        style: hsBody(
                          14,
                          color: HSColors.text,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(r.$4, style: hsDisplay(26)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final b in [
                  'reb_record',
                  'blk_record',
                  'ast_leader',
                  'stl_leader',
                ]) ...[badge(b, 40), const SizedBox(width: 8)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
