import 'package:flutter_test/flutter_test.dart';

import 'package:supremolabs/main.dart';
import 'package:supremolabs/ui/product.dart';

void main() {
  testWidgets('home screen renders every product', (WidgetTester tester) async {
    await tester.pumpWidget(const SupremoLabsApp());
    await tester.pump();

    expect(find.text('SUPREMO LABS'), findsOneWidget);
    for (final p in products) {
      expect(find.text(p.name), findsOneWidget);
    }
  });
}
