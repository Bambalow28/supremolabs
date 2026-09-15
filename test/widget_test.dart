import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supremolabs/app/router.dart';
import 'package:supremolabs/data/products.dart';
import 'package:supremolabs/main.dart';

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

  test('every routed product resolves to a page, unknown paths fall home', () {
    for (final p in products.where((p) => p.live)) {
      final route = generateRoute(RouteSettings(name: p.route));
      expect(route.settings.name, p.route);
      expect(
        p.ground,
        isNotNull,
        reason: '${p.name} has a route but no ground',
      );
    }
    expect(generateRoute(const RouteSettings(name: '/nope')), isNotNull);
  });

  test('routes sweep in the destination line colour, not a Material cut', () {
    final route = generateRoute(const RouteSettings(name: '/travelsync'));
    expect(route, isNot(isA<MaterialPageRoute<dynamic>>()));
    expect(
      (route as TransitionRoute<dynamic>).transitionDuration,
      const Duration(milliseconds: 620),
    );
  });
}
