// Shared motion vocabulary (see DESIGN.md). Two devices, both earning their
// frames: a section reveals when you actually reach it, and a single dot
// pulses to mark the studio's own signal. Anything that moves without saying
// something belongs to neither.
import 'package:flutter/material.dart';

/// A small circle that breathes in place. Deliberately rare — the hub runs
/// exactly one, at the interchange. When everything pulses, nothing reads as
/// live.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, required this.color, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A viewer who asked the OS to stop animation gets a plain dot, not a
    // still frame of a glow.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.22 + 0.30 * t),
                blurRadius: 4 + 9 * t,
                spreadRadius: 1 + 2 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pointer-hover state without a bespoke StatefulWidget per link — the nav
/// wordmark, the footer terminus, a station on the trunk, and the studio link
/// all want the same three lines. [builder] receives the current hover state.
/// With no [onTap] there is nothing to hover toward, so none is tracked.
class Hover extends StatelessWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  const Hover({super.key, required this.builder, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return builder(context, false);
    return _HoverRegion(builder: builder, onTap: onTap!);
  }
}

class _HoverRegion extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback onTap;
  const _HoverRegion({required this.builder, required this.onTap});

  @override
  State<_HoverRegion> createState() => _HoverRegionState();
}

class _HoverRegionState extends State<_HoverRegion> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(context, _hovered),
      ),
    );
  }
}

/// Fades and slides [child] up the first time it scrolls into view.
///
/// It used to start on a `Future.delayed` timer at mount, which meant every
/// section below the fold finished its entrance on an empty screen — by the
/// time you scrolled down, the animation was already over. Now it listens to
/// the enclosing scrollable (Scaffold provides the observer) and fires when
/// the widget's top edge actually crosses into the viewport. [index]
/// staggers siblings that arrive together.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  late final CurvedAnimation _eased = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_eased);

  ScrollNotificationObserverState? _observer;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFire());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _fired = true;
      _controller.value = 1;
      return;
    }
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  void _onScroll(ScrollNotification _) => _maybeFire();

  void _maybeFire() {
    if (_fired || !mounted) return;
    // No enclosing scrollable to listen to (a page shorter than the
    // viewport, a test harness): show it rather than leave it invisible.
    final box = context.findRenderObject() as RenderBox?;
    if (_observer != null && box != null && box.hasSize) {
      final top = box.localToGlobal(Offset.zero).dy;
      // 12% of the viewport still below the fold, so the section is already
      // on screen when it starts moving rather than sliding in from nowhere.
      if (top > MediaQuery.of(context).size.height * 0.88) return;
    }
    _fired = true;
    _observer?.removeListener(_onScroll);
    _observer = null;
    if (widget.index == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: 70 * widget.index), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    _eased.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _eased,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Builds [builder] with `false` until the widget's top edge scrolls into the
/// viewport, then `true` for good — the trigger for animations that should
/// play when you reach them (a grid lighting up, a ladder filling), not on a
/// page you have not scrolled to yet. Shows immediately under reduced motion
/// or when there is nothing to scroll.
class WhenVisible extends StatefulWidget {
  final Widget Function(BuildContext context, bool visible) builder;
  const WhenVisible({super.key, required this.builder});

  @override
  State<WhenVisible> createState() => _WhenVisibleState();
}

class _WhenVisibleState extends State<WhenVisible> {
  ScrollNotificationObserverState? _observer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _visible = true;
      return;
    }
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  void _onScroll(ScrollNotification _) => _check();

  void _check() {
    if (_visible || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (_observer != null && box != null && box.hasSize) {
      final top = box.localToGlobal(Offset.zero).dy;
      if (top > MediaQuery.of(context).size.height * 0.9) return;
    }
    _observer?.removeListener(_onScroll);
    _observer = null;
    setState(() => _visible = true);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _visible);
}
