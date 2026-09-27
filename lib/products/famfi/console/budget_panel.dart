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
  final _afford = TextEditingController();

  @override
  void dispose() {
    _afford.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final store = widget.store;
    final amount = AmountField.parse(_afford.text);
    final result = amount == null ? null : store.affordability(amount);
    final spentAll = store.budgets.fold(0.0, (s, b) => s + store.spentNow(b));
    final targetAll = store.budgets.fold(0.0, (s, b) => s + b.monthlyTarget);

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
                Text.rich(
                  TextSpan(
                    style: ff(14.5, color: c.muted),
                    children: [
                      TextSpan(
                        text: ffMoney(spentAll),
                        style: ff(14.5, weight: FontWeight.w700, color: c.ink),
                      ),
                      const TextSpan(text: ' of '),
                      TextSpan(
                        text: ffMoney(targetAll),
                        style: ff(14.5, weight: FontWeight.w700, color: c.ink),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, cons) {
              final stacked = cons.maxWidth < 820;
              final table = _Table(
                store: store,
                onOpen: (b) => widget.openDrawer(
                  BudgetDrawer(
                    store: store,
                    budget: b,
                    onClose: widget.closeDrawer,
                  ),
                ),
                onAddNew: () => widget.openDrawer(
                  BudgetDrawer(store: store, onClose: widget.closeDrawer),
                ),
              );
              final afford = _Afford(
                controller: _afford,
                onChanged: () => setState(() {}),
                result: result,
              );
              if (stacked) {
                return Column(
                  children: [table, const SizedBox(height: 24), afford],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: table),
                    const SizedBox(width: 24),
                    SizedBox(width: 340, child: afford),
                  ],
                ),
              );
            },
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
          for (final b in store.budgets)
            _BudgetRow(store: store, budget: b, onTap: () => onOpen(b)),
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

class _Afford extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final AffordabilityResult? result;
  const _Afford({
    required this.controller,
    required this.onChanged,
    required this.result,
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
            'Can we afford it?',
            style: ff(17, weight: FontWeight.w800, color: c.ink, spacing: -0.3),
          ),
          const SizedBox(height: 14),
          AmountField(
            controller: controller,
            fontSize: 22,
            onChanged: (_) => onChanged(),
          ),
          if (result != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (result!.affordable ? c.good : c.bad).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    result!.affordable
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 18,
                    color: result!.affordable ? c.good : c.bad,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result!.affordable
                          ? 'Yes, it fits'
                          : 'No — short ${ffMoney(result!.shortfall)}',
                      style: ff(
                        14,
                        weight: FontWeight.w600,
                        color: result!.affordable ? c.good : c.bad,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
