import 'package:flutter/material.dart';

import '../data/products.dart';
import '../theme/sl_theme.dart';

/// A product's real App Store icon in the iOS squircle. Without one, a keyline
/// monogram holds the place — never a stand-in image.
class AppIcon extends StatelessWidget {
  final Product product;
  final double size;
  final bool shadow;
  const AppIcon({
    super.key,
    required this.product,
    required this.size,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.2237);
    final icon = product.icon;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: size * 0.16,
                  offset: Offset(0, size * 0.07),
                ),
              ]
            : null,
      ),
      foregroundDecoration: shadow
          ? BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            )
          : null,
      child: ClipRRect(
        borderRadius: radius,
        child: icon != null
            ? Image.asset(
                icon,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: SLColors.hairline, width: 1.4),
                ),
                child: Center(
                  child: Text(
                    product.name[0],
                    style: SLType.display(
                      size * 0.5,
                      weight: FontWeight.w800,
                    ).copyWith(color: SLColors.inkMuted),
                  ),
                ),
              ),
      ),
    );
  }
}
