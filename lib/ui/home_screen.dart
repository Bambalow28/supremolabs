// THESIS: a studio's private lounge, not a SaaS landing page — the lineup is
// shown like member cards on a wall, not feature tiles in a pricing grid.
// OWN-WORLD: near-black warm ground, brass hairlines and labels, Fraunces
// display serif over quiet Inter body — no gradients, shadows, or second hue.
// STORY: visitor reads Supremo Labs as one coherent studio, sees itself in
// the lineup, and understands each product is a door, not a feature.
// FIRST VIEWPORT: wordmark nav, large italic Fraunces line + one-sentence
// positioning, brass eyebrow label — no CTA button, the scroll is the action.
// FORM: brief-pinned old-money world: restrained-strategy hub with hero +
// product grid + about, per user-confirmed structure; no direction roll run
// because the aesthetic and structure were both pinned by the brief.
import 'package:flutter/material.dart';
import '../theme.dart';
import 'product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.ground,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _Nav(),
            _Hero(),
            _SectionRule(),
            _ProductLineup(),
            _SectionRule(),
            _About(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

const _maxContentWidth = 1120.0;

class _Page extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Page({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav();

  @override
  Widget build(BuildContext context) {
    return _Page(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('SUPREMO LABS', style: SLType.eyebrow(SLColors.ink)),
          Text('ABOUT', style: SLType.eyebrow(SLColors.inkMuted)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final headlineSize = width < 640 ? 40.0 : 64.0;
    return _Page(
      padding: EdgeInsets.fromLTRB(24, width < 640 ? 48 : 96, 24, width < 640 ? 56 : 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A STUDIO, NOT A LIST', style: SLType.eyebrow(SLColors.brass)),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'One studio.\n', style: SLType.display(headlineSize)),
                TextSpan(text: 'A ', style: SLType.display(headlineSize)),
                TextSpan(text: 'connected', style: SLType.displayItalic(headlineSize)),
                TextSpan(text: ' suite of tools.', style: SLType.display(headlineSize)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Supremo Labs builds a small, coherent lineup of travel, finance, '
              'planning, and life apps — each one made with the same care, '
              'not scattered side projects wearing one name.',
              style: SLType.body(17),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule();

  @override
  Widget build(BuildContext context) {
    return const _Page(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: SLColors.divider, height: 1, thickness: 1),
    );
  }
}

class _ProductLineup extends StatelessWidget {
  const _ProductLineup();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width < 640 ? 1 : (width < 980 ? 2 : 3);
    return _Page(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE LINEUP', style: SLType.eyebrow(SLColors.brass)),
          const SizedBox(height: 16),
          Text('Every product', style: SLType.display(32)),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: columns == 1 ? 2.4 : 1.35,
            ),
            itemBuilder: (context, i) => _ProductCard(product: products[i]),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SLColors.surface,
          border: Border.all(color: _hover ? SLColors.brass : SLColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.product.category.toUpperCase(), style: SLType.eyebrow(SLColors.inkMuted)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(widget.product.name, style: SLType.display(24)),
                const SizedBox(height: 8),
                Text(widget.product.tagline, style: SLType.body(14)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('COMING SOON', style: SLType.eyebrow(SLColors.brass)),
            ),
          ],
        ),
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    return _Page(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE STUDIO', style: SLType.eyebrow(SLColors.brass)),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              'Supremo Labs is a small studio building software the way a '
              'good craftsman builds anything — one piece at a time, made to '
              'last. Every product ships under one name and one standard.',
              style: SLType.display(22, weight: FontWeight.w400).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return _Page(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        children: [
          const Divider(color: SLColors.divider, height: 1, thickness: 1),
          const SizedBox(height: 24),
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
