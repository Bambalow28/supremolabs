// /marketpulse/personal — the phone app's own screens and state, run here
// (imported from ../marketpulse, not re-drawn), as the whole page between the
// site header and footer. The page itself scrolls: each tab is sized to its
// content, and the rail (or tab bar) stays pinned while you read. The data
// source setting lives in Settings. Everything is stored in this browser;
// nothing is sent to Supremo Labs.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:marketpulse/academy_state.dart';
import 'package:marketpulse/app_state.dart';
import 'package:marketpulse/arena_screen.dart';
import 'package:marketpulse/arena_service.dart';
import 'package:marketpulse/live_screen.dart';
import 'package:marketpulse/settings_screen.dart';
import 'package:marketpulse/signals_screen.dart';
import 'package:marketpulse/watchlist_screen.dart';
import 'package:marketpulse/widgets.dart' as app_ui;

import '../../app/site_shell.dart';
import 'marketpulse_page.dart';
import 'mp_proxy.dart';

class MarketPulseConsolePage extends StatefulWidget {
  const MarketPulseConsolePage({super.key});

  @override
  State<MarketPulseConsolePage> createState() => _MarketPulseConsolePageState();
}

class _MarketPulseConsolePageState extends State<MarketPulseConsolePage> {
  late final AppState _app = AppState();
  late final AcademyState _academy = AcademyState();
  late final ArenaService _arena = ArenaService();
  final _scroll = ScrollController();
  final _area = GlobalKey();
  int _tab = 0;

  static const _tabs = [
    ('News', CupertinoIcons.news),
    ('Watchlists', CupertinoIcons.star),
    ('Signals', CupertinoIcons.graph_square),
    ('Arena', CupertinoIcons.flag),
    ('Settings', CupertinoIcons.gear),
  ];

  static const _railW = 212.0;
  static const _barH = 54.0;

  @override
  void initState() {
    super.initState();
    // main.dart loads the proxy before the first frame, so the first fetch
    // already goes the right way.
    _app.init();
    _academy.init();
    _arena.init();
    // Same cadence as the phone app: headlines (and so alerts) every 2 minutes.
    _poll = Timer.periodic(const Duration(minutes: 2), (_) => _app.refresh());
  }

  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Widget _screen(int i) => switch (i) {
    0 => LiveScreen(_app),
    1 => WatchlistScreen(_app, _academy),
    2 => SignalsScreen(_app),
    3 => ArenaScreen(_arena, _app),
    _ => SettingsScreen(_app),
  };

  void _select(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
    // The app polls the strip and signal prices only for the visible tab.
    _app.tab = i;
    if (i == 2) _app.refreshSignalPrices();
    _arena.watch(i == 3);
    _toAreaTop();
  }

  /// Brings the top of the app area back into view, so a new tab or a pushed
  /// story starts at its own top, not wherever the last page was left.
  void _toAreaTop() {
    final box = _area.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !_scroll.hasClients) return;
    final top = _scroll.offset + box.localToGlobal(Offset.zero).dy;
    if (_scroll.offset > top) _scroll.jumpTo(top);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 1000;
    final minH = (size.height - 90).clamp(560.0, 1400.0);
    return SiteShell(
      ground: app_ui.bg,
      maxWidth: 1280,
      controller: _scroll,
      children: [
        app_ui.AppBackdrop(
          child: SLPage(
            maxWidth: 1280,
            padding: EdgeInsets.zero,
            child: Stack(
              key: _area,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: wide ? _railW : 0,
                    top: wide ? 0 : _barH,
                  ),
                  child: _stage(minH),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: wide ? null : 0,
                  child: _Sticky(
                    controller: _scroll,
                    area: _area,
                    height: wide ? minH : _barH,
                    child: wide
                        ? _Rail(
                            tab: _tab,
                            tabs: _tabs,
                            onTap: _select,
                            app: _app,
                          )
                        : _TopTabs(tab: _tab, tabs: _tabs, onTap: _select),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The phone app's screens, themed as the app themes them. Each tab keeps its
  /// own Navigator so a story or ticker opens inside the pane, not over the
  /// site. Only the active tab takes up room (Offstage), so the page is as tall
  /// as the tab you are on.
  Widget _stage(double minH) => Theme(
    data: app_ui.buildTheme(),
    child: Column(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Offstage(
            offstage: i != _tab,
            child: _Pane(
              key: ValueKey('mp-tab-$i'),
              active: i == _tab,
              minHeight: minH,
              onDeep: _toAreaTop,
              // The app's screens do not listen to its state themselves
              // (its Shell rebuilds them), so each tab is rebuilt per
              // notification.
              root: ListenableBuilder(
                listenable: Listenable.merge([_app, _academy, _arena]),
                builder: (_, _) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(bottom: false, child: _screen(i)),
                ),
              ),
            ),
          ),
        if (_tab == _tabs.length - 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
            child: const _SourcePanel(),
          ),
      ],
    ),
  );
}

/// One tab. Sized to its screen's content so the page scrolls instead of the
/// screen: the screen's own scroll view is told how much it needs, via its
/// scroll metrics, and has nothing left to scroll. A screen pushed on top (a
/// story, a ticker) gets a viewport-high pane and scrolls inside it, since a
/// sheet or detail view cannot size itself to the page. The tab fades and
/// slides in each time it is opened.
class _Pane extends StatefulWidget {
  final bool active;
  final double minHeight;
  final VoidCallback onDeep;
  final Widget root;
  const _Pane({
    super.key,
    required this.active,
    required this.minHeight,
    required this.onDeep,
    required this.root,
  });

  @override
  State<_Pane> createState() => _PaneState();
}

class _PaneState extends State<_Pane> with SingleTickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final _depth = _Depth(_onDepth);
  double _h = 0;
  bool _deep = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _enter.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _enter.value = 1;
  }

  @override
  void didUpdateWidget(_Pane old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _h = 0; // measure afresh: content may have shrunk since last visit
      MediaQuery.disableAnimationsOf(context)
          ? _enter.value = 1
          : _enter.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _onDepth(int d) {
    final deep = d > 1;
    if (deep == _deep) return;
    if (deep) widget.onDeep();
    setState(() {
      _deep = deep;
      if (!deep) _h = 0; // content may have grown while deep
    });
  }

  bool _onMetrics(ScrollMetricsNotification n) {
    if (_deep || n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final need = n.metrics.viewportDimension + n.metrics.maxScrollExtent;
    if (need > _h + 1) setState(() => _h = need);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final h = _deep ? widget.minHeight : math.max(widget.minHeight, _h);
    final inner = Navigator(
      observers: [_depth],
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => widget.root),
    );
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: AnimatedBuilder(
        animation: _enter,
        child: SizedBox(
          height: h,
          // Same widget shape either way: swapping parents would rebuild the
          // Navigator and drop the route that was just pushed (first click lost).
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              physics: _deep ? null : const NeverScrollableScrollPhysics(),
            ),
            child: inner,
          ),
        ),
        builder: (_, child) {
          final t = Curves.easeOutCubic.transform(_enter.value);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 24),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Counts the routes on a tab's Navigator (the tab's own screen is 1).
class _Depth extends NavigatorObserver {
  final ValueChanged<int> onChange;
  int _d = 0;
  _Depth(this.onChange);

  void _set(int d) {
    _d = d;
    onChange(d);
  }

  @override
  void didPush(Route route, Route? previous) => _set(_d + 1);

  @override
  void didPop(Route route, Route? previous) => _set(_d - 1);

  @override
  void didRemove(Route route, Route? previous) => _set(_d - 1);
}

/// Keeps [child] in view while the page scrolls past its [area], without
/// leaving it. [height] is the child's own height.
class _Sticky extends StatelessWidget {
  final ScrollController controller;
  final GlobalKey area;
  final double height;
  final Widget child;
  const _Sticky({
    required this.controller,
    required this.area,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (_, c) {
      final box = area.currentContext?.findRenderObject() as RenderBox?;
      var dy = 0.0;
      if (box != null && box.attached && box.hasSize) {
        dy = (-box.localToGlobal(Offset.zero).dy).clamp(
          0.0,
          math.max(0.0, box.size.height - height),
        );
      }
      return Transform.translate(offset: Offset(0, dy), child: c);
    },
    child: SizedBox(height: height, child: child),
  );
}

class _Rail extends StatelessWidget {
  final int tab;
  final List<(String, IconData)> tabs;
  final ValueChanged<int> onTap;
  final AppState app;
  const _Rail({
    required this.tab,
    required this.tabs,
    required this.onTap,
    required this.app,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 212,
    padding: const EdgeInsets.fromLTRB(12, 22, 12, 16),
    decoration: const BoxDecoration(
      color: Color(0xFF091524),
      border: Border(right: BorderSide(color: MPColors.rule)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 22),
          child: Text('MarketPulse', style: mpTitle(16)),
        ),
        for (var i = 0; i < tabs.length; i++)
          _RailItem(
            label: tabs[i].$1,
            icon: tabs[i].$2,
            on: i == tab,
            onTap: () => onTap(i),
          ),
        const Spacer(),
        ListenableBuilder(
          listenable: app,
          builder: (_, _) => Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              app.updated == null
                  ? 'Loading headlines…'
                  : 'Updated ${_hm(app.updated!)} · every 2 min',
              style: mpBody(11.5),
            ),
          ),
        ),
      ],
    ),
  );
}

String _hm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _RailItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool on;
  final VoidCallback onTap;
  const _RailItem({
    required this.label,
    required this.icon,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    label: label,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF13243A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: on ? MPColors.pulse : MPColors.mute),
            const SizedBox(width: 12),
            Text(
              label,
              style: mpBody(
                14,
                color: on ? MPColors.text : MPColors.mute,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopTabs extends StatelessWidget {
  final int tab;
  final List<(String, IconData)> tabs;
  final ValueChanged<int> onTap;
  const _TopTabs({required this.tab, required this.tabs, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    decoration: const BoxDecoration(
      color: Color(0xFF091524),
      border: Border(bottom: BorderSide(color: MPColors.rule)),
    ),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      children: [
        for (var i = 0; i < tabs.length; i++)
          _RailItem(
            label: tabs[i].$1,
            icon: tabs[i].$2,
            on: i == tab,
            onTap: () => onTap(i),
          ),
      ],
    ),
  );
}

/// Shown under Settings: where the headlines and prices come from, and the one
/// setting the browser needs that the phone does not: a proxy for feeds that refuse browser calls.
class _SourcePanel extends StatefulWidget {
  const _SourcePanel();

  @override
  State<_SourcePanel> createState() => _SourcePanelState();
}

class _SourcePanelState extends State<_SourcePanel> {
  late final _ctl = TextEditingController(text: MPProxy.url);
  bool _saved = false;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await MPProxy.save(_ctl.text);
    if (!mounted) return;
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final direct = MPProxy.url.isEmpty;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA SOURCE',
          style: mpBody(
            11,
            color: MPColors.mute,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: direct ? MPColors.warn : MPColors.pulse,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              direct ? 'Direct from the browser' : 'Through your proxy',
              style: mpBody(14, color: MPColors.text, weight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          direct
              ? 'Most news feeds and Yahoo prices refuse browser calls, so many panels stay empty until you add a proxy.'
              : 'Feeds and prices are fetched by your proxy and returned to this page.',
          style: mpBody(12.5),
        ),
        const SizedBox(height: 18),
        Text('Proxy URL', style: mpBody(12, color: MPColors.mute)),
        const SizedBox(height: 6),
        TextField(
          controller: _ctl,
          onChanged: (_) => setState(() => _saved = false),
          style: mpBody(13, color: MPColors.text),
          decoration: InputDecoration(
            hintText: 'https://mp-proxy.you.workers.dev',
            hintStyle: mpBody(13),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF13243A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MPColors.rule),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MPColors.rule),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MPColors.pulse),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: MPColors.pulse,
                foregroundColor: const Color(0xFF04130C),
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(
                'Save',
                style: mpBody(
                  13,
                  color: const Color(0xFF04130C),
                  weight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (_saved)
              Expanded(
                child: Text(
                  'Saved. Reload the page to use it.',
                  style: mpBody(12, color: MPColors.pulse),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'The proxy source is in tool/mp_proxy_worker.js. Your AI key goes straight to Anthropic from this browser, never through it.',
          style: mpBody(12),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF091524),
        border: Border.all(color: MPColors.rule),
        borderRadius: BorderRadius.circular(16),
      ),
      child: body,
    );
  }
}
