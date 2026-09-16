import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supremolabs/app/router.dart';
import 'package:supremolabs/data/products.dart';
import 'package:supremolabs/main.dart';
import 'package:supremolabs/theme/sl_theme.dart';

void main() {
  testWidgets('home screen names every product', (WidgetTester tester) async {
    await tester.pumpWidget(const SupremoLabsApp());
    await tester.pump();

    // Nav wordmark and the masthead.
    expect(find.text('SUPREMO LABS'), findsWidgets);
    for (final p in products) {
      // A shipped product is named more than once by design — an entry in
      // the lineup and a node in the footer — so this asserts presence, not a
      // single card. The web's own labels are painted on canvas and are
      // deliberately invisible to this (and to assistive tech).
      expect(find.text(p.name), findsWidgets, reason: '${p.name} is missing');
    }
  });

  testWidgets('only shipped products are offered as destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupremoLabsApp());
    await tester.pump();

    final live = products.where((p) => p.live).length;
    // One "OUT NOW" per shipped release in the discography; everything else
    // is named honestly as forthcoming rather than dressed up as a peer.
    expect(find.text('OUT NOW'), findsNWidgets(live));
    expect(find.text('FORTHCOMING'), findsNWidgets(products.length - live));
  });

  test('every live product has a route registered, with a ground color', () {
    for (final p in products.where((p) => p.live)) {
      expect(pages.containsKey(p.route), isTrue, reason: '${p.name} has no route');
      expect(
        p.ground,
        isNotNull,
        reason: '${p.name} has a route but no ground',
      );
    }
    // Unknown paths aren't in the map — GoRouter's errorBuilder falls them
    // home instead (see appRouter's errorBuilder).
    expect(pages.containsKey('/nope'), isFalse);
  });

  test('routes sweep in the destination line colour, not a Material cut', () {
    final page = LineSweepPage(
      path: '/travelsync',
      builder: pages['/travelsync']!,
      line: SLColors.accent,
    );
    expect(page, isNot(isA<MaterialPage<dynamic>>()));
    expect(page.transitionDuration, const Duration(milliseconds: 620));
  });
}
