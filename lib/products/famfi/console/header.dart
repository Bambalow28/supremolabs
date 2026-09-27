// Tab switcher, search, notification bell, and the "+ New" button that sits
// above every panel.
import 'package:flutter/material.dart';
import 'package:juwa_wealth/models.dart';
import 'package:juwa_wealth/store.dart';
import 'package:juwa_wealth/ui/common.dart' show NotificationBell;

import '../ff_theme.dart';
import 'ff_tab.dart';

class ConsoleHeader extends StatelessWidget {
  final JuwaStore store;
  final FFTab tab;
  final ValueChanged<FFTab> onTabChanged;
  final TextEditingController search;
  final FocusNode searchFocus;
  final VoidCallback onNew;
  final void Function(Bill bill) onOpenBill;

  const ConsoleHeader({
    super.key,
    required this.store,
    required this.tab,
    required this.onTabChanged,
    required this.search,
    required this.searchFocus,
    required this.onNew,
    required this.onOpenBill,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Measured against this row's own available width, not the console's
    // overall compact breakpoint — the wallet rail eats a fixed 344px out of
    // that same width in the non-stacked layout, so a tablet in landscape (or
    // even a ~960px desktop window) can hand this row less space than a
    // stacked-compact phone width does. The keyboard-shortcut hints are the
    // first thing to go: meaningless on a touch tablet anyway.
    return LayoutBuilder(
      builder: (context, cons) {
        final tight = cons.maxWidth < 820;
        return Padding(
          padding: const EdgeInsets.fromLTRB(40, 18, 40, 14),
          child: Row(
            children: [
              for (final t in FFTab.values)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _TabButton(
                    label: switch (t) {
                      FFTab.ledger => 'Ledger',
                      FFTab.bills => 'Bills',
                      FFTab.payday => 'Payday',
                      FFTab.budget => 'Budget',
                    },
                    shortcut: '${FFTab.values.indexOf(t) + 1}',
                    showShortcut: !tight,
                    selected: tab == t,
                    onTap: () => onTabChanged(t),
                  ),
                ),
              // Expanded + right-aligned (not Spacer + Flexible, which split the
              // free space in half and crushed the field at mid widths).
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: tight ? 160 : 240),
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: search,
                        focusNode: searchFocus,
                        style: ff(14, color: c.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: c.surface,
                          hintText: tight ? 'Search' : 'Search everything',
                          hintStyle: ff(14, color: c.faint),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: c.faint,
                          ),
                          suffixIcon: tight
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Center(
                                    widthFactor: 1,
                                    child: _Kbd('⌘K'),
                                  ),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NotificationBell(store: store, onOpenBill: onOpenBill),
              const SizedBox(width: 8),
              tight
                  ? Material(
                      color: c.ink,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onNew,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: c.bg,
                          ),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onNew,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New'),
                      style: FilledButton.styleFrom(
                        backgroundColor: c.ink,
                        foregroundColor: c.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final String shortcut;
  final bool showShortcut;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.shortcut,
    this.showShortcut = true,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: selected ? c.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: ff(
                  15,
                  weight: FontWeight.w700,
                  color: selected ? c.ink : c.faint,
                ),
              ),
              if (showShortcut) ...[
                const SizedBox(width: 7),
                _Kbd(shortcut),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Kbd extends StatelessWidget {
  final String text;
  const _Kbd(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: c.rule),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: ff(10.5, weight: FontWeight.w600, color: c.faint),
      ),
    );
  }
}
