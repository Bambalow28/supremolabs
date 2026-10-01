// Ledger tab: month + filters, a keyboard entry row, then rows grouped by
// day. All writes go through JuwaStore.addTransaction — the same rules the
// phone's TransactionEditor uses (billId/paydayId are never set by hand).
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/transactions/transactions_screen.dart'
    show dayLabel, newestFirst;
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';
import 'csv_download.dart';
import 'csv_export.dart';
import 'drawer.dart' show categoryLabel, openTransactionDetail;

class LedgerPanel extends StatefulWidget {
  final JuwaStore store;
  final String searchQuery;
  final void Function(Widget drawer) openDrawer;
  final VoidCallback closeDrawer;

  const LedgerPanel({
    super.key,
    required this.store,
    required this.searchQuery,
    required this.openDrawer,
    required this.closeDrawer,
  });

  @override
  State<LedgerPanel> createState() => _LedgerPanelState();
}

class _LedgerPanelState extends State<LedgerPanel> {
  _Filters _filters = const _Filters();

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  Future<void> _openFilters() async {
    final next = await showDialog<_Filters>(
      context: context,
      builder: (_) => FFPopIn(
        child: _FilterDialog(store: widget.store, initial: _filters),
      ),
    );
    if (next != null) setState(() => _filters = next);
  }

  Future<void> _openExport() => showDialog<void>(
    context: context,
    builder: (_) => FFPopIn(
      child: _ExportDialog(
        store: widget.store,
        month:
            _filters.month ??
            DateTime(DateTime.now().year, DateTime.now().month),
        accountId: _filters.accountId,
      ),
    ),
  );

  // Every transaction id seen on the previous build; null until the first one
  // so the initial list staggers in instead of every row popping.
  Set<String>? _known;

  List<Widget> _byDay(BuildContext context, List<Transaction> shown) {
    final c = context.c;
    final known = _known;
    _known = {for (final t in widget.store.transactions) t.id};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <Widget>[];
    var i = 0;
    DateTime? day;
    for (final (index, t) in shown.indexed) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d != day) {
        day = d;
        final net = shown
            .skip(index)
            .takeWhile(
              (x) => DateTime(x.date.year, x.date.month, x.date.day) == d,
            )
            .fold(0.0, (s, x) => s + x.amount);
        out.add(
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 16, bottom: 8),
            child: Row(
              children: [
                Text(
                  dayLabel(d, today),
                  style: ff(13, weight: FontWeight.w700, color: c.muted),
                ),
                const Spacer(),
                Text(
                  ffAmount(net),
                  style: ff(13, weight: FontWeight.w600, color: c.faint),
                ),
              ],
            ),
          ),
        );
      }
      final row = _TxRow(
        store: widget.store,
        tx: t,
        onTap: () => openTransactionDetail(
          widget.store,
          t,
          openDrawer: widget.openDrawer,
          closeDrawer: widget.closeDrawer,
        ),
      );
      // Keyed by id so a row added at the top is the one that animates, not
      // whichever row the positional state happened to land on.
      out.add(
        known != null && !known.contains(t.id)
            ? _PopIn(key: ValueKey(t.id), child: row)
            : Reveal(key: ValueKey(t.id), index: i++, child: row),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final f = _filters;
    final searching = widget.searchQuery.isNotEmpty;
    var filtered = widget.store.transactions.where((t) {
      // A search spans every month; a picked month narrows to it; otherwise
      // it's simply the most recent, everywhere.
      if (!searching &&
          f.month != null &&
          !(t.date.year == f.month!.year && t.date.month == f.month!.month)) {
        return false;
      }
      if (f.accountId != null && t.accountId != f.accountId) return false;
      if (f.categoryId != null && t.categoryId != f.categoryId) return false;
      if (f.by != null && t.by != f.by) return false;
      if (f.type == _Type.spent && t.amount >= 0) return false;
      if (f.type == _Type.received && t.amount <= 0) return false;
      if (searching) {
        final q = widget.searchQuery.toLowerCase();
        final cat = categoryLabel(widget.store, t.categoryId).toLowerCase();
        if (!t.name.toLowerCase().contains(q) && !cat.contains(q)) return false;
      }
      return true;
    }).toList()..sort(newestFirst);

    final totalIn = filtered
        .where((t) => t.amount > 0)
        .fold(0.0, (s, t) => s + t.amount);
    final totalOut = filtered
        .where((t) => t.amount < 0)
        .fold(0.0, (s, t) => s + -t.amount);
    // Cards aren't lazy, so a long history is capped; the totals above still
    // cover everything the filters match.
    const cap = 100;
    final shown = filtered.take(cap).toList();

    if (widget.store.accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'No accounts yet — add one before logging a transaction.',
          style: ff(15, color: c.muted, weight: FontWeight.w600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transactions',
                  style: ff(
                    32,
                    weight: FontWeight.w800,
                    color: c.ink,
                    spacing: -1,
                  ),
                ),
              ),
              _ToolButton(
                icon: Icons.file_download_outlined,
                label: 'Export',
                onPressed: _openExport,
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: f.count > 0,
                label: Text('${f.count}'),
                backgroundColor: c.ink,
                textColor: c.bg,
                child: _ToolButton(
                  icon: Icons.tune_rounded,
                  label: 'Filters',
                  onPressed: _openFilters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // What's on screen on the left, its totals pushed to the right edge.
          Row(
            children: [
              Expanded(
                child: Text(
                  searching
                      ? 'Search results · every month'
                      : f.month == null
                      ? 'Most recent · ${f.summary(widget.store)}'
                      : '${_monthName(f.month!)} · ${f.summary(widget.store)}',
                  overflow: TextOverflow.ellipsis,
                  style: ff(14, color: c.muted),
                ),
              ),
              const SizedBox(width: 16),
              Text.rich(
                TextSpan(
                  style: ff(13.5, color: c.muted),
                  children: [
                    const TextSpan(text: 'In '),
                    TextSpan(
                      text: ffAmount(totalIn),
                      style: ff(13.5, weight: FontWeight.w700, color: c.good),
                    ),
                    const TextSpan(text: '  ·  Out '),
                    TextSpan(
                      text: ffAmount(totalOut),
                      style: ff(13.5, weight: FontWeight.w700, color: c.bad),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _filters.count > 0 || searching
                    ? 'Nothing matches — loosen the filters.'
                    : 'No transactions yet — the entry row above adds your first.',
                style: ff(14, color: c.muted),
              ),
            )
          else
            // Grouped by day, newest first; each row slides in on its own beat.
            ..._byDay(context, shown),
          if (filtered.length > cap)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Showing the latest $cap of ${filtered.length} — narrow with '
                'Filters, or pick a month.',
                style: ff(12.5, color: c.faint),
              ),
            ),
        ],
      ),
    );
  }
}

String _monthName(DateTime m) =>
    '${_LedgerPanelState._months[m.month - 1]} ${m.year}';

enum _Type { all, spent, received }

/// The ledger's active filters. Immutable; the dialog hands back a new one.
class _Filters {
  final String? accountId;
  final String? categoryId;
  final Owner? by;
  final _Type type;

  /// Null = most recent across every month.
  final DateTime? month;

  const _Filters({
    this.accountId,
    this.categoryId,
    this.by,
    this.type = _Type.all,
    this.month,
  });

  /// How many are narrowing the default view (for the button's badge).
  int get count =>
      (accountId != null ? 1 : 0) +
      (categoryId != null ? 1 : 0) +
      (by != null ? 1 : 0) +
      (type != _Type.all ? 1 : 0) +
      (month != null ? 1 : 0);

  String summary(JuwaStore store) {
    final account = store.accounts
        .where((a) => a.id == accountId)
        .firstOrNull
        ?.name;
    final parts = [
      account ?? 'All accounts',
      if (categoryId != null) categoryLabel(store, categoryId),
      if (by != null) 'by ${by!.label}',
      if (type != _Type.all) type == _Type.spent ? 'spent' : 'received',
    ];
    return parts.join(' · ');
  }
}

class _FilterDialog extends StatefulWidget {
  final JuwaStore store;
  final _Filters initial;
  const _FilterDialog({required this.store, required this.initial});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late _Filters _f = widget.initial;

  // copyWith can't clear a field, so rebuild from parts.
  void _set({
    Object? account = _keep,
    Object? category = _keep,
    Object? by = _keep,
    _Type? type,
    Object? month = _keep,
  }) => setState(
    () => _f = _Filters(
      accountId: identical(account, _keep) ? _f.accountId : account as String?,
      categoryId: identical(category, _keep)
          ? _f.categoryId
          : category as String?,
      by: identical(by, _keep) ? _f.by : by as Owner?,
      type: type ?? _f.type,
      month: identical(month, _keep) ? _f.month : month as DateTime?,
    ),
  );

  static const _keep = Object();

  Widget _chips<T>({
    required List<(String, T?)> options,
    required T? selected,
    required void Function(T?) onPick,
  }) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final o in options)
        ChoiceChip(
          label: Text(o.$1),
          selected: selected == o.$2,
          onSelected: (_) => onPick(o.$2),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = widget.store;
    final month = _f.month;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
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
                      'Filters',
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(c, 'Period'),
                    _chips<bool>(
                      options: const [
                        ('Most recent', false),
                        ('By month', true),
                      ],
                      selected: month != null,
                      onPick: (v) => _set(
                        month: v == true
                            ? DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                              )
                            : null,
                      ),
                    ),
                    if (month != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _MonthArrow(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => _set(
                                month: DateTime(month.year, month.month - 1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                _monthName(month),
                                style: ff(15, color: c.ink),
                              ),
                            ),
                            _MonthArrow(
                              icon: Icons.chevron_right_rounded,
                              onTap: () => _set(
                                month: DateTime(month.year, month.month + 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _label(c, 'Account'),
                    _chips<String>(
                      options: [
                        ('All', null),
                        for (final a in store.accounts) (a.name, a.id),
                      ],
                      selected: _f.accountId,
                      onPick: (v) => _set(account: v),
                    ),
                    _label(c, 'Category'),
                    _chips<String>(
                      options: [
                        ('Any', null),
                        for (final b in store.budgets) (b.name, b.id),
                        for (final cat in store.categories) (cat.name, cat.id),
                      ],
                      selected: _f.categoryId,
                      onPick: (v) => _set(category: v),
                    ),
                    _label(c, 'Added by'),
                    _chips<Owner>(
                      options: [
                        ('All', null),
                        for (final o in Owner.people) (o.title, o),
                      ],
                      selected: _f.by,
                      onPick: (v) => _set(by: v),
                    ),
                    _label(c, 'Type'),
                    _chips<_Type>(
                      options: const [
                        ('All', _Type.all),
                        ('Spent', _Type.spent),
                        ('Received', _Type.received),
                      ],
                      selected: _f.type,
                      onPick: (v) => _set(type: v ?? _Type.all),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, const _Filters()),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _f),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.ink,
                      foregroundColor: c.bg,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(JuwaColors c, String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      t,
      style: ff(12.5, weight: FontWeight.w600, color: c.muted),
    ),
  );
}

/// Pick a month (and optionally one account) and download it as CSV.
class _ExportDialog extends StatefulWidget {
  final JuwaStore store;
  final DateTime month;
  final String? accountId;
  const _ExportDialog({
    required this.store,
    required this.month,
    required this.accountId,
  });

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  late DateTime _month = widget.month;
  late String? _accountId = widget.accountId;

  Iterable<Transaction> get _rows => widget.store.transactions.where(
    (t) =>
        t.date.year == _month.year &&
        t.date.month == _month.month &&
        (_accountId == null || t.accountId == _accountId),
  );

  void _download() {
    final account = widget.store.accounts
        .where((a) => a.id == _accountId)
        .firstOrNull
        ?.name;
    final slug = account?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    downloadCsv(
      'famfi-${_month.year}-${_month.month.toString().padLeft(2, '0')}'
      '${slug == null ? '' : '-$slug'}.csv',
      transactionsCsv(widget.store, _rows),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final count = _rows.length;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export statement',
                style: ff(18, weight: FontWeight.w800, color: c.ink),
              ),
              const SizedBox(height: 4),
              Text(
                'A CSV of one month, oldest first.',
                style: ff(13, color: c.muted),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _MonthArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _monthName(_month),
                      style: ff(16, weight: FontWeight.w600, color: c.ink),
                    ),
                  ),
                  _MonthArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('All accounts'),
                    selected: _accountId == null,
                    onSelected: (_) => setState(() => _accountId = null),
                  ),
                  for (final a in widget.store.accounts)
                    ChoiceChip(
                      label: Text(a.name),
                      selected: _accountId == a.id,
                      onSelected: (_) => setState(() => _accountId = a.id),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                count == 0
                    ? 'No transactions in ${_monthName(_month)}.'
                    : '$count ${count == 1 ? 'transaction' : 'transactions'}',
                style: ff(13.5, color: c.muted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: count == 0 ? null : _download,
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Download CSV'),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.ink,
                      foregroundColor: c.bg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkResponse(
    onTap: onTap,
    radius: 18,
    child: SizedBox(
      width: 28,
      height: 28,
      child: Icon(icon, size: 20, color: context.c.muted),
    ),
  );
}

/// A just-added row: fades in, drops a few px and overshoots its size once.
class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutBack,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, -14 * (1 - t)),
          child: Transform.scale(
            scale: 0.96 + 0.04 * t,
            alignment: Alignment.topCenter,
            child: c,
          ),
        ),
      ),
      child: child,
    );
  }
}

class _TxRow extends StatelessWidget {
  final JuwaStore store;
  final Transaction tx;
  final VoidCallback onTap;
  const _TxRow({required this.store, required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final account = store.accounts
        .where((a) => a.id == tx.accountId)
        .firstOrNull;
    final bill = tx.billId == null
        ? null
        : store.bills.where((b) => b.id == tx.billId).firstOrNull;
    final category = bill != null || tx.categoryId == null
        ? null
        : store.categories.where((cc) => cc.id == tx.categoryId).firstOrNull;
    // The app's own prefix: the bill's, else the category's, else the
    // account's colour, with a payday / dollar glyph when neither has one.
    final swatch = swatchFor(
      bill?.color ?? category?.color ?? account?.color ?? 'graphite',
    );
    final icon = bill != null
        ? iconFor(bill.icon)
        : category != null
        ? iconFor(category.icon)
        : tx.paydayId != null
        ? Icons.volunteer_activism_rounded
        : Icons.attach_money_rounded;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: swatch.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: onSwatchIcon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          tx.name,
                          style: ff(15, weight: FontWeight.w600, color: c.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tx.receipt != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: c.muted,
                        ),
                      ],
                      if (tx.link != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.link_rounded, size: 15, color: c.muted),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: swatchFor(account?.color ?? 'graphite').color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          account?.name ?? '—',
                          style: ff(13, color: c.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    categoryLabel(store, tx.categoryId),
                    style: ff(13, color: c.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Center(child: FFStamp(tx.by.label, color: c.muted)),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    ffAmount(tx.amount),
                    textAlign: TextAlign.right,
                    style: ff(
                      15,
                      weight: FontWeight.w700,
                      color: tx.amount > 0 ? c.good : c.bad,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Export / Filters: one fixed height, icon and label centred in it.
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          side: BorderSide(color: c.rule),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
