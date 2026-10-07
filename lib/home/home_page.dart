// The hub, as a record label's catalog: every app is a numbered release, the
// crate up top is the whole catalog on one shelf, and one sleeve is always
// pulled face-out. Direction lives in the home surface brief under
// .impeccable/surfaces, not here.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/app_icon.dart';
import '../app/motion.dart';
import '../app/site_shell.dart';
import '../data/products.dart';
import '../theme/sl_theme.dart';

/// Catalog number, in lineup order — the only numbering on the page.
String catalogNo(Product p) =>
    'SL ${(products.indexOf(p) + 1).toString().padLeft(3, '0')}';

/// Ink that reads on a sleeve flooded in [c] — whichever of near-black or
/// near-white has the higher contrast ratio against it.
Color sleeveInk(Color c) {
  final l = c.computeLuminance();
  return (l + 0.05) / 0.05 >= 1.05 / (l + 0.05)
      ? const Color(0xFF0B0D10)
      : const Color(0xFFF7F7F5);
}

const _dig = Duration(milliseconds: 760);

/// Expo-out: a drawer thrown open, settling gently rather than stopping dead.
const _digCurve = Cubic(0.16, 1, 0.3, 1);

void _open(BuildContext context, Product p) {
  if (p.live) context.push(p.route!);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteShell(
      children: [
        _Masthead(),
        _Crate(),
        SLRule(),
        _Discography(),
        SLRule(),
        _LinerNotes(),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    final out = liveProducts.length;
    return SLPage(
      padding: EdgeInsets.fromLTRB(24, narrow ? 28 : 44, 24, narrow ? 28 : 40),
      child: FadeSlideIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.centerLeft,
                child: Semantics(
                  header: true,
                  child: Text(
                    'SUPREMO LABS',
                    style: SLType.display(
                      200,
                      weight: FontWeight.w800,
                    ).copyWith(height: 0.86),
                  ),
                ),
              ),
            ),
            SizedBox(height: narrow ? 16 : 22),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 24,
              runSpacing: 8,
              children: [
                Text(
                  'An independent label for apps.',
                  style: SLType.display(narrow ? 26 : 34),
                ),
                Text(
                  '$out out now  ·  ${products.length - out} forthcoming',
                  style: SLType.body(16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The whole catalog on one shelf. Every release is a spine; the one you
/// pick widens into its sleeve while the last one closes back — digging a
/// crate, not paging a carousel.
class _Crate extends StatefulWidget {
  const _Crate();

  @override
  State<_Crate> createState() => _CrateState();
}

class _CrateState extends State<_Crate> {
  int _selected = 0;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _pick(int i, double spine, bool narrow) {
    if (i == _selected) return _open(context, products[i]);
    setState(() => _selected = i);
    if (narrow && _scroll.hasClients) {
      _scroll.animateTo(
        (i * (spine + 2)).clamp(0.0, _scroll.position.maxScrollExtent),
        duration: _dig,
        curve: _digCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return SLPage(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 64),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final narrow = w < 700;
          final n = products.length;
          const gap = 2.0;
          final spine = narrow
              ? 34.0
              : ((w - 480) / (n - 1) - gap).clamp(30.0, 56.0);
          // Capped by viewport height so the face-out sleeve's notes and its
          // Open action land in the first viewport on a laptop.
          final cap = (MediaQuery.sizeOf(context).height * 0.46).clamp(
            300.0,
            540.0,
          );
          final sleeve = narrow
              ? w * 0.84
              : (w - (n - 1) * (spine + gap) - gap).clamp(300.0, cap);
          final duration = reduce ? Duration.zero : _dig;

          final shelf = SizedBox(
            height: sleeve + 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < n; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: gap),
                    child: _ShelfItem(
                      product: products[i],
                      open: i == _selected,
                      spine: spine,
                      sleeve: sleeve,
                      duration: duration,
                      onTap: () => _pick(i, spine, narrow),
                    ),
                  ),
              ],
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: shelf,
                )
              else
                shelf,
              const SizedBox(height: 28),
              AnimatedSize(
                duration: reduce ? Duration.zero : _dig,
                curve: _digCurve,
                alignment: Alignment.topLeft,
                child: AnimatedSwitcher(
                  duration: reduce ? Duration.zero : _dig,
                  switchInCurve: _digCurve,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.18),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _Notes(
                    key: ValueKey(_selected),
                    product: products[_selected],
                    narrow: narrow,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShelfItem extends StatelessWidget {
  final Product product;
  final bool open;
  final double spine;
  final double sleeve;
  final Duration duration;
  final VoidCallback onTap;
  const _ShelfItem({
    required this.product,
    required this.open,
    required this.spine,
    required this.sleeve,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: open
          ? (product.live
                ? 'Open ${product.name}'
                : '${product.name}, forthcoming')
          : 'Show ${catalogNo(product)}, ${product.name}',
      child: Hover(
        onTap: onTap,
        // The lift runs on its own quick timer, separate from the slower
        // slide that opens/closes the sleeve — a spine should feel
        // responsive to the cursor moving between items.
        builder: (context, hovered) => AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          offset: hovered && !open ? Offset(0, -12 / sleeve) : Offset.zero,
          // One progress value drives width, the spine fading out and the
          // sleeve sliding into view, so the sleeve is drawn out of the crate
          // in a single gesture instead of swapping at the first frame. A
          // tween that retargets mid-flight reverses from where it is.
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: open ? 1.0 : 0.0),
            duration: duration,
            curve: _digCurve,
            builder: (context, t, _) {
              final tt = t.clamp(0.0, 1.0);
              return SizedBox(
                width: spine + (sleeve - spine) * t,
                height: sleeve,
                child: ClipRect(
                  child: Stack(
                    children: [
                      if (tt > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          width: sleeve,
                          height: sleeve,
                          child: Opacity(
                            opacity: Curves.easeOut.transform(
                              ((tt - 0.12) / 0.6).clamp(0.0, 1.0),
                            ),
                            child: _Sleeve(
                              product: product,
                              size: sleeve,
                              lifted: hovered,
                              reveal: tt,
                            ),
                          ),
                        ),
                      if (tt < 1)
                        Positioned(
                          left: 0,
                          top: 0,
                          width: spine,
                          height: sleeve,
                          child: Opacity(
                            opacity: (1 - tt * 3).clamp(0.0, 1.0),
                            child: _Spine(
                              product: product,
                              width: spine,
                              lit: hovered,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Spine extends StatelessWidget {
  final Product product;
  final double width;
  final bool lit;
  const _Spine({required this.product, required this.width, required this.lit});

  @override
  Widget build(BuildContext context) {
    final live = product.live;
    final bg = live ? (product.accent ?? SLColors.inkMuted) : SLColors.surface;
    final ink = live ? sleeveInk(bg) : SLColors.inkMuted;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: live
            ? null
            : Border.all(color: lit ? SLColors.inkMuted : SLColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: RotatedBox(
        quarterTurns: 1,
        child: Row(
          children: [
            Flexible(
              child: Text(
                product.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: SLType.display(
                  (width * 0.52).clamp(16.0, 26.0),
                  weight: FontWeight.w700,
                ).copyWith(color: ink, letterSpacing: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            Text(catalogNo(product), style: SLType.label(ink)),
          ],
        ),
      ),
    );
  }
}

/// A release's cover. Shipped: flooded in the product's own color, its app
/// icon resting bottom right. Forthcoming: a blank keyline sleeve, stamped.
class _Sleeve extends StatelessWidget {
  final Product product;
  final double size;
  final bool lifted;

  /// 0–1 as the sleeve is drawn out; the icon trails the sleeve's edge.
  final double reveal;
  const _Sleeve({
    required this.product,
    required this.size,
    required this.lifted,
    this.reveal = 1,
  });

  @override
  Widget build(BuildContext context) {
    final s = size;
    final live = product.live;
    final bg = live ? (product.accent ?? SLColors.inkMuted) : SLColors.surface;
    final ink = live ? sleeveInk(bg) : SLColors.inkMuted;
    final pad = s * 0.055;

    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: bg,
        border: live ? null : Border.all(color: SLColors.hairline),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (live)
            Positioned(
              right: pad * 1.4,
              bottom: pad * 1.4,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 320),
                curve: _digCurve,
                scale: lifted ? 1.05 : 1,
                child: Transform.translate(
                  offset: Offset(s * 0.22 * (1 - reveal), 0),
                  child: AppIcon(
                    product: product,
                    size: s * 0.38,
                    shadow: true,
                  ),
                ),
              ),
            )
          else
            Center(
              child: Transform.rotate(
                angle: -0.14,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s * 0.04,
                    vertical: s * 0.012,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: SLColors.inkMuted, width: 2),
                  ),
                  child: Text(
                    'FORTHCOMING',
                    style: SLType.display(
                      s * 0.1,
                      weight: FontWeight.w800,
                    ).copyWith(color: SLColors.inkMuted, letterSpacing: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            left: pad,
            right: pad,
            top: pad,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(catalogNo(product), style: SLType.label(ink)),
                Text(
                  product.cluster.label.toUpperCase(),
                  style: SLType.label(ink),
                ),
              ],
            ),
          ),
          Positioned(
            left: pad,
            top: pad + s * 0.07,
            width: s - pad * 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                product.name.toUpperCase(),
                style: SLType.display(
                  s * 0.13,
                  weight: FontWeight.w800,
                ).copyWith(color: ink, height: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What's printed on the back of the sleeve currently face-out.
class _Notes extends StatelessWidget {
  final Product product;
  final bool narrow;
  const _Notes({super.key, required this.product, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final color = lineInk(product.accent ?? SLColors.inkMuted);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${catalogNo(product)}  ·  ${product.cluster.label}  ·  iOS',
          style: SLType.label(SLColors.inkMuted),
        ),
        const SizedBox(height: 10),
        Text(product.name, style: SLType.display(narrow ? 40 : 52)),
        const SizedBox(height: 6),
        Text(product.tagline, style: SLType.body(narrow ? 16 : 18)),
      ],
    );
    final action = product.live
        ? _Action(
            label: 'Open ${product.name}',
            color: color,
            onTap: () => _open(context, product),
          )
        : Text('FORTHCOMING', style: SLType.label(SLColors.inkMuted));
    return Flex(
      direction: narrow ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: narrow
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (narrow) text else Expanded(child: text),
        SizedBox(height: narrow ? 20 : 0, width: narrow ? 0 : 24),
        action,
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hover(
      onTap: onTap,
      builder: (context, hovered) {
        final fg = hovered ? sleeveInk(color) : color;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          decoration: BoxDecoration(
            color: hovered ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: SLType.label(fg)),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 16, color: fg),
            ],
          ),
        );
      },
    );
  }
}

/// The full catalog, as a label lists it: number, title, genre, status.
class _Discography extends StatelessWidget {
  const _Discography();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    return SLPage(
      padding: EdgeInsets.fromLTRB(24, narrow ? 56 : 80, 24, narrow ? 56 : 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text('Discography', style: SLType.display(narrow ? 44 : 64)),
          ),
          SizedBox(height: narrow ? 24 : 36),
          const Divider(color: SLColors.hairline, height: 1, thickness: 1),
          for (final p in products) _Track(product: p, narrow: narrow),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  final Product product;
  final bool narrow;
  const _Track({required this.product, required this.narrow});

  @override
  Widget build(BuildContext context) {
    final live = product.live;
    final color = lineInk(product.accent ?? SLColors.inkMuted);
    return Semantics(
      button: live,
      enabled: live,
      label: live
          ? 'Open ${product.name}. ${product.tagline}'
          : '${product.name}, forthcoming. ${product.tagline}',
      child: Hover(
        onTap: live ? () => _open(context, product) : null,
        builder: (context, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: narrow ? 4 : 12,
            vertical: narrow ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: hovered ? color.withValues(alpha: 0.08) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: SLColors.divider, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!narrow)
                SizedBox(
                  width: 96,
                  child: Text(
                    catalogNo(product),
                    style: SLType.label(SLColors.inkMuted),
                  ),
                ),
              // The release's icon, as it sits on the home screen; dimmed
              // while forthcoming.
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                scale: hovered ? 1.08 : 1,
                child: Opacity(
                  opacity: live ? 1 : 0.5,
                  child: AppIcon(product: product, size: narrow ? 44 : 52),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (narrow) ...[
                      Text(
                        catalogNo(product),
                        style: SLType.label(SLColors.inkMuted),
                      ),
                      const SizedBox(height: 4),
                    ],
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: SLType.display(narrow ? 24 : 30).copyWith(
                        color: hovered
                            ? color
                            : (live ? SLColors.ink : SLColors.inkMuted),
                      ),
                      child: Text(product.name),
                    ),
                    const SizedBox(height: 2),
                    Text(product.tagline, style: SLType.body(15)),
                  ],
                ),
              ),
              if (!narrow)
                SizedBox(
                  width: 150,
                  child: Text(product.cluster.label, style: SLType.body(15)),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: narrow ? 0 : 132),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      live ? 'OUT NOW' : 'FORTHCOMING',
                      style: SLType.label(live ? color : SLColors.inkMuted),
                    ),
                    if (live) ...[
                      const SizedBox(width: 8),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 180),
                        offset: hovered ? const Offset(0.3, 0) : Offset.zero,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinerNotes extends StatelessWidget {
  const _LinerNotes();

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 760;
    final portrait = Container(
      width: narrow ? 160 : 240,
      height: narrow ? 160 : 240,
      decoration: BoxDecoration(
        border: Border.all(color: SLColors.hairline),
        image: const DecorationImage(
          image: AssetImage('assets/about/portrait.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
    final note = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Liner notes', style: SLType.display(narrow ? 44 : 64)),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            'Every release in this catalog is designed, built, and shipped '
            'end to end by one person, to one standard.',
            style: SLType.body(
              narrow ? 19 : 22,
              color: SLColors.ink,
            ).copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 28),
        _Action(
          label: 'Read the full note',
          color: SLColors.accent,
          onTap: () => context.push('/about'),
        ),
      ],
    );
    return SLPage(
      padding: EdgeInsets.fromLTRB(24, narrow ? 56 : 88, 24, narrow ? 64 : 96),
      child: FadeSlideIn(
        child: Flex(
          direction: narrow ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            portrait,
            SizedBox(width: narrow ? 0 : 56, height: narrow ? 32 : 0),
            if (narrow) note else Expanded(child: note),
          ],
        ),
      ),
    );
  }
}
