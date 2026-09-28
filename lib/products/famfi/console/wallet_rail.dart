// The wallet rail — stays open on every tab (per the mockup) so an edit on
// any panel shows on the cards immediately. Reorder, owner filter, and the
// account drawer all live here. Collapsible, for a wider working area.
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
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

  static const _owners = [null, Owner.josh, Owner.judy, Owner.joint];
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
                  labels: const ['All', 'Josh', 'Judy', 'Joint'],
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
                  child: SkeletonBox(
                    width: compact ? 260 : double.infinity,
                    height: compact ? 64 : 64,
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                  ),
                ),
            ],
          )
        : ReorderableListView.builder(
            shrinkWrap: compact,
            scrollDirection: compact ? Axis.horizontal : Axis.vertical,
            physics: compact ? const NeverScrollableScrollPhysics() : null,
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
                          child: FFCard(
                            name: a.name,
                            kind: a.kind.label,
                            stamp: a.owner.label,
                            color: a.color,
                            icon: a.icon,
                            balance: store.balanceOf(a.id),
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
                            : SizedBox(height: 120, child: cards),
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
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(right: BorderSide(color: c.rule)),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Laid out at full width even while it folds, so nothing reflows
            // mid-animation — it just fades and is clipped.
            OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: _wide,
              maxWidth: _wide,
              child: IgnorePointer(
                ignoring: collapsed,
                child: AnimatedOpacity(
                  duration: _fold,
                  opacity: collapsed ? 0 : 1,
                  child: Column(
                    children: [
                      header,
                      Expanded(
                        child: store.accounts.isEmpty && !loading
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: emptyNote,
                              )
                            : cards,
                      ),
                      addButton,
                      footer,
                    ],
                  ),
                ),
              ),
            ),
            if (collapsed)
              Positioned.fill(
                child: SingleChildScrollView(
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
