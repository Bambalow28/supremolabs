// /famfi/personal — the desktop console: every control the phone app has,
// laid out for a long money session. Reads and writes through JuwaStore, kept
// live with the household's Firestore data via HouseholdSync — the same sync
// the phone app runs (see juwa_wealth/docs/firebase-plan.md).
//
// No Apple sign-in on the web: this browser signs in anonymously and joins
// the household with the same invite code a phone would use for a second
// phone (Household.join). Firebase Auth persists that anonymous uid across
// visits, so the join screen only shows up once per browser.
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/sync.dart';
import 'package:juwa_wealth/widgets.dart' show AmountField, SegmentedTabs;

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
  late final StreamSubscription<User?> _authSub;
  HouseholdSync? _sync;
  User? _user;
  String? _hid;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUser);
  }

  @override
  void dispose() {
    _authSub.cancel();
    _sync?.stop();
    super.dispose();
  }

  Future<void> _onUser(User? user) async {
    setState(() => _user = user);
    if (user == null) {
      // No anonymous session yet (fresh browser) — start one; this handler
      // runs again once it lands.
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        if (mounted) setState(() => _error = e);
      }
      return;
    }
    try {
      final store = await _future;
      final h = await Household.of(user.uid);
      if (h != null) await _connect(store, h.hid, h.owner);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _connect(JuwaStore store, String hid, Owner owner) async {
    store.me = owner;
    _sync = HouseholdSync(store, hid);
    await _sync!.start(importLocal: false);
    if (mounted) setState(() => _hid = hid);
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      ground: FFColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: FutureBuilder<JuwaStore>(
              future: _future,
              builder: (context, snap) {
                final store = snap.data;
                if (store == null) {
                  return const SizedBox(
                    height: 720,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (_error != null) {
                  return _ConsoleMessage(
                    text: "Couldn't reach your household. "
                        'Check your connection and reload.',
                  );
                }
                if (_user == null || _hid == null) {
                  return _user == null
                      ? const SizedBox(
                          height: 720,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _JoinCard(
                          uid: _user!.uid,
                          onJoined: (hid, owner) =>
                              _connect(store, hid, owner),
                        );
                }
                return FamFiConsoleBody(store: store);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsoleMessage extends StatelessWidget {
  final String text;
  const _ConsoleMessage({required this.text});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 720,
    child: Center(
      child: Text(
        text,
        style: ff(15, color: context.c.muted),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// Shown once per browser: joins the household with the same invite code a
/// phone uses to add a second phone (Household.invite/join in sync.dart).
class _JoinCard extends StatefulWidget {
  final String uid;
  final void Function(String hid, Owner owner) onJoined;
  const _JoinCard({required this.uid, required this.onJoined});

  @override
  State<_JoinCard> createState() => _JoinCardState();
}

class _JoinCardState extends State<_JoinCard> {
  Owner _owner = Owner.josh;
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final hid = await Household.join(widget.uid, _owner, _code.text);
      if (hid == null) {
        setState(
          () => _error = 'That code is wrong or expired. Ask for a new one.',
        );
      } else {
        widget.onJoined(hid, _owner);
      }
    } catch (_) {
      setState(() => _error = "Couldn't reach the server. Check your connection.");
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 720,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join your household',
                style: ff(20, weight: FontWeight.w800, color: c.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'Open the household sheet on either phone and invite this '
                'browser — the code works for 10 minutes.',
                style: ff(13.5, color: c.muted),
              ),
              const SizedBox(height: 20),
              SegmentedTabs(
                labels: const ['Josh', 'Judy'],
                selected: _owner == Owner.josh ? 0 : 1,
                onChanged: (i) =>
                    setState(() => _owner = i == 0 ? Owner.josh : Owner.judy),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                maxLength: 6,
                style: ff(
                  18,
                  weight: FontWeight.w700,
                  color: c.ink,
                ).copyWith(letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: 'Join code',
                  counterText: '',
                  filled: true,
                  fillColor: c.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _join,
                style: FilledButton.styleFrom(
                  backgroundColor: c.ink,
                  foregroundColor: c.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _busy
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: c.bg,
                        ),
                      )
                    : const Text('Join household'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: ff(13, color: c.bad)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FamFiConsoleBody extends StatefulWidget {
  final JuwaStore store;
  const FamFiConsoleBody({super.key, required this.store});

  @override
  State<FamFiConsoleBody> createState() => _ConsoleState();
}

class _ConsoleState extends State<FamFiConsoleBody> {
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
