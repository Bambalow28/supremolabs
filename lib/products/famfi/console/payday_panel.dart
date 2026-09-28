// Payday tab: two cheques (Josh's and Judy's) + their splits, matching
// PaydayScreen's math (JuwaStore.splitForBoth) exactly — only the layout is
// desktop.
import 'package:flutter/material.dart';
import 'package:juwa_wealth/ui/bills/bills_screen.dart' show freqLabel;
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';
import 'drawer.dart';

String _ownerName(Owner o) =>
    '${o.label[0]}${o.label.substring(1).toLowerCase()}';

class PaydayPanel extends StatelessWidget {
  List<Owner> get _owners => Owner.people;

  final JuwaStore store;
  final Map<Owner, TextEditingController> amountControllers;
  final Map<Owner, FocusNode> amountFocus;
  final Map<Owner, String?> intoAccountId;
  final void Function(Owner owner, String id) onIntoChanged;
  final Map<Owner, DateTime> nextPayday;
  final void Function(Owner owner, DateTime date) onNextPaydayChanged;
  final DateTime today;
  final Map<Owner, SplitResult> splits;
  final VoidCallback onSave;
  final void Function(Widget drawer) openDrawer;
  final VoidCallback closeDrawer;

  const PaydayPanel({
    super.key,
    required this.store,
    required this.amountControllers,
    required this.amountFocus,
    required this.intoAccountId,
    required this.onIntoChanged,
    required this.nextPayday,
    required this.onNextPaydayChanged,
    required this.today,
    required this.splits,
    required this.onSave,
    required this.openDrawer,
    required this.closeDrawer,
  });

  double _amountFor(Owner o) =>
      AmountField.parse(amountControllers[o]!.text) ?? 0;

  Future<void> _pickInto(BuildContext context, Owner owner) async {
    final id = await pickFrom<String>(
      context,
      title: 'Deposited into',
      items: [for (final a in store.accounts) (a.name, a.id)],
    );
    if (id != null) onIntoChanged(owner, id);
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      builder: (_, child) => FFPopIn(child: child!),
    );
    if (d != null) onPicked(DateTime(d.year, d.month, d.day));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (store.accounts.isEmpty) {
      return _empty(c, 'No accounts yet — add one to run payday.');
    }
    final due = _owners.fold(0.0, (s, o) {
      final split = splits[o];
      if (split == null) return s;
      return s +
          split.groups.fold(0.0, (s2, g) => s2 + g.total) +
          split.unassigned.fold(0.0, (s2, o2) => s2 + o2.subtotal);
    });

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
                'Payday',
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
                      const TextSpan(
                        text: 'Bills due before the next cheque · ',
                      ),
                      TextSpan(
                        text: ffMoney(due),
                        style: ff(14.5, weight: FontWeight.w700, color: c.ink),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, cons) {
              final stacked = cons.maxWidth < 760;
              final form = Column(
                children: [
                  for (final o in _owners) ...[
                    if (o != _owners.first) const SizedBox(height: 16),
                    _ChequeForm(
                      owner: o,
                      controller: amountControllers[o]!,
                      focusNode: amountFocus[o]!,
                      into: store.accounts
                          .where((a) => a.id == intoAccountId[o])
                          .firstOrNull,
                      onPickInto: () => _pickInto(context, o),
                      paidOn: today,
                      nextPayday: nextPayday[o]!,
                      onPickNextPayday: () => _pickDate(
                        context,
                        nextPayday[o]!,
                        (d) => onNextPaydayChanged(o, d),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (store.paydays.isNotEmpty)
                    GestureDetector(
                      onTap: () => openDrawer(
                        PaydayHistoryDrawer(store: store, onClose: closeDrawer),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: c.faint),
                          const SizedBox(width: 6),
                          Text(
                            '${store.paydays.length} earlier '
                            '${store.paydays.length == 1 ? 'payday' : 'paydays'} · view history',
                            style: ff(12.5, color: c.faint),
                          ),
                        ],
                      ),
                    ),
                ],
              );
              final right = _SplitAndLeft(
                store: store,
                splits: splits,
                amountOf: _amountFor,
                intoAccountId: intoAccountId,
                nextPayday: nextPayday,
                onSave: onSave,
                openDrawer: openDrawer,
                closeDrawer: closeDrawer,
              );
              if (stacked) {
                return Column(
                  children: [form, const SizedBox(height: 24), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: form),
                  const SizedBox(width: 24),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _empty(dynamic c, String msg) => Padding(
    padding: const EdgeInsets.all(40),
    child: Text(
      msg,
      style: ff(15, color: c.muted, weight: FontWeight.w600),
    ),
  );
}

/// One owner's cheque card: amount field, deposit account, paid-on/next
/// payday dates. No "Whose" toggle — the owner is fixed per card.
class _ChequeForm extends StatelessWidget {
  final Owner owner;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Account? into;
  final VoidCallback onPickInto;
  final DateTime paidOn;
  final DateTime nextPayday;
  final VoidCallback onPickNextPayday;

  const _ChequeForm({
    required this.owner,
    required this.controller,
    required this.focusNode,
    required this.into,
    required this.onPickInto,
    required this.paidOn,
    required this.nextPayday,
    required this.onPickNextPayday,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_ownerName(owner)}'s cheque",
            style: ff(12, weight: FontWeight.w600, color: c.muted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.rule, width: 2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '\$',
                    style: ff(20, weight: FontWeight.w800, color: c.faint),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [MoneyTextFormatter()],
                    style: ff(38, weight: FontWeight.w800, color: c.ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Deposited into',
            style: ff(12, weight: FontWeight.w600, color: c.muted),
          ),
          const SizedBox(height: 6),
          DPickerButton(
            onTap: onPickInto,
            child: Row(
              children: [
                if (into != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: swatchFor(into!.color).color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  into?.name ?? 'Choose account',
                  style: ff(14, color: c.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateField(label: 'Paid on', date: paidOn, onTap: null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Next payday',
                  date: nextPayday,
                  onTap: onPickNextPayday,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback? onTap;
  const _DateField({required this.label, required this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ff(12, weight: FontWeight.w600, color: c.muted),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.event_rounded, size: 15, color: c.faint),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Text(
                    ffDate(date),
                    style: ff(13.5, weight: FontWeight.w600, color: c.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplitAndLeft extends StatelessWidget {
  List<Owner> get _owners => Owner.people;

  final JuwaStore store;
  final Map<Owner, SplitResult> splits;
  final double Function(Owner) amountOf;
  final Map<Owner, String?> intoAccountId;
  final Map<Owner, DateTime> nextPayday;
  final VoidCallback onSave;
  final void Function(Widget drawer) openDrawer;
  final VoidCallback closeDrawer;

  const _SplitAndLeft({
    required this.store,
    required this.splits,
    required this.amountOf,
    required this.intoAccountId,
    required this.nextPayday,
    required this.onSave,
    required this.openDrawer,
    required this.closeDrawer,
  });

  Future<void> _pickBillAccount(BuildContext context, Bill bill) async {
    final id = await pickFrom<String>(
      context,
      title: 'Choose account',
      items: [for (final a in store.accounts) (a.name, a.id)],
    );
    if (id != null) store.updateBill(bill.copyWith(accountId: id));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final canSave = _owners.any((o) => amountOf(o) > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // splits already comes back ordered earliest-next-payday-first (see
        // JuwaStore.splitForBoth), so this iterates in that order.
        for (final entry in splits.entries) ...[
          if (entry.key != splits.keys.first) const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                FFStamp(entry.key.label, color: c.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${_ownerName(entry.key)}'s cheque · covers until "
                    '${ffDate(nextPayday[entry.key]!)}',
                    overflow: TextOverflow.ellipsis,
                    style: ff(13.5, weight: FontWeight.w600, color: c.muted),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: entry.value.groups.isEmpty && entry.value.unassigned.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No bills due before the next payday.',
                      style: ff(14, color: c.muted),
                    ),
                  )
                : Column(
                    children: [
                      for (final g in entry.value.groups)
                        _Group(
                          store: store,
                          group: g,
                          onPickAccount: (b) => _pickBillAccount(context, b),
                        ),
                      if (entry.value.unassigned.isNotEmpty)
                        _UnassignedGroup(
                          store: store,
                          occurrences: entry.value.unassigned,
                          onPickAccount: (b) => _pickBillAccount(context, b),
                        ),
                    ],
                  ),
          ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.rule),
          ),
          // Totals and the action share the top line; what the save will
          // write gets the full width below instead of a squeezed 3-line
          // column between them.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        for (final o in _owners) ...[
                          if (o != _owners.first) const SizedBox(width: 24),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_ownerName(o)} left',
                                  style: ff(12, color: c.muted),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    ffMoney(splits[o]?.left ?? 0),
                                    style: ff(
                                      20,
                                      weight: FontWeight.w800,
                                      color: (splits[o]?.left ?? 0) < 0
                                          ? c.bad
                                          : c.good,
                                      spacing: -0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  FilledButton(
                    onPressed: canSave ? onSave : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: c.ink,
                      foregroundColor: c.bg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Save payday ⌘↵'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.rule)),
                ),
                child: Text(
                  _writeSummary(),
                  style: ff(12.5, color: c.muted, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _writeSummary() {
    final parts = <String>[];
    var txCount = 0;
    for (final o in _owners) {
      final amount = amountOf(o);
      final intoId = intoAccountId[o];
      final split = splits[o];
      if (amount <= 0 || intoId == null || split == null) continue;
      final into = store.accounts.where((a) => a.id == intoId).firstOrNull;
      final transfers = split.groups.where((g) => !g.stays).toList();
      txCount += 1 + transfers.length * 2;
      final transferText = transfers.isEmpty
          ? ''
          : ', ${transfers.map((g) => '${ffMoney(g.total)} → ${store.accounts.where((a) => a.id == g.accountId).firstOrNull?.name ?? 'account'}').join(', ')}';
      parts.add(
        '${_ownerName(o)}: ${ffMoney(amount)} into ${into?.name ?? 'account'}$transferText',
      );
    }
    if (parts.isEmpty) return 'Enter an amount for at least one cheque.';
    return 'Writes $txCount transaction${txCount == 1 ? '' : 's'}: '
        '${parts.join('. ')}.';
  }
}

class _Group extends StatelessWidget {
  final JuwaStore store;
  final SplitGroup group;
  final void Function(Bill) onPickAccount;
  const _Group({
    required this.store,
    required this.group,
    required this.onPickAccount,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final account = store.accounts
        .where((a) => a.id == group.accountId)
        .firstOrNull;
    final swatch = swatchFor(account?.color ?? 'graphite');
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: swatch.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  account?.name ?? 'Deleted account',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ff(15, weight: FontWeight.w700, color: c.ink),
                ),
              ),
              const SizedBox(width: 8),
              FFStamp(account?.owner.label ?? '', color: c.muted),
              const SizedBox(width: 8),
              Text(
                group.stays ? 'stays' : 'transfer',
                style: ff(13, color: c.muted),
              ),
              const Spacer(),
              Text(
                ffMoney(group.total),
                style: ff(16, weight: FontWeight.w800, color: c.ink),
              ),
            ],
          ),
          for (final b in group.bills)
            _BillRow(
              bill: b,
              accountName: account?.name,
              accountColor: swatch.color,
              onPickAccount: () => onPickAccount(b.bill),
            ),
        ],
      ),
    );
  }
}

class _UnassignedGroup extends StatelessWidget {
  final JuwaStore store;
  final List<BillOccurrence> occurrences;
  final void Function(Bill) onPickAccount;
  const _UnassignedGroup({
    required this.store,
    required this.occurrences,
    required this.onPickAccount,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: c.fill,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: c.warn, width: 1.5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Not assigned yet',
                style: ff(15, weight: FontWeight.w700, color: c.ink),
              ),
            ],
          ),
          for (final o in occurrences)
            _BillRow(
              bill: o,
              accountName: null,
              accountColor: c.warn,
              onPickAccount: () => onPickAccount(o.bill),
              unassigned: true,
            ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final BillOccurrence bill;
  final String? accountName;
  final Color accountColor;
  final VoidCallback onPickAccount;
  final bool unassigned;
  const _BillRow({
    required this.bill,
    required this.accountName,
    required this.accountColor,
    required this.onPickAccount,
    this.unassigned = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final swatch = swatchFor(bill.bill.color);
    final date = bill.dates.first;
    final today = DateTime.now();
    final diff = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    final Color when;
    final String dateText;
    if (diff <= 0) {
      when = c.bad;
      dateText = 'Today';
    } else if (diff <= 3) {
      when = c.warn;
      dateText = ffDate(date);
    } else {
      when = c.muted;
      dateText = ffDate(date);
    }
    final sub = bill.dates.length > 1
        ? '${freqLabel(bill.bill)} · ×${bill.dates.length}'
        : freqLabel(bill.bill);
    final icon = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: swatch.color, shape: BoxShape.circle),
      child: Icon(iconFor(bill.bill.icon), size: 15, color: swatch.on),
    );
    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bill.bill.name,
          style: ff(14.5, weight: FontWeight.w600, color: c.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ff(12, color: c.muted),
        ),
      ],
    );
    final dateLabel = Text(
      dateText,
      style: ff(13, weight: FontWeight.w600, color: when),
    );
    final picker = unassigned
        ? DPickerButton(
            onTap: onPickAccount,
            outline: c.warn,
            child: Text(
              'Choose account',
              style: ff(13, weight: FontWeight.w600, color: c.warn),
            ),
          )
        : DPickerButton(
            onTap: onPickAccount,
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: accountColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    accountName ?? '',
                    style: ff(13, weight: FontWeight.w600, color: c.ink),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
    final amount = Text(
      ffMoney(bill.subtotal),
      textAlign: TextAlign.right,
      style: ff(15, weight: FontWeight.w700, color: c.ink),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      // One line while there's room; with the accounts rail open the panel is
      // narrower than the five columns need, so the amount would be cut off.
      // Then the date and account picker drop under the name.
      child: LayoutBuilder(
        builder: (context, cons) {
          if (cons.maxWidth >= 640) {
            return Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(flex: 3, child: name),
                const SizedBox(width: 16),
                SizedBox(width: 100, child: dateLabel),
                const SizedBox(width: 16),
                SizedBox(width: 170, child: picker),
                const SizedBox(width: 16),
                SizedBox(width: 90, child: amount),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 14),
                  Expanded(child: name),
                  const SizedBox(width: 12),
                  amount,
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: Row(
                  children: [
                    SizedBox(width: 84, child: dateLabel),
                    Expanded(child: picker),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
