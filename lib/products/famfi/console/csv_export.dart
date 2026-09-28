// A statement as CSV: one row per transaction, oldest first, in the shape a
// spreadsheet or bookkeeping tool expects — ISO dates, a signed plain-number
// amount (spent is negative), RFC 4180 quoting and CRLF line ends.
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';

import 'drawer.dart' show categoryLabel;

const _header = [
  'Date',
  'Description',
  'Account',
  'Category',
  'Type',
  'Amount',
  'Added by',
  'Source',
  'Note',
  'Order link',
  'Receipt',
];

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Quotes a field when it holds a comma, quote or line break.
String csvField(String v) =>
    RegExp(r'[",\r\n]').hasMatch(v) ? '"${v.replaceAll('"', '""')}"' : v;

String transactionsCsv(JuwaStore store, Iterable<Transaction> txs) {
  final sorted = txs.toList()
    ..sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
  final rows = <List<String>>[
    _header,
    for (final t in sorted)
      [
        _iso(t.date),
        t.name,
        store.accounts.where((a) => a.id == t.accountId).firstOrNull?.name ??
            'Deleted account',
        t.categoryId == null ? '' : categoryLabel(store, t.categoryId),
        t.amount < 0 ? 'Spent' : 'Received',
        t.amount.toStringAsFixed(2),
        t.by.label,
        t.billId != null
            ? 'Bill'
            : t.paydayId != null
            ? 'Payday'
            : 'Manual',
        t.note ?? '',
        t.link ?? '',
        t.receipt != null ? 'Yes' : '',
      ],
  ];
  return rows.map((r) => r.map(csvField).join(',')).join('\r\n');
}
