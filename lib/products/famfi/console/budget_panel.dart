// Budget tab: category table + "can we afford it?" — matches
// BudgetScreen/JuwaStore.affordability exactly (aggregate budget remaining,
// no per-account math the phone doesn't do either).
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/widgets.dart';

import '../ff_theme.dart';
import 'drawer.dart';

class BudgetPanel extends StatefulWidget {
  final JuwaStore store;
  final void Function(Widget drawer) openDrawer;
  final VoidCallback closeDrawer;

  const BudgetPanel({
    super.key,
    required this.store,
    required this.openDrawer,
    required this.closeDrawer,
  });

  @override
  State<BudgetPanel> createState() => _BudgetPanelState();
}

class _BudgetPanelState extends State<BudgetPanel> {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = widget.store;
    final spentAll = store.budgets.fold(0.0, (s, b) => s + store.spentNow(b));
    final targetAll = store.budgets.fold(0.0, (s, b) => s + b.monthlyTarget);

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Budget',
                style: ff(
                  32,
                  weight: FontWeight.w800,
                  color: c.ink,
                  spacing: -1,
                ),
              ),
              const SizedBox(width: 14),
              if (store.budgets.isNotEmpty)
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: ff(14.5, color: c.muted),
                      children: [
                        TextSpan(
                          text: ffMoney(spentAll),
                          style: ff(
                            14.5,
                            weight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                        const TextSpan(text: ' of '),
                        TextSpan(
                          text: ffMoney(targetAll),
                          style: ff(
                            14.5,
                            weight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => FFPopIn(child: _AffordDialog(store: store)),
                ),
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: const Text('Can we afford it?'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.ink,
                  side: BorderSide(color: c.rule),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Table(
            store: store,
            onOpen: (b) => openBudgetDetail(
              store,
              b,
              openDrawer: widget.openDrawer,
              closeDrawer: widget.closeDrawer,
            ),
            onAddNew: () => widget.openDrawer(
              BudgetDrawer(store: store, onClose: widget.closeDrawer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final JuwaStore store;
  final void Function(Budget) onOpen;
  final VoidCallback onAddNew;
  const _Table({
    required this.store,
    required this.onOpen,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (store.budgets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No budgets yet — add your first category.',
                style: ff(14, color: c.muted, weight: FontWeight.w600),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 34 + 14),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'CATEGORY',
                      style: ff(
                        11.5,
                        weight: FontWeight.w600,
                        color: c.muted,
                        spacing: 0.6,
                      ),
                    ),
                  ),
                  Expanded(flex: 3, child: Text('')),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'SPENT',
                      textAlign: TextAlign.right,
                      style: ff(
                        11.5,
                        weight: FontWeight.w600,
                        color: c.muted,
                        spacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'TARGET',
                      textAlign: TextAlign.right,
                      style: ff(
                        11.5,
                        weight: FontWeight.w600,
                        color: c.muted,
                        spacing: 0.6,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'LEFT',
                      textAlign: TextAlign.right,
                      style: ff(
                        11.5,
                        weight: FontWeight.w600,
                        color: c.muted,
                        spacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (final (i, b) in store.budgets.indexed)
            Reveal(
              index: i,
              child: _BudgetRow(
                store: store,
                budget: b,
                onTap: () => onOpen(b),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddNew,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: c.muted),
                    const SizedBox(width: 12),
                    Text('New category', style: ff(14, color: c.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final JuwaStore store;
  final Budget budget;
  final VoidCallback onTap;
  const _BudgetRow({
    required this.store,
    required this.budget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final spent = store.spentNow(budget);
    final remaining = store.budgetRemaining(budget);
    final over = remaining < 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.rule)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c.fill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.donut_small_rounded,
                  size: 17,
                  color: c.muted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Text(
                  budget.name,
                  style: ff(15, weight: FontWeight.w600, color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120),
                    child: BudgetBar(
                      spent: spent,
                      target: budget.monthlyTarget,
                      color: c.tint,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  ffMoney(spent),
                  textAlign: TextAlign.right,
                  style: ff(14.5, weight: FontWeight.w700, color: c.ink),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  ffMoney(budget.monthlyTarget),
                  textAlign: TextAlign.right,
                  style: ff(14, color: c.muted),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  ffMoney(remaining.abs()),
                  textAlign: TextAlign.right,
                  style: ff(
                    14.5,
                    weight: FontWeight.w700,
                    color: over ? c.bad : c.ink,
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

/// "Can we afford it?" — a one-off check, so it lives in a dialog rather than
/// taking a column off the category table.
class _AffordDialog extends StatefulWidget {
  final JuwaStore store;
  const _AffordDialog({required this.store});

  @override
  State<_AffordDialog> createState() => _AffordDialogState();
}

class _AffordDialogState extends State<_AffordDialog> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final amt = AmountField.parse(_amount.text);
    final result = amt == null ? null : widget.store.affordability(amt);
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Can we afford it?',
                style: ff(
                  20,
                  weight: FontWeight.w800,
                  color: c.ink,
                  spacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              ffRaisedFields(
                context,
                AmountField(
                  controller: _amount,
                  fontSize: 22,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (result != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (result.affordable ? c.good : c.bad).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result.affordable
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 18,
                        color: result.affordable ? c.good : c.bad,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.affordable
                              ? 'Yes, it fits'
                              : 'No — short ${ffAmount(result.shortfall)}',
                          style: ff(
                            14,
                            weight: FontWeight.w600,
                            color: result.affordable ? c.good : c.bad,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
