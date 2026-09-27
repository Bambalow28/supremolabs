// The wallet rail — stays open on every tab (per the mockup) so an edit on
// any panel shows on the cards immediately. Reorder, owner filter, and the
// account drawer all live here.
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

  const WalletRail({
    super.key,
    required this.store,
    required this.ownerFilter,
    required this.onOwnerFilterChanged,
    required this.selectedAccountId,
    required this.onSelectAccount,
    required this.onAddAccount,
    required this.deltas,
    this.compact = false,
  });

  static const _owners = [null, Owner.josh, Owner.judy, Owner.joint];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final visible = ownerFilter == null
        ? store.accounts
        : store.accounts.where((a) => a.owner == ownerFilter);
    final total = visible.fold(0.0, (s, a) => s + store.balanceOf(a.id));

    final header = Padding(
      padding: EdgeInsets.fromLTRB(compact ? 20 : 24, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Household', style: ff(13, color: c.muted)),
          const SizedBox(height: 2),
          Text(
            ffMoney(total),
            style: ff(30, weight: FontWeight.w800, color: c.ink, spacing: -0.9),
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
    );

    final cards = ReorderableListView.builder(
      shrinkWrap: compact,
      scrollDirection: compact ? Axis.horizontal : Axis.vertical,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(compact ? 20 : 22, 4, 20, 4),
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
        final card = ReorderableDragStartListener(
          key: ValueKey(a.id),
          index: i,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              right: compact ? 10 : 0,
              // Extra headroom so the delta pill (hangs below the card) never
              // overlaps "owed" or the card underneath it.
              top: deltas.containsKey(a.id) ? 6 : 0,
            ),
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
        );
        return card;
      },
    );

    final addButtonInner = OutlinedButton.icon(
      onPressed: onAddAccount,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text('Add account', style: ff(13.5, weight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: c.muted,
        side: BorderSide(color: c.rule, width: 1.5, style: BorderStyle.solid),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size.fromHeight(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
    final addButton = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 22),
      child: addButtonInner,
    );

    final footer = Padding(
      padding: EdgeInsets.fromLTRB(compact ? 20 : 24, 12, 20, 16),
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
              'Saved in this browser · phone sync arrives with Firebase',
              style: ff(11.5, color: c.faint),
              maxLines: 2,
            ),
          ),
        ],
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
            store.accounts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Text(
                      'No accounts yet — add your first card.',
                      style: ff(13, color: c.muted),
                    ),
                  )
                : SizedBox(height: 92, child: cards),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: addButtonInner,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 344,
      decoration: BoxDecoration(
        color: c.bg,
        border: Border(right: BorderSide(color: c.rule)),
      ),
      child: Column(
        children: [
          header,
          Expanded(
            child: store.accounts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No accounts yet — add your first card.',
                          style: ff(
                            14,
                            color: c.muted,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : cards,
          ),
          addButton,
          footer,
        ],
      ),
    );
  }
}
