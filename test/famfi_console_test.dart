import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supremolabs/products/famfi/famfi_console_page.dart';

String d(String s) => '${s}T00:00:00.000';
// Minimal household: enough to fill every tab's table/calendar.
final seed = {
  'accounts': [
    {
      'id': 'jc',
      'name': 'Josh Chequing',
      'icon': 'bank',
      'color': 'cobalt',
      'kind': 'chequing',
      'owner': 'josh',
      'balance': 4812.40,
    },
    {
      'id': 'uc',
      'name': 'Judy Chequing',
      'icon': 'wallet',
      'color': 'tomato',
      'kind': 'chequing',
      'owner': 'judy',
      'balance': 3960.15,
    },
    {
      'id': 'vi',
      'name': 'Visa Infinite',
      'icon': 'card',
      'color': 'graphite',
      'kind': 'credit',
      'owner': 'josh',
      'balance': -1240.18,
    },
  ],
  'bills': [
    {
      'id': 'b1',
      'name': 'Rent',
      'amount': 1850,
      'icon': 'home',
      'color': 'cobalt',
      'firstDate': d('2026-01-01'),
      'repeat': 'monthly',
      'accountId': 'jc',
    },
    {
      'id': 'b3',
      'name': 'Gym',
      'amount': 24.99,
      'icon': 'fitness',
      'color': 'tomato',
      'firstDate': d('2026-01-02'),
      'repeat': 'weekly',
      'accountId': 'vi',
    },
  ],
  'paydays': [],
  'budgets': [
    {
      'id': 'g1',
      'name': 'Groceries',
      'monthlyTarget': 800,
      'spent': 258,
      'month': '2026-09',
    },
  ],
  'categories': [
    {'id': 'c1', 'name': 'Gas', 'color': 'graphite'},
  ],
  'transactions': [
    {
      'id': 't1',
      'accountId': 'uc',
      'amount': -142.36,
      'date': d('2026-09-24'),
      'name': 'Loblaws',
      'categoryId': 'g1',
      'billId': null,
      'paydayId': null,
      'by': 'judy',
      'note': null,
      'receipt': null,
    },
    {
      'id': 't5',
      'accountId': 'jc',
      'amount': -75,
      'date': d('2026-09-18'),
      'name': 'Internet',
      'categoryId': null,
      'billId': 'b1',
      'paydayId': null,
      'by': 'josh',
      'note': null,
      'receipt': null,
    },
  ],
  'readNotificationIds': [],
};

void main() {
  testWidgets('empty state renders and switching tabs works', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: FamFiConsolePage()));
    await tester.pumpAndSettle();

    // No accounts yet: the rail's empty state and the Payday tab's own
    // empty state (Payday is the default tab) should both show.
    expect(find.textContaining('No accounts yet'), findsWidgets);
    expect(find.text('Payday'), findsWidgets);

    // Digits typed into a field are text, not the 1–4 tab shortcuts.
    await tester.tap(find.byType(TextField).first);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    expect(find.textContaining('run payday'), findsOneWidget);

    await tester.tap(find.text('Ledger'));
    await tester.pumpAndSettle();
    expect(find.text('Ledger'), findsWidgets);

    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    expect(find.text('Bills'), findsWidgets);

    await tester.tap(find.text('Budget'));
    await tester.pumpAndSettle();
    expect(find.text('Budget'), findsWidgets);
  });

  testWidgets('every tab lays out with real data at desktop size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(const MaterialApp(home: FamFiConsolePage()));
    await tester.pumpAndSettle();
    for (final tab in ['Ledger', 'Bills', 'Budget', 'Payday']) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab tab');
    }
  });

  testWidgets('opening a second account shows that account, not the first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(const MaterialApp(home: FamFiConsolePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Josh Chequing').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Judy Chequing').first);
    await tester.pumpAndSettle();
    // The drawer's name field must hold the account just opened.
    expect(find.widgetWithText(TextField, 'Judy Chequing'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Josh Chequing'), findsNothing);
  });

  testWidgets('two-cheque Payday: entering both amounts renders both Lefts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(const MaterialApp(home: FamFiConsolePage()));
    await tester.pumpAndSettle();

    // Payday is the default tab: two cheque cards, one per owner.
    expect(find.text("Josh's cheque"), findsOneWidget);
    expect(find.text("Judy's cheque"), findsOneWidget);

    // TextField order: header search box, then Josh's amount, then Judy's.
    final amountFields = find.byType(TextField);
    await tester.enterText(amountFields.at(1), '3250');
    await tester.pumpAndSettle();
    await tester.enterText(amountFields.at(2), '2980');
    await tester.pumpAndSettle();

    expect(find.text('Josh left'), findsOneWidget);
    expect(find.text('Judy left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
