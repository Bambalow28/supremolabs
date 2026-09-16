// The studio chrome every route sits inside.
//
// Per DESIGN.md the chrome carries the current page's own color: the product's
// accent on a product route, the studio's core signal everywhere else. The
// vertical trunk rail that used to run down every page went out with the
// transit world — the hub's web is the map now, and a scroll-progress line
// beside it was chrome asserting a metaphor the page no longer holds.
//
// The footer is the web restated at the bottom of the page: every reachable
// product as a node in its own color, the one you are standing on lit, so the
// end of a page is a junction rather than a dead end.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../theme/sl_theme.dart';
import 'motion.dart';

const slMaxContentWidth = 1120.0;

/// Scrolls [key]'s widget into view — used by product pages to resolve a
/// nested route (e.g. `/travelsync/features`) to a station further down
/// their single scrolling page.
void scrollToSection(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  });
}

/// Centered, max-width column — the single measure every section aligns to.
class SLPage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SLPage({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: slMaxContentWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

/// A single hairline with generous space around it — the page's structural
/// divider, tinted [color].
class SLRule extends StatelessWidget {
  final Color color;
  const SLRule({super.key, this.color = SLColors.hairline});

  @override
  Widget build(BuildContext context) {
    return SLPage(child: Divider(color: color, height: 1, thickness: 1));
  }
}

/// The current route's color — a product's own accent on its route, the
/// studio's own signal everywhere else (hub, about).
Color currentLineColor(BuildContext context) {
  final route = ModalRoute.of(context)?.settings.name;
  return lineInk(productForPath(route)?.accent ?? SLColors.accent);
}

class SiteShell extends StatefulWidget {
  /// Body sections, between nav and footer.
  final List<Widget> children;

  /// Ground behind the body. Defaults to the studio ground; product pages
  /// pass their own.
  final Color? ground;

  /// Right-side nav slot on non-home routes, in place of the ABOUT link
  /// (which only shows on the root page). Null leaves that slot empty.
  final Widget? trailing;

  const SiteShell({
    super.key,
    required this.children,
    this.ground,
    this.trailing,
  });

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyGround = widget.ground ?? SLColors.ground;
    final line = currentLineColor(context);
    return Scaffold(
      backgroundColor: bodyGround,
      // Nav scrolls away with the rest of the page — not a fixed bar — and
      // stays transparent so the route's own ground shows through.
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _Nav(trailing: widget.trailing),
            ),
            SLRule(color: line),
            ...widget.children,
            Container(
              color: bodyGround,
              width: double.infinity,
              child: _Footer(line: line),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final Widget? trailing;
  const _Nav({this.trailing});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final atHome = route == '/';
    final product = productForPath(route);
    final accent = lineInk(product?.accent ?? SLColors.accent);

    return SLPage(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Hover(
                // Replaces the stack rather than pushing another home onto
                // it — the wordmark is "go home", not "go deeper".
                onTap: atHome ? null : () => context.go('/'),
                builder: (context, hovered) => Text(
                  'SUPREMO LABS',
                  style: SLType.eyebrow(hovered ? accent : SLColors.ink),
                ),
              ),
              if (product != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '/',
                    style: SLType.eyebrow(accent.withValues(alpha: 0.5)),
                  ),
                ),
                Text(product.name.toUpperCase(), style: SLType.eyebrow(accent)),
              ],
            ],
          ),
          // ABOUT only lives on the root page — product routes get their own
          // trailing slot (e.g. TravelSync's search) in its place.
          if (atHome)
            Hover(
              onTap: () => context.push('/about'),
              builder: (context, hovered) => Text(
                'ABOUT',
                style: SLType.eyebrow(
                  hovered ? SLColors.ink : SLColors.inkMuted,
                ),
              ),
            )
          else
            ?trailing,
        ],
      ),
    );
  }
}

/// The web, restated. Every reachable product as a node in its own color,
/// with the one you're standing on lit — so the end of a page is a junction,
/// not a dead end.
class _Footer extends StatelessWidget {
  final Color line;
  const _Footer({required this.line});

  @override
  Widget build(BuildContext context) {
    final here = productForPath(ModalRoute.of(context)?.settings.name);
    return SLPage(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: line, height: 1, thickness: 1),
          const SizedBox(height: 24),
          Wrap(
            spacing: 22,
            runSpacing: 10,
            children: [
              for (final p in products.where((p) => p.route != null))
                _NodeLink(product: p, current: identical(p, here)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© SUPREMO LABS', style: SLType.eyebrow(SLColors.inkMuted)),
              Text('SUPREMOLABS.COM', style: SLType.eyebrow(SLColors.inkMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NodeLink extends StatelessWidget {
  final Product product;
  final bool current;
  const _NodeLink({required this.product, required this.current});

  @override
  Widget build(BuildContext context) {
    final color = lineInk(product.accent ?? SLColors.inkMuted);
    return Hover(
      onTap: current
          ? null
          : () => context.push(product.route!),
      builder: (context, hovered) {
        final lit = hovered || current;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The same marker the web and the lineup use, at footer scale.
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: lit ? 8 : 6,
              height: lit ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: lit ? 1 : 0.45),
              ),
            ),
            const SizedBox(width: 9),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: SLType.body(
                13,
                color: lit ? color : SLColors.inkMuted,
                weight: current ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(product.name),
            ),
          ],
        );
      },
    );
  }
}
