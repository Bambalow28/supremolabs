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
  final VoidCallback onRefresh;
  final bool refreshing;

  const ConsoleHeader({
    super.key,
    required this.store,
    required this.tab,
    required this.onTabChanged,
    required this.search,
    required this.searchFocus,
    required this.onNew,
    required this.onOpenBill,
    required this.onRefresh,
    this.refreshing = false,
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
        // Only a genuinely narrow row goes tight — not the rail folding, or the
        // controls would jump each time it opens and closes.
        final tight = cons.maxWidth < 700;
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.rule)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (refreshing)
                // A quiet cue that data is being fetched, under the skeletons.
                Positioned(
                  left: -24,
                  right: -24,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: c.tint,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              Row(
                children: [
                  // Tabs scroll rather than overflow when the row runs short.
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final t in FFTab.values)
                            _TabButton(
                              label: switch (t) {
                                FFTab.ledger => 'Transactions',
                                FFTab.bills => 'Bills',
                                FFTab.payday => 'Payday',
                                FFTab.budget => 'Budget',
                              },
                              compact: tight,
                              selected: tab == t,
                              onTap: () => onTabChanged(t),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Everything from here on is a fixed-width cluster pinned to
                  // the right edge, whatever the tabs or the rail are doing.
                  SizedBox(
                    width: tight ? 150 : 230,
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
                  const SizedBox(width: 8),
                  _RefreshButton(onTap: onRefresh, spinning: refreshing),
                  const SizedBox(width: 4),
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
            ],
          ),
        );
      },
    );
  }
}

/// A real tab: label over a 2px rule that fills with ink when selected.
class _TabButton extends StatelessWidget {
  final String label;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: ff(
                  15,
                  weight: FontWeight.w700,
                  color: selected ? c.ink : c.faint,
                ),
                child: Text(label),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 2,
                color: selected ? c.ink : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool spinning;
  const _RefreshButton({required this.onTap, required this.spinning});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didUpdateWidget(_RefreshButton old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_spin.isAnimating) _spin.repeat();
    if (!widget.spinning) _spin.stop();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Refresh everything',
    onPressed: widget.spinning ? null : widget.onTap,
    icon: RotationTransition(
      turns: _spin,
      child: Icon(Icons.refresh_rounded, size: 21, color: context.c.muted),
    ),
  );
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
