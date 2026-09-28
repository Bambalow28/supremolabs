// The slide-in drawer's contents: account, transaction, bill and budget
// editors, plus payday history. All are compact desktop forms over the same
// JuwaStore API the phone editors use — no full-screen Scaffold, since these
// live inside a 440px panel.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/bills/bills_screen.dart' show freqLabel;
import 'package:juwa_wealth/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// Common drawer chrome: title + close, 28px padding, 20px between fields,
/// fields staggering in as the drawer arrives, and a full-width footer
/// action ruled off from the scrolling form above it.
class DrawerScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<Widget> children;
  final Widget? footer;

  /// Sits beside the close button — e.g. Edit on a read-only view.
  final Widget? action;

  const DrawerScaffold({
    super.key,
    required this.title,
    required this.onClose,
    required this.children,
    this.footer,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ffRaisedFields(
      context,
      Container(
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
                  ?action,
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
                      Reveal(index: i, slide: 10, child: children[i]),
                    ],
                  ],
                ),
              ),
            ),
            if (footer != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.rule)),
                ),
                child: footer,
              ),
          ],
        ),
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
    builder: (ctx) => FFPopIn(
      child: AlertDialog(
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
    builder: (ctx) => FFPopIn(
      child: AlertDialog(
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
  late Owner _owner = widget.account?.owner ?? widget.store.me;
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
          // Typed unsigned; a card or line of credit is owed, so it's saved
          // (and must preview) negative — else it reads green here, red in
          // the list.
          balance:
              (_owes ? -1 : 1) * (AmountField.parse(_balance.text) ?? 0) +
              // The list card shows starting balance plus its transactions,
              // so the preview must too.
              (widget.account == null
                  ? 0
                  : widget.store.balanceOf(widget.account!.id) -
                        widget.account!.balance),
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
            labels: [for (final o in Owner.all) o.title],
            selected: Owner.all.indexOf(_owner).clamp(0, Owner.all.length - 1),
            onChanged: (i) => setState(() => _owner = Owner.all[i]),
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
                                    ffAmount(t.amount),
                                    style: ff(
                                      13.5,
                                      weight: FontWeight.w700,
                                      color: t.amount > 0 ? c.good : c.bad,
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

/// Order links are saved as free text (no forced scheme) — prefix `https://`
/// when one's missing, same normalization the app applies on open.
String _normalizedLink(String url) =>
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(url) ? url : 'https://$url';

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
  late final _note = TextEditingController(
    text: widget.transaction?.note ?? '',
  );
  late final _link = TextEditingController(
    text: widget.transaction?.link ?? '',
  );
  late bool _received =
      widget.transaction != null && widget.transaction!.amount > 0;
  late String? _accountId =
      widget.transaction?.accountId ??
      (widget.store.accounts.isEmpty ? null : widget.store.accounts.first.id);
  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late String? _categoryId = widget.transaction?.categoryId;
  late Owner _by = widget.transaction?.by ?? widget.store.me;

  bool get _editing => widget.transaction != null;

  @override
  void dispose() {
    _amount.dispose();
    _name.dispose();
    _note.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _pasteLink() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim();
    if (text != null && text.isNotEmpty) setState(() => _link.text = text);
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
      builder: (_, child) => FFPopIn(child: child!),
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
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      receipt: widget.transaction?.receipt,
      link: _link.text.trim().isEmpty ? null : _link.text.trim(),
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
        SegmentedTabs(
          labels: const ['Spent', 'Received'],
          selected: _received ? 1 : 0,
          onChanged: (i) => setState(() => _received = i == 1),
        ),
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
            labels: [for (final o in Owner.people) o.title],
            selected: Owner.people
                .indexOf(_by)
                .clamp(0, Owner.people.length - 1),
            onChanged: (i) => setState(() => _by = Owner.people[i]),
          ),
        ),
        DField(
          label: 'Note',
          child: TextField(
            controller: _note,
            maxLines: 3,
            minLines: 1,
            style: ff(14, color: c.ink),
          ),
        ),
        DField(
          label: 'Order link',
          child: TextField(
            controller: _link,
            autocorrect: false,
            keyboardType: TextInputType.url,
            style: ff(14, color: c.ink),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Amazon order page, store link…',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_link.text.trim().isNotEmpty)
                    IconButton(
                      tooltip: 'Open',
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: FFColors.accentInk,
                      ),
                      onPressed: () => launchUrl(
                        Uri.parse(_normalizedLink(_link.text.trim())),
                        webOnlyWindowName: '_blank',
                      ),
                    ),
                  IconButton(
                    tooltip: 'Paste',
                    icon: Icon(
                      Icons.content_paste_rounded,
                      size: 18,
                      color: c.muted,
                    ),
                    onPressed: _pasteLink,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.transaction?.receipt != null)
          receiptField(context, widget.store, widget.transaction!.receipt!),
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
      builder: (_, child) => FFPopIn(child: child!),
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
  late BudgetPeriod _period = widget.budget?.period ?? BudgetPeriod.monthly;
  late DateTime? _startDate = widget.budget?.startDate;

  bool get _editing => widget.budget != null;

  String get _restartLabel => Budget(
    id: '',
    name: '',
    monthlyTarget: 0,
    spent: 0,
    month: '',
    period: _period,
    startDate: _startDate,
  ).restartLabel;

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Restarts on',
      builder: (_, child) => FFPopIn(child: child!),
    );
    if (d != null) setState(() => _startDate = d);
  }

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
    final draft = Budget(
      id: widget.budget?.id ?? store.newId(),
      name: _name.text.trim(),
      monthlyTarget: target,
      spent: spent,
      month: '',
      period: _period,
      startDate: _startDate,
    );
    // Stamp the hand-entered amount with the period it was typed for.
    final budget = draft.copyWith(month: draft.periodKey(DateTime.now()));
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
          label: 'Repeats',
          child: SegmentedTabs(
            labels: [for (final p in BudgetPeriod.values) p.label],
            selected: _period.index,
            onChanged: (i) => setState(() => _period = BudgetPeriod.values[i]),
          ),
        ),
        DField(
          label: 'Restarts',
          child: DPickerButton(
            onTap: _pickStart,
            child: Text(_restartLabel, style: ff(14, color: c.ink)),
          ),
        ),
        DField(
          label: '${_period.label} target',
          child: AmountField(controller: _target, fontSize: 18),
        ),
        DField(
          label: 'Spent this ${_period.noun}',
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

/// The receipt photo, tap to enlarge. Shared by the edit and read-only views.
Widget receiptField(BuildContext context, JuwaStore store, String fileName) {
  return DField(
    label: 'Receipt',
    child: GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => FFPopIn(
          child: _ReceiptDialog(store: store, fileName: fileName),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 260,
          width: double.infinity,
          child: _ReceiptPhoto(store, fileName, fit: BoxFit.cover),
        ),
      ),
    ),
  );
}

/// A receipt's bytes as an image that can't take the page down: a failed
/// fetch, an undecodable file or a huge photo all fall back to a quiet
/// "unavailable" tile.
class _ReceiptPhoto extends StatefulWidget {
  final JuwaStore store;
  final String fileName;
  final BoxFit fit;
  const _ReceiptPhoto(this.store, this.fileName, {required this.fit});

  @override
  State<_ReceiptPhoto> createState() => _ReceiptPhotoState();
}

class _ReceiptPhotoState extends State<_ReceiptPhoto> {
  late final Future<Uint8List?> _bytes = widget.store
      .receiptBytes(widget.fileName)
      .then<Uint8List?>((b) => b)
      .catchError((Object _) => null);

  Widget _unavailable(BuildContext context) {
    final c = context.c;
    return ColoredBox(
      color: c.fill,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: c.faint, size: 28),
            const SizedBox(height: 6),
            Text('Photo unavailable', style: ff(12, color: c.faint)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SkeletonBox(width: double.infinity, height: 260);
        }
        final bytes = snap.data;
        if (bytes == null) return _unavailable(context);
        return Image.memory(
          bytes,
          fit: widget.fit,
          // Decode at screen size, not camera size.
          cacheWidth: 1400,
          errorBuilder: (context, _, _) => _unavailable(context),
        );
      },
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  final JuwaStore store;
  final String fileName;
  const _ReceiptDialog({required this.store, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: size.height * 0.85,
              minHeight: 200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // Pinch or scroll to zoom in on the small print.
              child: InteractiveViewer(
                maxScale: 5,
                child: SizedBox(
                  width: 560,
                  height: size.height * 0.85,
                  child: _ReceiptPhoto(store, fileName, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only value under a label — the view-mode twin of a [DField].
class DRead extends StatelessWidget {
  final String label;
  final Widget child;
  const DRead({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => DField(label: label, child: child);
}

Widget _editButton(BuildContext context, VoidCallback onTap) => Padding(
  padding: const EdgeInsets.only(right: 4),
  child: SizedBox(
    height: 36,
    child: FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
      ),
      child: const Text('Edit'),
    ),
  ),
);

/// Opens [t] read-only; its Edit button swaps in the form.
void openTransactionDetail(
  JuwaStore store,
  Transaction t, {
  required void Function(Widget drawer) openDrawer,
  required VoidCallback closeDrawer,
}) => openDrawer(
  TransactionDetailDrawer(
    store: store,
    transaction: t,
    onClose: closeDrawer,
    onEdit: () => openDrawer(
      TransactionDrawer(store: store, transaction: t, onClose: closeDrawer),
    ),
  ),
);

/// Opens [b] with every transaction in its category; Edit swaps in the form.
void openBudgetDetail(
  JuwaStore store,
  Budget b, {
  required void Function(Widget drawer) openDrawer,
  required VoidCallback closeDrawer,
}) => openDrawer(
  BudgetDetailDrawer(
    store: store,
    budget: b,
    onClose: closeDrawer,
    openDrawer: openDrawer,
    onEdit: () =>
        openDrawer(BudgetDrawer(store: store, budget: b, onClose: closeDrawer)),
  ),
);

// ------------------------------------------------- transaction (read-only)

class TransactionDetailDrawer extends StatelessWidget {
  final JuwaStore store;
  final Transaction transaction;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  const TransactionDetailDrawer({
    super.key,
    required this.store,
    required this.transaction,
    required this.onClose,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tx = transaction;
    final account = store.accounts
        .where((a) => a.id == tx.accountId)
        .firstOrNull;
    final swatch = swatchFor(account?.color ?? 'graphite');
    final received = tx.amount > 0;
    return DrawerScaffold(
      title: 'Transaction',
      onClose: onClose,
      action: _editButton(context, onEdit),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tx.name,
              style: ff(20, weight: FontWeight.w700, color: c.ink),
            ),
            const SizedBox(height: 6),
            Text(
              ffAmount(tx.amount),
              style: ff(
                34,
                weight: FontWeight.w800,
                color: received ? c.good : c.bad,
              ),
            ),
            Text(
              received ? 'Received' : 'Spent',
              style: ff(13, color: c.muted),
            ),
          ],
        ),
        DRead(
          label: 'Account',
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
                account?.name ?? 'Deleted account',
                style: ff(15, color: c.ink),
              ),
            ],
          ),
        ),
        DRead(
          label: 'Date',
          child: Text(ffDate(tx.date), style: ff(15, color: c.ink)),
        ),
        DRead(
          label: 'Category',
          child: Text(
            categoryLabel(store, tx.categoryId),
            style: ff(15, color: c.ink),
          ),
        ),
        DRead(
          label: 'Added by',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FFStamp(tx.by.label, color: c.muted),
          ),
        ),
        if (tx.billId != null || tx.paydayId != null)
          Text(
            tx.billId != null
                ? 'Written automatically when the bill was paid.'
                : 'Written automatically by a payday.',
            style: ff(12.5, color: c.muted),
          ),
        if (tx.note != null && tx.note!.isNotEmpty)
          DRead(
            label: 'Note',
            child: Text(tx.note!, style: ff(14, color: c.ink)),
          ),
        if (tx.link != null)
          DRead(
            label: 'Order link',
            child: GestureDetector(
              onTap: () => launchUrl(
                Uri.parse(_normalizedLink(tx.link!)),
                webOnlyWindowName: '_blank',
              ),
              child: Text(
                tx.link!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ff(
                  14,
                  color: FFColors.accentInk,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (tx.receipt != null) receiptField(context, store, tx.receipt!),
      ],
    );
  }
}

// ------------------------------------------------------- budget (detail)

class BudgetDetailDrawer extends StatelessWidget {
  final JuwaStore store;
  final Budget budget;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final void Function(Widget drawer) openDrawer;
  const BudgetDetailDrawer({
    super.key,
    required this.store,
    required this.budget,
    required this.onClose,
    required this.onEdit,
    required this.openDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Read live: the drawer outlives edits, so pick the current copy.
    final b =
        store.budgets.where((x) => x.id == budget.id).firstOrNull ?? budget;
    final spent = store.spentNow(b);
    final left = store.budgetRemaining(b);
    final manual = store.manualSpentNow(b);
    final txs = store.transactions.where((t) => t.categoryId == b.id).toList()
      ..sort((x, y) => y.date.compareTo(x.date));
    return DrawerScaffold(
      title: b.name,
      onClose: onClose,
      action: _editButton(context, onEdit),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: ff(15, color: c.muted),
                children: [
                  TextSpan(
                    text: ffAmount(spent),
                    style: ff(30, weight: FontWeight.w800, color: c.ink),
                  ),
                  TextSpan(
                    text:
                        '  of ${ffAmount(b.monthlyTarget)} this ${b.period.noun}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BudgetBar(spent: spent, target: b.monthlyTarget, color: c.tint),
            const SizedBox(height: 10),
            Text(
              '${b.period.label} · restarts ${b.restartLabel.toLowerCase()}',
              style: ff(12.5, color: c.faint),
            ),
            const SizedBox(height: 4),
            Text(
              left < 0 ? '${ffAmount(left)} over' : '${ffAmount(left)} left',
              style: ff(
                13.5,
                weight: FontWeight.w600,
                color: left < 0 ? c.bad : c.muted,
              ),
            ),
            if (manual > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Includes ${ffAmount(manual)} entered by hand.',
                  style: ff(12.5, color: c.faint),
                ),
              ),
          ],
        ),
        DRead(
          label: 'Transactions · ${txs.length}',
          child: txs.isEmpty
              ? Text(
                  'Nothing filed under ${b.name} yet.',
                  style: ff(13.5, color: c.muted),
                )
              : Column(
                  children: [
                    for (final t in txs)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => openTransactionDetail(
                          store,
                          t,
                          openDrawer: openDrawer,
                          closeDrawer: onClose,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: ff(
                                        14.5,
                                        weight: FontWeight.w600,
                                        color: c.ink,
                                      ),
                                    ),
                                    Text(
                                      ffDate(t.date),
                                      style: ff(12, color: c.muted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                ffAmount(t.amount),
                                style: ff(
                                  14.5,
                                  weight: FontWeight.w700,
                                  color: t.amount > 0 ? c.good : c.bad,
                                ),
                              ),
                            ],
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
