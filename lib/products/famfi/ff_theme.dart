// FamFi's own world on supremolabs.com, shared by /famfi and /famfi/personal.
//
// Colour, swatches, icons and money math all come from the app itself
// (`package:juwa_wealth`), so the web and the phones can never drift apart.
// The app ships SF; on the web Inter is the nearest cut with heavy weights
// and tabular figures.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:juwa_wealth/theme.dart';

export 'package:juwa_wealth/theme.dart';

class FFColors {
  FFColors._();

  /// Public page + dark console ground (JuwaColors.dark().bg).
  static const ground = Color(0xFF0C0E12);

  /// FamFi's accent: the cobalt card from the app icon.
  static const accent = Color(0xFF2E5BE8);

  /// Cobalt lifted to read as type on the dark ground (lineInk).
  static const accentInk = Color(0xFF6F8FF5);
}

/// JuwaTheme with Inter swapped in, so every juwa_wealth widget reused on the
/// web (Money, AmountField, BudgetBar...) renders in FamFi's web type.
ThemeData famFiTheme(Brightness b) {
  final base = b == Brightness.dark ? JuwaTheme.dark() : JuwaTheme.light();
  return base.copyWith(textTheme: GoogleFonts.interTextTheme(base.textTheme));
}

/// Inter with tabular figures — every FamFi label and number on the web.
TextStyle ff(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double? spacing,
}) => GoogleFonts.inter(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: spacing ?? (size >= 28 ? -size * 0.035 : -0.1),
  fontFeatures: const [FontFeature.tabularFigures()],
);

final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

final _date = DateFormat('EEE, MMM d');

/// `Fri, Sep 25` — the app's date style everywhere on the console.
String ffDate(DateTime d) => _date.format(d);

/// `$1,234.56`, `−$12.30`, or `+$5.00` with [sign]. Minus is U+2212.
String ffMoney(double v, {bool sign = false}) {
  final s = _money.format(v.abs());
  if (v < 0) return '−$s';
  return sign && v > 0 ? '+$s' : s;
}

/// The JOSH / JUDY / JOINT (or HIS / HERS) stamp, as on the app's cards.
class FFStamp extends StatelessWidget {
  final String label;
  final Color color;
  const FFStamp(this.label, {super.key, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(5, 2, 5, 1),
    decoration: BoxDecoration(
      border: Border.all(color: color, width: 1.4),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: ff(9.5, weight: FontWeight.w800, color: color, spacing: 1.1),
    ),
  );
}

/// One wallet card: swatch flood, icon tile, name over type + stamp, balance.
/// [delta] shows a pending change as a pill under the card's edge (Payday).
class FFCard extends StatelessWidget {
  final String name;
  final String kind;
  final String stamp;
  final String color;
  final String icon;
  final double balance;
  final double? delta;
  final double height;
  final bool selected;

  const FFCard({
    super.key,
    required this.name,
    required this.kind,
    required this.stamp,
    required this.color,
    required this.icon,
    required this.balance,
    this.delta,
    this.height = 64,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final sw = swatchFor(color);
    final on = sw.on;
    final card = Container(
      // A floor, not a fixed height: larger text settings grow the card
      // instead of clipping its second line.
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: sw.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: height > 80
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: on.withValues(
                alpha: on.computeLuminance() > .5 ? .18 : .1,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(iconFor(icon), size: 18, color: on),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ff(15, weight: FontWeight.w700, color: on),
                ),
                const SizedBox(height: 4),
                // Wrap, not Row: on a squeezed card the stamp drops to its
                // own line rather than truncating the account type.
                Wrap(
                  spacing: 7,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      kind,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ff(12.5, color: on.withValues(alpha: .86)),
                    ),
                    FFStamp(stamp, color: on),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Capped so a wide balance (e.g. a large negative "owed" figure)
          // can't starve the name/kind column down to nothing on a narrow
          // card — this is the tightest spot the compact wallet rail hits.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ffMoney(balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ff(17, weight: FontWeight.w800, color: on),
                ),
                if (balance < 0)
                  Text(
                    'owed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ff(11.5, color: on.withValues(alpha: .8)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: delta == null ? 0 : 26),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? Border.all(color: context.c.ink, width: 2)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(selected ? 4 : 0),
              child: card,
            ),
          ),
          if (delta != null)
            Positioned(
              // Hangs just below the card so it never covers the type/stamp
              // line or the "owed" note.
              left: 14,
              bottom: -24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.c.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: context.c.rule),
                ),
                child: Text(
                  ffMoney(delta!, sign: true),
                  style: ff(
                    11.5,
                    weight: FontWeight.w700,
                    color: context.c.good,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
