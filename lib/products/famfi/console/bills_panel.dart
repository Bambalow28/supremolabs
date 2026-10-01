// Bills tab: a month calendar plus the before/later due lists, matching
// BillsScreen's grouping (occurrences before the next payday vs. after).
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/bills/bills_screen.dart' show freqLabel;
import 'package:juwa_wealth/widgets.dart' show Reveal;

import '../ff_theme.dart';
import 'drawer.dart';

class BillsPanel extends StatefulWidget {
  final JuwaStore store;
  final void Function(Widget drawer) openDrawer;
  final VoidCallback closeDrawer;

  const BillsPanel({
    super.key,
    required this.store,
    required this.openDrawer,
    required this.closeDrawer,
  });

  @override
  State<BillsPanel> createState() => _BillsPanelState();
}

class _BillsPanelState extends State<BillsPanel> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  Future<void> _markPaid(Bill bill, DateTime date) async {
    var accountId = bill.accountId;
    if (accountId == null) {
      accountId = await pickFrom<String>(
        context,
        title: 'Pay from which account?',
        items: [for (final a in widget.store.accounts) (a.name, a.id)],
      );
      if (accountId == null) return;
    }
    await widget.store.markBillPaid(bill, date, accountId);
  }

  Future<void> _openAll() async {
    final edit = await showDialog<Bill>(
      context: context,
      builder: (_) => FFPopIn(child: _AllBillsDialog(store: widget.store)),
    );
    if (edit == null || !mounted) return;
    widget.openDrawer(
      BillDrawer(store: widget.store, bill: edit, onClose: widget.closeDrawer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = widget.store;
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final nextPayday = store.nextPaydayDate(day);

    final before = <(Bill, DateTime)>[];
    final later = <(Bill, DateTime)>[];
    for (final bill in store.bills) {
      final occ = JuwaStore.occurrences(bill, day, nextPayday);
      if (occ.isNotEmpty) {
        for (final d in occ) {
          before.add((bill, d));
        }
      } else {
        final due = JuwaStore.nextDue(bill, nextPayday);
        if (due != null) later.add((bill, due));
      }
    }
    before.sort((a, b) => a.$2.compareTo(b.$2));
    later.sort((a, b) => a.$2.compareTo(b.$2));
    final beforeTotal = before.fold(0.0, (s, e) => s + e.$1.amount);

    if (store.bills.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bills',
              style: ff(32, weight: FontWeight.w800, color: c.ink, spacing: -1),
            ),
            const SizedBox(height: 24),
            Text(
              'No bills yet — add one to see it on the calendar.',
              style: ff(15, color: c.muted, weight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Bills',
                style: ff(
                  32,
                  weight: FontWeight.w800,
                  color: c.ink,
                  spacing: -1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: ff(14.5, color: c.muted),
                    children: [
                      TextSpan(
                        text: ffMoney(store.monthlyBillTotal),
                        style: ff(14.5, weight: FontWeight.w700, color: c.ink),
                      ),
                      const TextSpan(
                        text: ' a month · hover a bill to mark it paid',
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _openAll,
                icon: const Icon(Icons.list_alt_rounded, size: 18),
                label: const Text('All bills'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.ink,
                  side: BorderSide(color: c.rule),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, cons) {
              final stacked = cons.maxWidth < 900;
              final calendar = _Calendar(
                store: store,
                month: _month,
                onPrev: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                onNext: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
                monthLabel: '${_months[_month.month - 1]} ${_month.year}',
              );
              final lists = _Lists(
                store: store,
                before: before,
                later: later,
                beforeTotal: beforeTotal,
                nextPayday: nextPayday,
                today: day,
                onMarkPaid: _markPaid,
                onOpen: (bill) => widget.openDrawer(
                  BillDrawer(
                    store: store,
                    bill: bill,
                    onClose: widget.closeDrawer,
                  ),
                ),
              );
              if (stacked) {
                return Column(
                  children: [calendar, const SizedBox(height: 24), lists],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: calendar),
                  const SizedBox(width: 24),
                  SizedBox(width: 400, child: lists),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  final JuwaStore store;
  final DateTime month;
  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _Calendar({
    required this.store,
    required this.month,
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final today = DateTime.now();
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final leading = firstOfMonth.weekday % 7;
    final nextPayday = store.nextPaydayDate(
      DateTime(today.year, today.month, today.day),
    );
    final paydayDates = <DateTime>{
      DateTime(nextPayday.year, nextPayday.month, nextPayday.day),
      for (final p in store.paydays)
        DateTime(p.date.year, p.date.month, p.date.day),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                monthLabel,
                style: ff(17, weight: FontWeight.w700, color: c.ink),
              ),
              const Spacer(),
              IconButton(
                onPressed: onPrev,
                icon: Icon(Icons.chevron_left_rounded, color: c.muted),
              ),
              IconButton(
                onPressed: onNext,
                icon: Icon(Icons.chevron_right_rounded, color: c.muted),
              ),
            ],
          ),
          // A Table, not a fixed-ratio grid: a week grows to fit its
          // busiest day instead of clipping bills.
          Builder(
            builder: (context) {
              final cells = <Widget>[
                for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                for (var day = 1; day <= lastDay; day++)
                  _dayCell(context, day, today, paydayDates),
              ];
              while (cells.length % 7 != 0) {
                cells.add(const SizedBox.shrink());
              }
              return Table(
                defaultVerticalAlignment:
                    TableCellVerticalAlignment.intrinsicHeight,
                children: [
                  TableRow(
                    children: [
                      for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              w,
                              style: ff(
                                11.5,
                                weight: FontWeight.w600,
                                color: c.faint,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (var r = 0; r < cells.length; r += 7)
                    TableRow(children: cells.sublist(r, r + 7)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    int day,
    DateTime today,
    Set<DateTime> paydayDates,
  ) {
    final c = context.c;
    final date = DateTime(month.year, month.month, day);
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isPayday = paydayDates.contains(date);
    final occ = <(Bill, bool)>[];
    for (final bill in store.bills) {
      if (JuwaStore.occurrences(
        bill,
        date,
        date.add(const Duration(days: 1)),
      ).isNotEmpty) {
        occ.add((bill, store.isPaid(bill, date)));
      }
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.rule)),
        color: isPayday ? c.fill : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? c.ink : null,
                ),
                child: Text(
                  '$day',
                  style: ff(
                    12,
                    weight: FontWeight.w600,
                    color: isToday ? c.bg : c.ink,
                  ),
                ),
              ),
              if (isPayday) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PAYDAY',
                      style: ff(
                        11,
                        weight: FontWeight.w700,
                        color: c.good,
                        spacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          for (final (bill, paid) in occ.take(3))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: swatchFor(bill.color).color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bill.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          ff(
                            11,
                            weight: FontWeight.w600,
                            color: paid ? c.faint : c.ink,
                            height: 1,
                          ).copyWith(
                            decoration: paid
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Lists extends StatelessWidget {
  final JuwaStore store;
  final List<(Bill, DateTime)> before;
  final List<(Bill, DateTime)> later;
  final double beforeTotal;
  final DateTime nextPayday;
  final DateTime today;
  final Future<void> Function(Bill, DateTime) onMarkPaid;
  final void Function(Bill) onOpen;

  const _Lists({
    required this.store,
    required this.before,
    required this.later,
    required this.beforeTotal,
    required this.nextPayday,
    required this.today,
    required this.onMarkPaid,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Before payday · ${ffDate(nextPayday)}',
                overflow: TextOverflow.ellipsis,
                style: ff(13, weight: FontWeight.w600, color: c.muted),
              ),
            ),
            Text(
              ffMoney(beforeTotal),
              style: ff(13, weight: FontWeight.w700, color: c.ink),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: before.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Nothing due before payday.',
                    style: ff(13.5, color: c.muted),
                  ),
                )
              : Column(
                  children: [
                    for (final (i, (bill, date)) in before.indexed)
                      Reveal(
                        index: i,
                        child: _Row(
                          store: store,
                          bill: bill,
                          date: date,
                          today: today,
                          onMarkPaid: onMarkPaid,
                          onOpen: onOpen,
                          last: i == before.length - 1,
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Text(
          'Later',
          style: ff(13, weight: FontWeight.w600, color: c.muted),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: later.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Nothing else scheduled.',
                    style: ff(13.5, color: c.muted),
                  ),
                )
              : Column(
                  children: [
                    for (final (i, (bill, date)) in later.indexed)
                      Reveal(
                        index: before.length + i,
                        child: _Row(
                          store: store,
                          bill: bill,
                          date: date,
                          today: today,
                          onMarkPaid: onMarkPaid,
                          onOpen: onOpen,
                          last: i == later.length - 1,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Row extends StatefulWidget {
  final JuwaStore store;
  final Bill bill;
  final DateTime date;
  final DateTime today;
  final Future<void> Function(Bill, DateTime) onMarkPaid;
  final void Function(Bill) onOpen;

  /// The list's final row: no rule beneath it.
  final bool last;
  const _Row({
    required this.store,
    required this.bill,
    required this.date,
    required this.today,
    required this.onMarkPaid,
    required this.onOpen,
    this.last = false,
  });

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final swatch = swatchFor(widget.bill.color);
    final paid = widget.store.isPaid(widget.bill, widget.date);
    final diff = widget.date.difference(widget.today).inDays;
    final Color when = diff <= 0 ? c.bad : (diff <= 3 ? c.warn : c.muted);
    final whenText = diff <= 0 ? 'Today' : ffDate(widget.date);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onOpen(widget.bill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: widget.last
                  ? null
                  : Border(bottom: BorderSide(color: c.rule)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: swatch.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconFor(widget.bill.icon),
                    size: 16,
                    color: swatch.on,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bill.name,
                        style: ff(14.5, weight: FontWeight.w600, color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        freqLabel(widget.bill),
                        style: ff(12.5, color: c.muted),
                      ),
                    ],
                  ),
                ),
                if (_hover && !paid)
                  OutlinedButton.icon(
                    onPressed: () =>
                        widget.onMarkPaid(widget.bill, widget.date),
                    icon: Icon(Icons.check_rounded, size: 15, color: c.good),
                    label: Text(
                      'Mark paid',
                      style: ff(12.5, weight: FontWeight.w700, color: c.good),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.good, width: 1.5),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        ffMoney(widget.bill.amount),
                        style: ff(15, weight: FontWeight.w700, color: c.ink),
                      ),
                      Text(
                        paid ? 'Paid' : whenText,
                        style: ff(
                          12,
                          weight: FontWeight.w600,
                          color: paid ? c.good : when,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Every bill in one list. Edit hands the bill back to the panel (which opens
/// the drawer); delete is confirmed here.
///
/// Bills are recurring series, not single dues, so both actions act on the
/// whole series: edits and deletes change what is *scheduled* from now on,
/// while payments already logged live in Transactions and are never touched.
class _AllBillsDialog extends StatelessWidget {
  final JuwaStore store;
  const _AllBillsDialog({required this.store});

  Future<void> _delete(BuildContext context, Bill bill) async {
    final paid = store.transactions.where((t) => t.billId == bill.id).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => FFPopIn(
        child: AlertDialog(
          title: Text('Delete ${bill.name}?'),
          content: Text(
            'Stops this ${freqLabel(bill).split(' · ').first.toLowerCase()} '
            'bill and removes every upcoming due date. '
            '${paid == 0 ? 'No payments are logged for it.' : '$paid logged '
                      '${paid == 1 ? 'payment stays' : 'payments stay'} in '
                      'Transactions.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) await store.deleteBill(bill.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Rebuilds as bills change, so a delete drops its row in place.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final day = DateTime.now();
        final today = DateTime(day.year, day.month, day.day);
        final rows =
            [for (final b in store.bills) (b, JuwaStore.nextDue(b, today))]
              ..sort((a, b) {
                if (a.$2 == null) return b.$2 == null ? 0 : 1;
                if (b.$2 == null) return -1;
                return a.$2!.compareTo(b.$2!);
              });
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All bills',
                          style: ff(18, weight: FontWeight.w800, color: c.ink),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: c.muted),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Text(
                    'Edit or delete changes the whole recurring bill from '
                    'now on. Payments already logged stay as they are.',
                    style: ff(13, color: c.muted),
                  ),
                ),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: Text('No bills yet.', style: ff(14, color: c.muted)),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        for (final (bill, due) in rows)
                          _BillLine(
                            bill: bill,
                            due: due,
                            onEdit: () => Navigator.pop(context, bill),
                            onDelete: () => _delete(context, bill),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillLine extends StatelessWidget {
  final Bill bill;
  final DateTime? due;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _BillLine({
    required this.bill,
    required this.due,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final swatch = swatchFor(bill.color);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.rule)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: swatch.color,
              shape: BoxShape.circle,
            ),
            child: Icon(iconFor(bill.icon), size: 16, color: swatch.on),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ff(14.5, weight: FontWeight.w600, color: c.ink),
                ),
                Text(
                  '${freqLabel(bill)} · ${due == null ? 'no upcoming date' : 'next ${ffDate(due!)}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ff(12.5, color: c.muted),
                ),
              ],
            ),
          ),
          Text(
            ffMoney(bill.amount),
            style: ff(15, weight: FontWeight.w700, color: c.ink),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 19, color: c.muted),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, size: 19, color: c.bad),
          ),
        ],
      ),
    );
  }
}
