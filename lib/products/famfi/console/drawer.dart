// The slide-in drawer's contents: account, transaction, bill and budget
// editors, plus payday history. All are compact desktop forms over the same
// JuwaStore API the phone editors use — no full-screen Scaffold, since these
// live inside a 440px panel.
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/bills/bills_screen.dart' show freqLabel;
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';

/// Resolves a transaction's `categoryId` to a display name — a budget first,
/// then a custom category, 'None' when unset or deleted. Reimplemented here
/// (not imported from juwa_wealth's transaction_editor.dart) because that
/// file pulls in `dart:io` for receipt photos, which breaks the web build.
String categoryLabel(JuwaStore store, String? categoryId) {
  if (categoryId == null) return 'None';
  final budget = store.budgets.where((b) => b.id == categoryId).firstOrNull;
  if (budget != null) return budget.name;
  final category = store.categories
      .where((c) => c.id == categoryId)
      .firstOrNull;
  return category?.name ?? 'None';
}

/// Common drawer chrome: title + close, 28px padding, 20px between fields.
class DrawerScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<Widget> children;
  final Widget? footer;

  const DrawerScaffold({
    super.key,
    required this.title,
    required this.onClose,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 440,
      color: c.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ff(16, weight: FontWeight.w700, color: c.ink),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close_rounded, color: c.muted),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 20),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: footer,
            ),
        ],
      ),
    );
  }
}

class DField extends StatelessWidget {
  final String label;
  final Widget child;
  const DField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ff(12, weight: FontWeight.w600, color: c.muted, spacing: 0.2),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class DPickerButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? outline;
  const DPickerButton({
    super.key,
    required this.child,
    required this.onTap,
    this.outline,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: outline == null
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outline!, width: 1.5),
                ),
          child: Row(
            children: [
              Expanded(child: child),
              const SizedBox(width: 6),
              Icon(Icons.unfold_more_rounded, size: 16, color: c.faint),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> pickFrom<T>(
  BuildContext context, {
  required String title,
  required List<(String, T)> items,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 320,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in items)
              ListTile(
                title: Text(item.$1),
                onTap: () => Navigator.pop(ctx, item.$2),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required VoidCallback onConfirm,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
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
  );
  if (ok == true) onConfirm();
}

/// Colour swatch grid, reused by every editor.
class SwatchGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const SwatchGrid({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in juwaSwatches)
          GestureDetector(
            onTap: () => onChanged(s.key),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: s.color,
                shape: BoxShape.circle,
                border: selected == s.key
                    ? Border.all(color: c.ink, width: 2)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// Icon grid, reused by every editor.
class IconGrid extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeOn;
  final ValueChanged<String> onChanged;
  const IconGrid({
    super.key,
    required this.selected,
    required this.activeColor,
    required this.activeOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in juwaIcons.keys)
          GestureDetector(
            onTap: () => onChanged(key),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected == key ? activeColor : c.fill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                juwaIcons[key],
                size: 18,
                color: selected == key ? activeOn : c.muted,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- account

class AccountDrawer extends StatefulWidget {
  final JuwaStore store;
  final Account? account;
  final VoidCallback onClose;
  const AccountDrawer({
    super.key,
    required this.store,
    this.account,
    required this.onClose,
  });

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  late final _name = TextEditingController(text: widget.account?.name ?? '');
  late final _balance = TextEditingController(
    text: widget.account == null
        ? ''
        : AmountField.format(widget.account!.balance.abs()),
  );
  late AccountKind _kind = widget.account?.kind ?? AccountKind.chequing;
  late Owner _owner = widget.account?.owner ?? Owner.josh;
  late String _color = widget.account?.color ?? juwaSwatches.first.key;
  late String _icon = widget.account?.icon ?? juwaIcons.keys.first;

  bool get _editing => widget.account != null;
  bool get _owes => _kind == AccountKind.credit || _kind == AccountKind.loc;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final bal = AmountField.parse(_balance.text);
    if (name.isEmpty || bal == null) return;
    final store = widget.store;
    final account = Account(
      id: widget.account?.id ?? store.newId(),
      name: name,
      icon: _icon,
      color: _color,
      kind: _kind,
      owner: _owner,
      balance: _owes ? -bal.abs() : bal.abs(),
    );
    if (_editing) {
      await store.updateAccount(account);
    } else {
      await store.addAccount(account);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final swatch = swatchFor(_color);
    return DrawerScaffold(
      title: _editing ? 'Edit account' : 'New account',
      onClose: widget.onClose,
      footer: SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: swatch.color,
            foregroundColor: swatch.on,
          ),
          child: Text(_editing ? 'Save' : 'Create account'),
        ),
      ),
      children: [
        FFCard(
          name: _name.text.isEmpty ? 'New account' : _name.text,
          kind: _kind.label,
          stamp: _owner.label,
          color: _color,
          icon: _icon,
          balance: AmountField.parse(_balance.text) ?? 0,
          height: 90,
        ),
        DField(
          label: 'Name',
          child: TextField(
            controller: _name,
            style: ff(15, color: c.ink),
            decoration: const InputDecoration(),
            onChanged: (_) => setState(() {}),
          ),
        ),
        DField(
          label: _owes ? 'Amount owed' : 'Starting balance',
          child: AmountField(
            controller: _balance,
            fontSize: 16,
            onChanged: (_) => setState(() {}),
          ),
        ),
        DField(
          label: 'Type',
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in AccountKind.values)
                ChoiceChip(
                  label: Text(k.label),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ],
          ),
        ),
        DField(
          label: 'Owner',
          child: SegmentedTabs(
            labels: const ['Josh', 'Judy', 'Joint'],
            selected: Owner.values.indexOf(_owner),
            onChanged: (i) => setState(() => _owner = Owner.values[i]),
          ),
        ),
        DField(
          label: 'Colour',
          child: SwatchGrid(
            selected: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        DField(
          label: 'Icon',
          child: IconGrid(
            selected: _icon,
            activeColor: swatch.color,
            activeOn: swatch.on,
            onChanged: (v) => setState(() => _icon = v),
          ),
        ),
        if (widget.account != null) ...[
          Builder(
            builder: (context) {
              final recent =
                  widget.store.transactions
                      .where((t) => t.accountId == widget.account!.id)
                      .toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
              return DField(
                label: 'Recent',
                child: recent.isEmpty
                    ? Text('No transactions yet', style: ff(13, color: c.muted))
                    : Column(
                        children: [
                          for (final t in recent.take(5))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.name,
                                      style: ff(13.5, color: c.ink),
                                    ),
                                  ),
                                  Text(
                                    ffMoney(t.amount, sign: true),
                                    style: ff(
                                      13.5,
                                      weight: FontWeight.w700,
                                      color: t.amount > 0 ? c.good : c.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            onPressed: () => _confirm(
              context,
              title: 'Delete account?',
              body:
                  'This removes the account. Bills pointing to it become unassigned.',
              onConfirm: () async {
                await widget.store.deleteAccount(widget.account!.id);
                widget.onClose();
              },
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.bad,
              side: BorderSide(color: c.rule),
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Delete account'),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ transaction

class TransactionDrawer extends StatefulWidget {
  final JuwaStore store;
  final Transaction? transaction;
  final VoidCallback onClose;
  const TransactionDrawer({
    super.key,
    required this.store,
    this.transaction,
    required this.onClose,
  });

  @override
  State<TransactionDrawer> createState() => _TransactionDrawerState();
}

class _TransactionDrawerState extends State<TransactionDrawer> {
  late final _amount = TextEditingController(
    text: widget.transaction == null
        ? ''
        : AmountField.format(widget.transaction!.amount.abs()),
  );
  late final _name = TextEditingController(
    text: widget.transaction?.name ?? '',
  );
  late bool _received =
      widget.transaction != null && widget.transaction!.amount > 0;
  late String? _accountId =
      widget.transaction?.accountId ??
      (widget.store.accounts.isEmpty ? null : widget.store.accounts.first.id);
  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late String? _categoryId = widget.transaction?.categoryId;
  late Owner _by = widget.transaction?.by ?? Owner.josh;

  bool get _editing => widget.transaction != null;

  @override
  void dispose() {
    _amount.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAccount() async {
    final id = await pickFrom<String>(
      context,
      title: 'Account',
      items: [for (final a in widget.store.accounts) (a.name, a.id)],
    );
    if (id != null) setState(() => _accountId = id);
  }

  Future<void> _pickCategory() async {
    final items = <(String, String?)>[
      ('None', null),
      for (final b in widget.store.budgets) ('${b.name} (Budget)', b.id),
      for (final cat in widget.store.categories) (cat.name, cat.id),
    ];
    final id = await pickFrom<String?>(
      context,
      title: 'Category',
      items: items,
    );
    setState(() => _categoryId = id);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day));
  }

  Future<void> _save() async {
    final amt = AmountField.parse(_amount.text);
    if (amt == null || amt == 0 || _accountId == null) return;
    final store = widget.store;
    final id = widget.transaction?.id ?? store.newId();
    final tx = Transaction(
      id: id,
      accountId: _accountId!,
      amount: _received ? amt.abs() : -amt.abs(),
      date: _date,
      name: _name.text.trim().isEmpty
          ? (_received ? 'Received' : 'Spent')
          : _name.text.trim(),
      categoryId: _categoryId,
      billId: widget.transaction?.billId,
      paydayId: widget.transaction?.paydayId,
      by: _by,
    );
    if (_editing) {
      await store.updateTransaction(tx);
    } else {
      await store.addTransaction(tx);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final account = widget.store.accounts
        .where((a) => a.id == _accountId)
        .firstOrNull;
    final swatch = swatchFor(account?.color ?? juwaSwatches.first.key);
    final locked =
        widget.transaction?.billId != null ||
        widget.transaction?.paydayId != null;
    return DrawerScaffold(
      title: _editing ? 'Edit transaction' : 'New transaction',
      onClose: widget.onClose,
      footer: SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: swatch.color,
            foregroundColor: swatch.on,
          ),
          child: Text(_editing ? 'Save' : 'Add transaction'),
        ),
      ),
      children: [
        if (locked)
          Text(
            'Written automatically — editing amount/account may drift from what it records.',
            style: ff(12, color: c.warn),
          ),
        DField(
          label: 'Amount',
          child: Row(
            children: [
              SegmentedTabs(
                labels: const ['−', '+'],
                selected: _received ? 1 : 0,
                onChanged: (i) => setState(() => _received = i == 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AmountField(
                  controller: _amount,
                  fontSize: 18,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        DField(
          label: 'Name',
          child: TextField(
            controller: _name,
            style: ff(15, color: c.ink),
          ),
        ),
        DField(
          label: 'Account',
          child: DPickerButton(
            onTap: _pickAccount,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: swatch.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  account?.name ?? 'Choose account',
                  style: ff(14, color: c.ink),
                ),
              ],
            ),
          ),
        ),
        DField(
          label: 'Date',
          child: DPickerButton(
            onTap: _pickDate,
            child: Text(ffDate(_date), style: ff(14, color: c.ink)),
          ),
        ),
        DField(
          label: 'Category',
          child: DPickerButton(
            onTap: _pickCategory,
            child: Text(
              categoryLabel(widget.store, _categoryId),
              style: ff(14, color: c.ink),
            ),
          ),
        ),
        DField(
          label: 'By',
          child: SegmentedTabs(
            labels: const ['Josh', 'Judy'],
            selected: _by == Owner.josh ? 0 : 1,
            onChanged: (i) =>
                setState(() => _by = i == 0 ? Owner.josh : Owner.judy),
          ),
        ),
        if (widget.transaction != null)
          OutlinedButton(
            onPressed: () => _confirm(
              context,
              title: 'Delete transaction?',
              body: 'Removes this ledger entry.',
              onConfirm: () async {
                await widget.store.deleteTransaction(widget.transaction!.id);
                widget.onClose();
              },
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.bad,
              side: BorderSide(color: c.rule),
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Delete transaction'),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------------- bill

class BillDrawer extends StatefulWidget {
  final JuwaStore store;
  final Bill? bill;
  final VoidCallback onClose;
  const BillDrawer({
    super.key,
    required this.store,
    this.bill,
    required this.onClose,
  });

  @override
  State<BillDrawer> createState() => _BillDrawerState();
}

class _BillDrawerState extends State<BillDrawer> {
  late final _amount = TextEditingController(
    text: widget.bill == null ? '' : AmountField.format(widget.bill!.amount),
  );
  late final _name = TextEditingController(text: widget.bill?.name ?? '');
  late DateTime _firstDate = widget.bill?.firstDate ?? DateTime.now();
  late Repeat _repeat = widget.bill?.repeat ?? Repeat.monthly;
  late String _color = widget.bill?.color ?? juwaSwatches.first.key;
  late String _icon = widget.bill?.icon ?? juwaIcons.keys.first;
  late String? _accountId = widget.bill?.accountId;

  bool get _editing => widget.bill != null;

  @override
  void dispose() {
    _amount.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _firstDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _firstDate = DateTime(d.year, d.month, d.day));
    }
  }

  Future<void> _pickAccount() async {
    final id = await pickFrom<String>(
      context,
      title: 'Pays from',
      items: [for (final a in widget.store.accounts) (a.name, a.id)],
    );
    if (id != null) setState(() => _accountId = id);
  }

  Future<void> _save() async {
    final amt = AmountField.parse(_amount.text);
    if (amt == null || _name.text.trim().isEmpty) return;
    final store = widget.store;
    final bill = Bill(
      id: widget.bill?.id ?? store.newId(),
      name: _name.text.trim(),
      amount: amt,
      icon: _icon,
      color: _color,
      firstDate: _firstDate,
      repeat: _repeat,
      accountId: _accountId,
    );
    if (_editing) {
      await store.updateBill(bill);
    } else {
      await store.addBill(bill);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final swatch = swatchFor(_color);
    final account = widget.store.accounts
        .where((a) => a.id == _accountId)
        .firstOrNull;
    final preview = Bill(
      id: '',
      name: _name.text.isEmpty ? 'Bill' : _name.text,
      amount: AmountField.parse(_amount.text) ?? 0,
      icon: _icon,
      color: _color,
      firstDate: _firstDate,
      repeat: _repeat,
      accountId: _accountId,
    );
    return DrawerScaffold(
      title: _editing ? 'Edit bill' : 'New bill',
      onClose: widget.onClose,
      footer: SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: swatch.color,
            foregroundColor: swatch.on,
          ),
          child: Text(_editing ? 'Save' : 'Add bill'),
        ),
      ),
      children: [
        DField(
          label: 'Amount',
          child: AmountField(
            controller: _amount,
            fontSize: 18,
            onChanged: (_) => setState(() {}),
          ),
        ),
        DField(
          label: 'Name',
          child: TextField(
            controller: _name,
            style: ff(15, color: c.ink),
            onChanged: (_) => setState(() {}),
          ),
        ),
        DField(
          label: 'First date',
          child: DPickerButton(
            onTap: _pickDate,
            child: Text(ffDate(_firstDate), style: ff(14, color: c.ink)),
          ),
        ),
        DField(
          label: 'Repeats · ${freqLabel(preview)}',
          child: SegmentedTabs(
            // One label per Repeat value, in enum order.
            labels: const ['Weekly', 'Bi-weekly', 'Monthly', 'Yearly'],
            selected: Repeat.values.indexOf(_repeat),
            onChanged: (i) => setState(() => _repeat = Repeat.values[i]),
          ),
        ),
        DField(
          label: 'Colour',
          child: SwatchGrid(
            selected: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        DField(
          label: 'Icon',
          child: IconGrid(
            selected: _icon,
            activeColor: swatch.color,
            activeOn: swatch.on,
            onChanged: (v) => setState(() => _icon = v),
          ),
        ),
        DField(
          label: 'Pays from',
          child: DPickerButton(
            onTap: _pickAccount,
            outline: account == null ? c.warn : null,
            child: Text(
              account?.name ?? 'Choose account',
              style: ff(14, color: account == null ? c.warn : c.ink),
            ),
          ),
        ),
        if (widget.bill != null)
          OutlinedButton(
            onPressed: () => _confirm(
              context,
              title: 'Delete bill?',
              body: 'Removes ${widget.bill!.name} and every occurrence.',
              onConfirm: () async {
                await widget.store.deleteBill(widget.bill!.id);
                widget.onClose();
              },
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.bad,
              side: BorderSide(color: c.rule),
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Delete bill'),
          ),
      ],
    );
  }
}

// ----------------------------------------------------------------- budget

class BudgetDrawer extends StatefulWidget {
  final JuwaStore store;
  final Budget? budget;
  final VoidCallback onClose;
  const BudgetDrawer({
    super.key,
    required this.store,
    this.budget,
    required this.onClose,
  });

  @override
  State<BudgetDrawer> createState() => _BudgetDrawerState();
}

class _BudgetDrawerState extends State<BudgetDrawer> {
  late final _name = TextEditingController(text: widget.budget?.name ?? '');
  late final _target = TextEditingController(
    text: widget.budget == null
        ? ''
        : AmountField.format(widget.budget!.monthlyTarget),
  );
  late final _spent = TextEditingController(
    text: widget.budget == null
        ? ''
        : AmountField.format(widget.store.manualSpentNow(widget.budget!)),
  );

  bool get _editing => widget.budget != null;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _spent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final target = AmountField.parse(_target.text);
    if (_name.text.trim().isEmpty || target == null) return;
    final spent = AmountField.parse(_spent.text) ?? 0;
    final store = widget.store;
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final budget = Budget(
      id: widget.budget?.id ?? store.newId(),
      name: _name.text.trim(),
      monthlyTarget: target,
      spent: spent,
      month: month,
    );
    if (_editing) {
      await store.updateBudget(budget);
    } else {
      await store.addBudget(budget);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DrawerScaffold(
      title: _editing ? 'Edit budget' : 'New category',
      onClose: widget.onClose,
      footer: SizedBox(
        height: 46,
        child: FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: c.tint,
            foregroundColor: c.bg,
          ),
          child: Text(_editing ? 'Save' : 'Add budget'),
        ),
      ),
      children: [
        DField(
          label: 'Name',
          child: TextField(
            controller: _name,
            style: ff(15, color: c.ink),
          ),
        ),
        DField(
          label: 'Monthly target',
          child: AmountField(controller: _target, fontSize: 18),
        ),
        DField(
          label: 'Spent this month',
          child: AmountField(controller: _spent, fontSize: 18),
        ),
        if (widget.budget != null)
          OutlinedButton(
            onPressed: () => _confirm(
              context,
              title: 'Delete budget?',
              body: 'Removes ${widget.budget!.name}.',
              onConfirm: () async {
                await widget.store.deleteBudget(widget.budget!.id);
                widget.onClose();
              },
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.bad,
              side: BorderSide(color: c.rule),
              minimumSize: const Size.fromHeight(44),
            ),
            child: const Text('Delete budget'),
          ),
      ],
    );
  }
}

// -------------------------------------------------------- payday history

class PaydayHistoryDrawer extends StatelessWidget {
  final JuwaStore store;
  final VoidCallback onClose;
  const PaydayHistoryDrawer({
    super.key,
    required this.store,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final paydays = List.of(store.paydays)
      ..sort((a, b) => b.date.compareTo(a.date));
    return DrawerScaffold(
      title: 'Payday history',
      onClose: onClose,
      children: [
        if (paydays.isEmpty)
          Text('No saved paydays yet.', style: ff(14, color: c.muted))
        else
          for (final p in paydays)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  FFStamp(p.owner.label, color: c.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ffDate(p.date),
                          style: ff(13, weight: FontWeight.w600, color: c.ink),
                        ),
                        Text(
                          'Into ${store.accounts.where((a) => a.id == p.intoAccountId).firstOrNull?.name ?? 'deleted account'}',
                          style: ff(12, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ffMoney(p.amount),
                    style: ff(15, weight: FontWeight.w700, color: c.ink),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: c.bad,
                    ),
                    onPressed: () => _confirm(
                      context,
                      title: 'Delete payday?',
                      body:
                          'Removes this saved split and the deposit/transfer transactions it wrote.',
                      onConfirm: () => store.deletePayday(p.id),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
