// /famfi/personal — the desktop console: every control the phone app has,
// laid out for a long money session. Reads and writes straight through
// JuwaStore (shared_preferences -> browser localStorage on web); no backend
// yet, so the rail footer says so honestly (see juwa_wealth/docs/firebase-plan.md).
//
// No sign-in gate for now, per spec — the mockup's Apple sign-in gate is
// deferred until Firebase ships.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/widgets.dart' show AmountField;

import '../../app/site_shell.dart';
import 'console/bills_panel.dart';
import 'console/budget_panel.dart';
import 'console/drawer.dart';
import 'console/ff_tab.dart';
import 'console/header.dart';
import 'console/ledger_panel.dart';
import 'console/payday_panel.dart';
import 'console/wallet_rail.dart';
import 'ff_theme.dart';

class FamFiConsolePage extends StatefulWidget {
  const FamFiConsolePage({super.key});

  @override
  State<FamFiConsolePage> createState() => _FamFiConsolePageState();
}

class _FamFiConsolePageState extends State<FamFiConsolePage> {
  late final Future<JuwaStore> _future = JuwaStore.load();

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      ground: FFColors.ground,
      children: [
        FutureBuilder<JuwaStore>(
          future: _future,
          builder: (context, snap) {
            final store = snap.data;
            if (store == null) {
              return const SizedBox(
                height: 720,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _Console(store: store);
          },
        ),
      ],
    );
  }
}

class _Console extends StatefulWidget {
  final JuwaStore store;
  const _Console({required this.store});

  @override
  State<_Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<_Console> {
  static const _owners = [Owner.josh, Owner.judy];

  FFTab _tab = FFTab.payday;
  Owner? _ownerFilter;
  String? _selectedAccountId;
  Widget? _drawerChild;

  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  // Payday form state lives here (not in PaydayPanel) so the wallet rail can
  // show each card's pending delta while that tab is open. Mirrors
  // PaydayScreen: one amount + focus node per owner, plus user overrides for
  // their deposit account and next payday (falls back to the store's own
  // pick for that owner otherwise).
  final _amounts = {for (final o in _owners) o: TextEditingController()};
  final _amountFocus = {for (final o in _owners) o: FocusNode()};
  final _pickedInto = <Owner, String>{};
  final _pickedNext = <Owner, DateTime>{};

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _search.addListener(_onSearchChanged);
    // The split, Left in hand and the wallet's deltas all read the cheques.
    for (final o in _owners) {
      _amounts[o]!.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _searchFocus.dispose();
    for (final o in _owners) {
      _amounts[o]!.dispose();
      _amountFocus[o]!.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    if (_search.text.isNotEmpty && _tab != FFTab.ledger) {
      setState(() => _tab = FFTab.ledger);
    } else {
      setState(() {});
    }
  }

  bool get _typing {
    final ctx = FocusManager.instance.primaryFocus?.context;
    // A TextField's focus node sits on a Focus *inside* its EditableText,
    // so look up the tree rather than at the node's own widget.
    return ctx != null &&
        (ctx.widget is EditableText ||
            ctx.findAncestorWidgetOfExactType<EditableText>() != null);
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    // The handler is global: stay quiet while another page is pushed on top.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    final meta =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    if (meta && event.logicalKey == LogicalKeyboardKey.keyK) {
      _searchFocus.requestFocus();
      return true;
    }
    if (meta && event.logicalKey == LogicalKeyboardKey.enter) {
      if (_tab == FFTab.payday) {
        _savePayday();
        return true;
      }
      return false;
    }
    if (_typing) return false;
    final digitTabs = {
      LogicalKeyboardKey.digit1: FFTab.ledger,
      LogicalKeyboardKey.digit2: FFTab.bills,
      LogicalKeyboardKey.digit3: FFTab.payday,
      LogicalKeyboardKey.digit4: FFTab.budget,
    };
    final mapped = digitTabs[event.logicalKey];
    if (mapped != null) {
      setState(() => _tab = mapped);
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyN) {
      _newForTab();
      return true;
    }
    return false;
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  // Keyed so opening item B over item A's drawer builds fresh form state
  // instead of reusing A's controllers (and saving A's values onto B).
  void openDrawer(Widget child) => setState(
    () => _drawerChild = KeyedSubtree(key: UniqueKey(), child: child),
  );

  /// [owner]'s picked deposit account, or their own default if it was since
  /// deleted or never picked.
  String? _intoFor(JuwaStore store, Owner owner) {
    final picked = _pickedInto[owner];
    if (picked != null && store.accounts.any((a) => a.id == picked)) {
      return picked;
    }
    return store.depositAccountFor(owner);
  }

  DateTime _nextFor(JuwaStore store, Owner owner, DateTime today) =>
      _pickedNext[owner] ?? store.nextPaydayFor(owner, today);

  double _amountFor(Owner owner) =>
      AmountField.parse(_amounts[owner]!.text) ?? 0;

  void closeDrawer() => setState(() {
    _drawerChild = null;
    _selectedAccountId = null;
  });

  void _newForTab() {
    final store = widget.store;
    switch (_tab) {
      case FFTab.ledger:
        openDrawer(TransactionDrawer(store: store, onClose: closeDrawer));
      case FFTab.bills:
        openDrawer(BillDrawer(store: store, onClose: closeDrawer));
      case FFTab.payday:
        _amountFocus[Owner.josh]!.requestFocus();
      case FFTab.budget:
        openDrawer(BudgetDrawer(store: store, onClose: closeDrawer));
    }
  }

  /// Mirrors PaydayScreen's `_save`: one saved Payday per owner whose amount
  /// is > 0, each written via `savePaydayWithTransactions`, then that owner's
  /// amount and picked next payday are cleared (their next payday now
  /// follows the payday just saved).
  // Guards a second ⌘↵ during the awaits below from saving the same
  // cheques twice (the phone's _save has the same guard).
  bool _saving = false;

  Future<void> _savePayday() async {
    final store = widget.store;
    if (_saving || store.accounts.isEmpty) return;
    final today = _today();
    final into = {
      for (final o in _owners)
        if (_intoFor(store, o) != null) o: _intoFor(store, o)!,
    };
    final nextPaydays = {for (final o in _owners) o: _nextFor(store, o, today)};
    final splits = store.splitForBoth(
      amounts: {for (final o in _owners) o: _amountFor(o)},
      nextPaydays: nextPaydays,
      into: into,
      today: today,
    );
    final toSave = splits.entries
        .where((e) => _amountFor(e.key) > 0 && into[e.key] != null)
        .toList();
    if (toSave.isEmpty) return;
    _saving = true;
    try {
      for (final e in toSave) {
        final o = e.key;
        await store.savePaydayWithTransactions(
          Payday(
            id: store.newId(),
            date: today,
            amount: _amountFor(o),
            owner: o,
            intoAccountId: into[o]!,
            nextPayday: nextPaydays[o]!,
            split: {for (final g in e.value.groups) g.accountId: g.total},
          ),
          e.value,
        );
        _amounts[o]!.clear();
        _pickedNext.remove(o);
      }
    } finally {
      _saving = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  /// Wallet deltas across both cheques, accumulated so an account either
  /// owner's split touches shows the combined pending change.
  Map<String, double> _deltasFor(
    Map<Owner, String?> into,
    Map<Owner, SplitResult> splits,
  ) {
    final m = <String, double>{};
    for (final o in _owners) {
      final intoId = into[o];
      final amount = _amountFor(o);
      final split = splits[o];
      if (intoId == null || amount <= 0 || split == null) continue;
      final transfers = split.groups.where((g) => !g.stays).toList();
      final out = transfers.fold(0.0, (s, g) => s + g.total);
      m[intoId] = (m[intoId] ?? 0) + (amount - out);
      for (final g in transfers) {
        m[g.accountId] = (m[g.accountId] ?? 0) + g.total;
      }
    }
    return m;
  }

  double _consoleHeight(BuildContext context) =>
      (MediaQuery.sizeOf(context).height - 100).clamp(720, double.infinity);

  void _onOpenBillFromNotification(Bill bill) {
    setState(() => _tab = FFTab.bills);
    openDrawer(
      BillDrawer(store: widget.store, bill: bill, onClose: closeDrawer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final today = _today();
        final into = {
          for (final o in _owners)
            if (_intoFor(store, o) != null) o: _intoFor(store, o),
        };
        final nextPaydays = {
          for (final o in _owners) o: _nextFor(store, o, today),
        };
        final splits = store.splitForBoth(
          amounts: {for (final o in _owners) o: _amountFor(o)},
          nextPaydays: nextPaydays,
          into: {
            for (final e in into.entries)
              if (e.value != null) e.key: e.value!,
          },
          today: today,
        );
        final deltas = _tab == FFTab.payday
            ? _deltasFor(into, splits)
            : const <String, double>{};

        return SizedBox(
          height: _consoleHeight(context),
          child: Theme(
            data: famFiTheme(MediaQuery.platformBrightnessOf(context)),
            child: Builder(
              builder: (context) {
                final c = context.c;
                return Focus(
                  autofocus: true,
                  child: Container(
                    color: c.bg,
                    child: LayoutBuilder(
                      builder: (context, cons) {
                        final compact = cons.maxWidth < 900;
                        final panel = _panel(
                          store,
                          splits,
                          into,
                          nextPaydays,
                          today,
                        );
                        // Wide: the wallet runs the full height on the left and
                        // the tabs sit over the task, as in the approved mockup.
                        return Stack(
                          children: [
                            compact
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ConsoleHeader(
                                        store: store,
                                        tab: _tab,
                                        onTabChanged: (t) =>
                                            setState(() => _tab = t),
                                        search: _search,
                                        searchFocus: _searchFocus,
                                        onNew: _newForTab,
                                        onOpenBill: _onOpenBillFromNotification,
                                      ),
                                      WalletRail(
                                        store: store,
                                        ownerFilter: _ownerFilter,
                                        onOwnerFilterChanged: (o) =>
                                            setState(() => _ownerFilter = o),
                                        selectedAccountId: _selectedAccountId,
                                        onSelectAccount: _openAccountDrawer,
                                        onAddAccount: () => openDrawer(
                                          AccountDrawer(
                                            store: store,
                                            onClose: closeDrawer,
                                          ),
                                        ),
                                        deltas: deltas,
                                        compact: compact,
                                      ),
                                      Expanded(child: panel),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      WalletRail(
                                        store: store,
                                        ownerFilter: _ownerFilter,
                                        onOwnerFilterChanged: (o) =>
                                            setState(() => _ownerFilter = o),
                                        selectedAccountId: _selectedAccountId,
                                        onSelectAccount: _openAccountDrawer,
                                        onAddAccount: () => openDrawer(
                                          AccountDrawer(
                                            store: store,
                                            onClose: closeDrawer,
                                          ),
                                        ),
                                        deltas: deltas,
                                        compact: compact,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ConsoleHeader(
                                              store: store,
                                              tab: _tab,
                                              onTabChanged: (t) =>
                                                  setState(() => _tab = t),
                                              search: _search,
                                              searchFocus: _searchFocus,
                                              onNew: _newForTab,
                                              onOpenBill:
                                                  _onOpenBillFromNotification,
                                            ),
                                            Expanded(child: panel),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 360),
                              curve: Curves.easeOutQuart,
                              top: 0,
                              bottom: 0,
                              right: _drawerChild == null ? -460 : 0,
                              width: 440,
                              child: Material(
                                elevation: 12,
                                child: _drawerChild ?? const SizedBox(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openAccountDrawer(Account a) {
    setState(() => _selectedAccountId = a.id);
    openDrawer(
      AccountDrawer(store: widget.store, account: a, onClose: closeDrawer),
    );
  }

  Widget _panel(
    JuwaStore store,
    Map<Owner, SplitResult> splits,
    Map<Owner, String?> into,
    Map<Owner, DateTime> nextPaydays,
    DateTime today,
  ) {
    switch (_tab) {
      case FFTab.payday:
        return PaydayPanel(
          store: store,
          amountControllers: _amounts,
          amountFocus: _amountFocus,
          intoAccountId: into,
          onIntoChanged: (o, id) => setState(() => _pickedInto[o] = id),
          nextPayday: nextPaydays,
          onNextPaydayChanged: (o, d) => setState(() => _pickedNext[o] = d),
          today: today,
          splits: splits,
          onSave: _savePayday,
          openDrawer: openDrawer,
          closeDrawer: closeDrawer,
        );
      case FFTab.ledger:
        return LedgerPanel(
          store: store,
          searchQuery: _search.text,
          openDrawer: openDrawer,
          closeDrawer: closeDrawer,
        );
      case FFTab.bills:
        return BillsPanel(
          store: store,
          openDrawer: openDrawer,
          closeDrawer: closeDrawer,
        );
      case FFTab.budget:
        return BudgetPanel(
          store: store,
          openDrawer: openDrawer,
          closeDrawer: closeDrawer,
        );
    }
  }
}
