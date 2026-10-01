// The wallet rail — stays open on every tab (per the mockup) so an edit on
// any panel shows on the cards immediately. Reorder, owner filter, and the
// account drawer all live here. Collapsible, for a wider working area.
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/accounts/wallet_card.dart' show WalletCard;
import 'package:juwa_wealth/ui/transactions/transactions_screen.dart'
    show newestFirst;
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';

class WalletRail extends StatelessWidget {
  final JuwaStore store;
  final Owner? ownerFilter;
  final ValueChanged<Owner?> onOwnerFilterChanged;
  final String? selectedAccountId;
  final ValueChanged<Account> onSelectAccount;
  final VoidCallback onAddAccount;

  /// accountId -> pending payday delta, shown as a pill under the card.
  final Map<String, double> deltas;

  /// True under the 900px breakpoint: rail becomes a horizontal strip.
  final bool compact;

  /// Folded away to a slim strip (wide) or just its header (compact).
  final bool collapsed;
  final VoidCallback onToggle;

  /// A refresh is in flight: cards show as skeletons until it lands.
  final bool loading;

  const WalletRail({
    super.key,
    required this.store,
    required this.ownerFilter,
    required this.onOwnerFilterChanged,
    required this.selectedAccountId,
    required this.onSelectAccount,
    required this.onAddAccount,
    required this.deltas,
    required this.collapsed,
    required this.onToggle,
    this.loading = false,
    this.compact = false,
  });

  List<Owner?> get _owners => [null, ...Owner.all];
  static const _wide = 344.0;
  static const _slim = 64.0;
  static const _fold = Duration(milliseconds: 280);

  Widget _toggle(BuildContext context) {
    final c = context.c;
    return IconButton(
      onPressed: onToggle,
      tooltip: collapsed ? 'Show accounts' : 'Hide accounts',
      icon: Icon(
        compact
            ? (collapsed
                  ? Icons.expand_more_rounded
                  : Icons.expand_less_rounded)
            : (collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded),
        color: c.muted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final visible = ownerFilter == null
        ? store.accounts
        : store.accounts.where((a) => a.owner == ownerFilter);
    final total = visible.fold(0.0, (s, a) => s + store.balanceOf(a.id));

    final header = Padding(
      padding: EdgeInsets.fromLTRB(24, compact ? 8 : 20, compact ? 8 : 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Household', style: ff(13, color: c.muted)),
              ),
              _toggle(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loading)
                  const SkeletonBox(width: 150, height: 34)
                else
                  Text(
                    ffAmount(total),
                    style: ff(
                      30,
                      weight: FontWeight.w800,
                      color: moneyColor(total),
                      spacing: -0.9,
                    ),
                  ),
                const SizedBox(height: 14),
                SegmentedTabs(
                  labels: ['All', for (final o in Owner.all) o.title],
                  selected: _owners.indexOf(ownerFilter),
                  onChanged: (i) => onOwnerFilterChanged(_owners[i]),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );

    final cards = loading
        ? ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: compact ? Axis.horizontal : Axis.vertical,
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: compact ? 0 : 10,
                    right: compact ? 10 : 0,
                  ),
                  child: SizedBox(
                    width: compact ? 260 : null,
                    child: const _AccountSkeleton(),
                  ),
                ),
            ],
          )
        : ReorderableListView.builder(
            // Never scrolls itself: the rail grows with its cards and the
            // page scrolls.
            shrinkWrap: true,
            scrollDirection: compact ? Axis.horizontal : Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
            itemCount: store.accounts.length,
            buildDefaultDragHandles: false,
            // onReorderItem already adjusts `to` for the removed item.
            onReorderItem: (from, to) {
              final ids = store.accounts.map((a) => a.id).toList();
              store.reorderAccounts(ids[from], to, ids);
            },
            itemBuilder: (context, i) {
              final a = store.accounts[i];
              final dim = ownerFilter != null && a.owner != ownerFilter;
              return ReorderableDragStartListener(
                key: ValueKey(a.id),
                index: i,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                    right: compact ? 10 : 0,
                    // Extra headroom so the delta pill (hangs below the card)
                    // never overlaps the card underneath it.
                    top: deltas.containsKey(a.id) ? 6 : 0,
                  ),
                  child: Reveal(
                    index: i,
                    child: GestureDetector(
                      onTap: () => onSelectAccount(a),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: dim ? 0.32 : 1,
                        child: SizedBox(
                          width: compact ? 260 : null,
                          child: _RailCard(
                            store: store,
                            account: a,
                            delta: deltas[a.id],
                            selected: selectedAccountId == a.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );

    final addButton = Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, compact ? 14 : 0),
      child: OutlinedButton.icon(
        onPressed: onAddAccount,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text('Add account', style: ff(13.5, weight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.muted,
          side: BorderSide(color: c.rule, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size.fromHeight(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );

    final footer = Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c.good, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Synced with your household · same data as the phones',
              style: ff(11.5, color: c.faint),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );

    final emptyNote = Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Text(
        'No accounts yet — add your first card.',
        style: ff(13, color: c.muted, weight: FontWeight.w600),
      ),
    );

    if (compact) {
      return Container(
        decoration: BoxDecoration(
          color: c.bg,
          border: Border(bottom: BorderSide(color: c.rule)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            AnimatedSize(
              duration: _fold,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: collapsed
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        store.accounts.isEmpty && !loading
                            ? emptyNote
                            // Tall enough for a card whose kind+stamp wraps to
                            // its own line plus a delta pill below it.
                            : SizedBox(
                                height: WalletCard.fullHeight + 32,
                                child: cards,
                              ),
                        addButton,
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: _fold,
      curve: Curves.easeOutCubic,
      width: collapsed ? _slim : _wide,
      // Same floor as the console, so the divider still runs the full height
      // on a short page.
      constraints: BoxConstraints(
        minHeight: (MediaQuery.sizeOf(context).height - 100).clamp(
          720.0,
          double.infinity,
        ),
      ),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(right: BorderSide(color: c.rule)),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Laid out at full width even while it folds, so nothing reflows
            // mid-animation — it just fades and is clipped.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: _wide,
                child: IgnorePointer(
                  ignoring: collapsed,
                  child: AnimatedOpacity(
                    duration: _fold,
                    opacity: collapsed ? 0 : 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        header,
                        store.accounts.isEmpty && !loading
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: emptyNote,
                              )
                            : cards,
                        addButton,
                        footer,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (collapsed)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _toggle(context),
                      const SizedBox(height: 8),
                      // One swatch per account: the strip still says what's
                      // there, and a tap opens it.
                      for (final a in store.accounts)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Tooltip(
                            message: a.name,
                            child: GestureDetector(
                              onTap: () => onSelectAccount(a),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: swatchFor(a.color).color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  iconFor(a.icon),
                                  size: 15,
                                  color: swatchFor(a.color).on,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The app's wallet card — latest three transactions and this month's in/out
/// on the card itself — with the pending-payday pill and selection ring the
/// rail adds.
class _RailCard extends StatelessWidget {
  final JuwaStore store;
  final Account account;
  final double? delta;
  final bool selected;
  const _RailCard({
    required this.store,
    required this.account,
    required this.delta,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final txs = [
      for (final t in store.transactions)
        if (t.accountId == account.id) t,
    ]..sort(newestFirst);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final month = txs.where((t) => !t.date.isBefore(start));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: delta == null ? 0 : 26),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected ? Border.all(color: c.ink, width: 2) : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(selected ? 4 : 0),
              child: WalletCard(
                account: account,
                balance: store.balanceOf(account.id),
                recent: txs,
                monthIn: month
                    .where((t) => t.amount > 0)
                    .fold<double>(0, (s, t) => s + t.amount),
                monthOut: month
                    .where((t) => t.amount < 0)
                    .fold<double>(0, (s, t) => s - t.amount),
              ),
            ),
          ),
          if (delta != null)
            Positioned(
              left: 14,
              bottom: -24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: c.rule),
                ),
                child: Text(
                  ffAmount(delta!),
                  style: ff(
                    11.5,
                    weight: FontWeight.w700,
                    color: moneyColor(delta!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// An account card's shape while it loads: icon tile, name and type lines,
/// balance chip — on a surface card so it reads against the ground.
class _AccountSkeleton extends StatelessWidget {
  const _AccountSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: WalletCard.fullHeight),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 34,
            height: 34,
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 96, height: 13),
                SizedBox(height: 8),
                SkeletonBox(width: 64, height: 10),
              ],
            ),
          ),
          SkeletonBox(
            width: 64,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}
