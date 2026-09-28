// Ledger tab: month + filters, a keyboard entry row, then rows grouped by
// day. All writes go through JuwaStore.addTransaction — the same rules the
// phone's TransactionEditor uses (billId/paydayId are never set by hand).
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';
import 'drawer.dart'
    show TransactionDrawer, DPickerButton, categoryLabel, pickFrom;

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
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  String? _accountFilter;
  String? _categoryFilter;
  Owner? _byFilter;

  final _entryName = TextEditingController();
  final _entryAmount = TextEditingController();
  String? _entryAccountId;
  String? _entryCategoryId;
  Owner _entryBy = Owner.josh;
  DateTime _entryDate = DateTime.now();
  bool _entryNegative = true;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _entryName.dispose();
    _entryAmount.dispose();
    super.dispose();
  }

  int _categoryFilterIndex() {
    if (_categoryFilter == null) return 0;
    final bi = widget.store.budgets.indexWhere((b) => b.id == _categoryFilter);
    if (bi >= 0) return 1 + bi;
    final ci = widget.store.categories.indexWhere(
      (c) => c.id == _categoryFilter,
    );
    return ci >= 0 ? 1 + widget.store.budgets.length + ci : 0;
  }

  void _addEntry() {
    final amt = AmountField.parse(_entryAmount.text);
    if (amt == null || amt == 0 || _entryAccountId == null) return;
    widget.store.addTransaction(
      Transaction(
        id: widget.store.newId(),
        accountId: _entryAccountId!,
        amount: _entryNegative ? -amt.abs() : amt.abs(),
        date: _entryDate,
        name: _entryName.text.trim().isEmpty
            ? (_entryNegative ? 'Spent' : 'Received')
            : _entryName.text.trim(),
        categoryId: _entryCategoryId,
        by: _entryBy,
      ),
    );
    _entryName.clear();
    _entryAmount.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Re-default if the remembered account was deleted since.
    if (!widget.store.accounts.any((a) => a.id == _entryAccountId)) {
      _entryAccountId = widget.store.accounts.firstOrNull?.id;
    }

    final monthTx = widget.store.transactions.where(
      // A search spans every month; browsing sticks to the one shown.
      (t) =>
          widget.searchQuery.isNotEmpty ||
          (t.date.year == _month.year && t.date.month == _month.month),
    );
    var filtered = monthTx.where((t) {
      if (_accountFilter != null && t.accountId != _accountFilter) return false;
      if (_categoryFilter != null && t.categoryId != _categoryFilter) {
        return false;
      }
      if (_byFilter != null && t.by != _byFilter) return false;
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery.toLowerCase();
        final cat = categoryLabel(widget.store, t.categoryId).toLowerCase();
        if (!t.name.toLowerCase().contains(q) && !cat.contains(q)) return false;
      }
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final totalIn = filtered
        .where((t) => t.amount > 0)
        .fold(0.0, (s, t) => s + t.amount);
    final totalOut = filtered
        .where((t) => t.amount < 0)
        .fold(0.0, (s, t) => s + t.amount);

    final byDay = <DateTime, List<Transaction>>{};
    for (final t in filtered) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      byDay.putIfAbsent(d, () => []).add(t);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    if (widget.store.accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'No accounts yet — add one before logging a transaction.',
          style: ff(15, color: c.muted, weight: FontWeight.w600),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 4, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Ledger',
                style: ff(
                  32,
                  weight: FontWeight.w800,
                  color: c.ink,
                  spacing: -1,
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: c.muted,
                ),
              ),
              Text(
                '${_months[_month.month - 1]} ${_month.year}',
                style: ff(15, color: c.muted),
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: c.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilterPill(
                      label: _accountFilter == null
                          ? 'All accounts'
                          : (widget.store.accounts
                                    .where((a) => a.id == _accountFilter)
                                    .firstOrNull
                                    ?.name ??
                                'All accounts'),
                      options: [
                        'All accounts',
                        for (final a in widget.store.accounts) a.name,
                      ],
                      selected: _accountFilter == null
                          ? 0
                          : widget.store.accounts.indexWhere(
                                  (a) => a.id == _accountFilter,
                                ) +
                                1,
                      onChanged: (i) => setState(
                        () => _accountFilter = i == 0
                            ? null
                            : widget.store.accounts[i - 1].id,
                      ),
                    ),
                    FilterPill(
                      label: _categoryFilter == null
                          ? 'Any category'
                          : categoryLabel(widget.store, _categoryFilter),
                      options: [
                        'Any category',
                        for (final b in widget.store.budgets) b.name,
                        for (final cat in widget.store.categories) cat.name,
                      ],
                      selected: _categoryFilterIndex(),
                      onChanged: (i) {
                        if (i == 0) {
                          return setState(() => _categoryFilter = null);
                        }
                        final bi = i - 1;
                        if (bi < widget.store.budgets.length) {
                          setState(
                            () => _categoryFilter = widget.store.budgets[bi].id,
                          );
                        } else {
                          setState(
                            () => _categoryFilter = widget
                                .store
                                .categories[bi - widget.store.budgets.length]
                                .id,
                          );
                        }
                      },
                    ),
                    FilterPill(
                      label: _byFilter == null
                          ? 'Either of us'
                          : _byFilter!.label,
                      options: const ['Either of us', 'JOSH', 'JUDY'],
                      selected: _byFilter == null
                          ? 0
                          : (_byFilter == Owner.josh ? 1 : 2),
                      onChanged: (i) => setState(
                        () => _byFilter = i == 0
                            ? null
                            : (i == 1 ? Owner.josh : Owner.judy),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    style: ff(13.5, color: c.muted),
                    children: [
                      const TextSpan(text: 'In '),
                      TextSpan(
                        text: ffMoney(totalIn, sign: true),
                        style: ff(13.5, weight: FontWeight.w700, color: c.good),
                      ),
                      const TextSpan(text: ' · Out '),
                      TextSpan(
                        text: ffMoney(totalOut),
                        style: ff(13.5, weight: FontWeight.w700, color: c.ink),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _EntryRow(
                  store: widget.store,
                  name: _entryName,
                  amount: _entryAmount,
                  accountId: _entryAccountId,
                  onAccountChanged: (v) => setState(() => _entryAccountId = v),
                  categoryId: _entryCategoryId,
                  onCategoryChanged: (v) =>
                      setState(() => _entryCategoryId = v),
                  by: _entryBy,
                  onByChanged: (v) => setState(() => _entryBy = v),
                  date: _entryDate,
                  onDateChanged: (v) => setState(() => _entryDate = v),
                  negative: _entryNegative,
                  onSignChanged: (v) => setState(() => _entryNegative = v),
                  onSubmit: _addEntry,
                ),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No transactions yet — the entry row above adds your first.',
                      style: ff(14, color: c.muted),
                    ),
                  )
                else
                  // Each day arrives as one beat, top day first.
                  for (final (di, day) in days.indexed) ...[
                    Reveal(
                      index: di,
                      child: _DayHeader(
                        day: day,
                        net: byDay[day]!.fold(0.0, (s, t) => s + t.amount),
                      ),
                    ),
                    for (final t in byDay[day]!)
                      Reveal(
                        index: di,
                        child: _TxRow(
                          store: widget.store,
                          tx: t,
                          onTap: () => widget.openDrawer(
                            TransactionDrawer(
                              store: widget.store,
                              transaction: t,
                              onClose: widget.closeDrawer,
                            ),
                          ),
                        ),
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final double net;
  const _DayHeader({required this.day, required this.net});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            ffDate(day),
            style: ff(12.5, weight: FontWeight.w600, color: c.muted),
          ),
          const Spacer(),
          Text(
            ffMoney(net, sign: true),
            style: ff(12.5, weight: FontWeight.w600, color: c.muted),
          ),
        ],
      ),
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
    final swatch = swatchFor(account?.color ?? 'graphite');
    final tag = tx.billId != null
        ? 'Bill'
        : (tx.paydayId != null ? 'Payday' : null);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(ffDate(tx.date), style: ff(13, color: c.muted)),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        tx.name,
                        style: ff(14, color: c.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tx.receipt != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 13,
                        color: c.muted,
                      ),
                    ],
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.fill,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          tag,
                          style: ff(
                            10.5,
                            weight: FontWeight.w600,
                            color: c.muted,
                          ),
                        ),
                      ),
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
                        color: swatch.color,
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
              SizedBox(width: 60, child: FFStamp(tx.by.label, color: c.muted)),
              SizedBox(
                width: 100,
                child: Text(
                  ffMoney(tx.amount, sign: true),
                  textAlign: TextAlign.right,
                  style: ff(
                    14.5,
                    weight: FontWeight.w700,
                    color: tx.amount > 0 ? c.good : c.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final JuwaStore store;
  final TextEditingController name;
  final TextEditingController amount;
  final String? accountId;
  final ValueChanged<String> onAccountChanged;
  final String? categoryId;
  final ValueChanged<String?> onCategoryChanged;
  final Owner by;
  final ValueChanged<Owner> onByChanged;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final bool negative;
  final ValueChanged<bool> onSignChanged;
  final VoidCallback onSubmit;

  const _EntryRow({
    required this.store,
    required this.name,
    required this.amount,
    required this.accountId,
    required this.onAccountChanged,
    required this.categoryId,
    required this.onCategoryChanged,
    required this.by,
    required this.onByChanged,
    required this.date,
    required this.onDateChanged,
    required this.negative,
    required this.onSignChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final account = store.accounts.where((a) => a.id == accountId).firstOrNull;

    final dateField = SizedBox(
      width: 96,
      child: GestureDetector(
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (_, child) => FFPopIn(child: child!),
          );
          if (d != null) onDateChanged(DateTime(d.year, d.month, d.day));
        },
        child: Text(
          ffDate(date),
          style: ff(13, weight: FontWeight.w700, color: c.ink),
        ),
      ),
    );
    final nameField = TextField(
      controller: name,
      style: ff(14, color: c.ink),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Name — e.g. Loblaws',
        hintStyle: ff(14, color: c.faint),
      ),
    );
    final accountField = DPickerButton(
      onTap: () async {
        final id = await pickFrom<String>(
          context,
          title: 'Account',
          items: [for (final a in store.accounts) (a.name, a.id)],
        );
        if (id != null) onAccountChanged(id);
      },
      child: Text(
        account?.name ?? 'Account',
        style: ff(13, color: c.ink),
        overflow: TextOverflow.ellipsis,
      ),
    );
    final categoryField = DPickerButton(
      onTap: () async {
        final items = <(String, String?)>[
          ('None', null),
          for (final b in store.budgets) ('${b.name} (Budget)', b.id),
          for (final cat in store.categories) (cat.name, cat.id),
        ];
        final id = await pickFrom<String?>(
          context,
          title: 'Category',
          items: items,
        );
        onCategoryChanged(id);
      },
      child: Text(
        categoryLabel(store, categoryId),
        style: ff(13, color: c.ink),
        overflow: TextOverflow.ellipsis,
      ),
    );
    final ownerField = SizedBox(
      width: 128,
      child: SegmentedTabs(
        labels: const ['Josh', 'Judy'],
        selected: by == Owner.josh ? 0 : 1,
        onChanged: (i) => onByChanged(i == 0 ? Owner.josh : Owner.judy),
      ),
    );
    final signField = SizedBox(
      width: 76,
      child: SegmentedTabs(
        labels: const ['−', '+'],
        selected: negative ? 0 : 1,
        onChanged: (i) => onSignChanged(i == 0),
      ),
    );
    final amountField = SizedBox(
      width: 110,
      child: TextField(
        controller: amount,
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: const [MoneyTextFormatter()],
        style: ff(14, weight: FontWeight.w700, color: c.ink),
        decoration: InputDecoration(
          isDense: true,
          prefixText: r'$',
          hintText: '0.00',
          hintStyle: ff(14, color: c.faint),
        ),
        onSubmitted: (_) => onSubmit(),
      ),
    );

    return LayoutBuilder(
      builder: (context, cons) {
        // Seven fields in one Row crush the account/category pickers to
        // nothing once the fixed-width fields (date/owner/sign/amount, ~460px)
        // eat most of a tablet-width panel — two rows instead, same fields.
        final stacked = cons.maxWidth < 720;
        return Container(
          color: c.bg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        dateField,
                        const SizedBox(width: 10),
                        Expanded(child: nameField),
                        const SizedBox(width: 10),
                        amountField,
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: accountField),
                        const SizedBox(width: 10),
                        Expanded(child: categoryField),
                        const SizedBox(width: 10),
                        ownerField,
                        const SizedBox(width: 10),
                        signField,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    dateField,
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: nameField),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: accountField),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: categoryField),
                    const SizedBox(width: 10),
                    ownerField,
                    const SizedBox(width: 10),
                    signField,
                    const SizedBox(width: 10),
                    amountField,
                  ],
                ),
        );
      },
    );
  }
}
