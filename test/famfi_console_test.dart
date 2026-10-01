import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juwa_wealth/store.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supremolabs/products/famfi/console/csv_export.dart';
import 'package:supremolabs/products/famfi/console/drawer.dart';
import 'package:supremolabs/products/famfi/console/ledger_panel.dart';
import 'package:supremolabs/products/famfi/famfi_console_page.dart';

/// The ledger's copy of [text] — the wallet rail's cards list recent
/// transactions too.
Finder _inLedger(String text) =>
    find.descendant(of: find.byType(LedgerPanel), matching: find.text(text));

// These tests exercise FamFiConsoleBody directly, not FamFiConsolePage — the
// page gates on Firebase Auth + household join (no Firebase in widget
// tests), same as juwa_wealth's own widget_test.dart tests Shell directly
// rather than going through AuthGate.
Future<Widget> _console() async => MaterialApp(
  // The real page scrolls (SiteShell); the console itself no longer does.
  home: Scaffold(
    body: SingleChildScrollView(
      child: FamFiConsoleBody(
        store: await JuwaStore.load(),
        onRefresh: () async {},
      ),
    ),
  ),
);

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
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();

    // No accounts yet: the rail's empty state and the Transactions tab's own
    // empty state (Transactions is the default tab) should both show.
    expect(find.textContaining('No accounts yet'), findsWidgets);
    expect(find.textContaining('before logging a transaction'), findsOneWidget);

    // Digits typed into a field are text, not the 1–4 tab shortcuts.
    await tester.tap(find.byType(TextField).first);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pumpAndSettle();
    expect(find.textContaining('before logging a transaction'), findsOneWidget);

    await tester.tap(find.text('Payday'));
    await tester.pumpAndSettle();
    expect(find.textContaining('run payday'), findsOneWidget);

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
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();
    for (final tab in ['Transactions', 'Bills', 'Budget', 'Payday']) {
      await tester.tap(find.text(tab).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$tab tab');
    }
  });

  // iPad portrait (768) and landscape (1024) — the tab bar and its search
  // field are the tight spot: the wallet rail's fixed 344px in the
  // non-stacked (landscape) layout leaves the header less room than the
  // compact breakpoint alone would suggest.
  for (final size in [Size(768, 1024), Size(1024, 768)]) {
    testWidgets('every tab lays out with real data at tablet size $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'juwa_wealth_v3': jsonEncode(seed),
      });
      await tester.pumpWidget(await _console());
      await tester.pumpAndSettle();
      for (final tab in ['Transactions', 'Bills', 'Budget', 'Payday']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$tab tab at $size');
      }
    });
  }

  testWidgets('opening a second account shows that account, not the first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Josh Chequing').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Judy Chequing').first);
    await tester.pumpAndSettle();
    // Read-only first: the drawer shows the account just opened, and Edit
    // swaps in a form holding that account's name.
    expect(find.byType(AccountDetailDrawer), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
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
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Payday').first);
    await tester.pumpAndSettle();
    // Two cheque cards, one per owner.
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

  testWidgets('a transaction opens read-only; Edit swaps in the form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transactions').first);
    await tester.pumpAndSettle();
    await tester.tap(_inLedger('Loblaws'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Edit transaction'), findsNothing);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit transaction'), findsOneWidget);
  });

  testWidgets('a budget lists its transactions; Edit swaps in the form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Transactions · 1'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BudgetDetailDrawer),
        matching: find.text('Loblaws'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit budget'), findsOneWidget);
  });

  testWidgets('Filters narrow the ledger; Export opens', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'juwa_wealth_v3': jsonEncode(seed),
    });
    await tester.pumpWidget(await _console());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transactions').first);
    await tester.pumpAndSettle();
    expect(_inLedger('Loblaws'), findsOneWidget);
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Visa Infinite'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    // Loblaws is on Judy's account, so the Visa filter drops it.
    expect(_inLedger('Loblaws'), findsNothing);
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(find.text('Export statement'), findsOneWidget);
  });

  test(
    'statement CSV is oldest-first, quoted, signed and CRLF-separated',
    () async {
      SharedPreferences.setMockInitialValues({
        'juwa_wealth_v3': jsonEncode({
          ...seed,
          'transactions': [
            {
              'id': 'a',
              'accountId': 'uc',
              'amount': -142.3,
              'date': d('2026-09-24'),
              'name': 'Loblaws, "Queen St"',
              'categoryId': 'g1',
              'billId': null,
              'paydayId': null,
              'by': 'judy',
              'note': 'milk\neggs',
              'receipt': 'a.jpg',
              'link': null,
            },
            {
              'id': 'b',
              'accountId': 'jc',
              'amount': 2400,
              'date': d('2026-09-01'),
              'name': 'Pay',
              'categoryId': null,
              'billId': null,
              'paydayId': 'p',
              'by': 'josh',
              'note': null,
              'receipt': null,
            },
          ],
        }),
      });
      final store = await JuwaStore.load();
      final lines = transactionsCsv(store, store.transactions).split('\r\n');
      expect(
        lines.first,
        startsWith('Date,Description,Account,Category,Type,Amount'),
      );
      expect(
        lines[1],
        '2026-09-01,Pay,Josh Chequing,,Received,2400.00,JOSH,Payday,,,',
      );
      // Quoted name, and a note whose line break stays inside its quotes.
      expect(
        lines[2],
        '2026-09-24,"Loblaws, ""Queen St""",Judy Chequing,Groceries,Spent,'
        '-142.30,JUDY,Manual,"milk\neggs",,Yes',
      );
      expect(lines, hasLength(3));
    },
  );
}
