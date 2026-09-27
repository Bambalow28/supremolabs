// FamFi's release page — the app's own wallet world, not the studio catalog.
//
// Per DESIGN.md's "Product pages" section: chrome (nav/footer) carries
// FamFi's cobalt via SiteShell; the body is entirely FamFi's own design —
// blue-black ground, full-colour wallet cards, HIS/HERS/JOINT stamps. This
// public page never names Josh or Judy: only the anonymised owner stamps.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/site_shell.dart';
import 'ff_theme.dart';

class _CardSpec {
  final String name;
  final String kind;
  final String stamp;
  final String color;
  final String icon;
  final double balance;
  const _CardSpec(
    this.name,
    this.kind,
    this.stamp,
    this.color,
    this.icon,
    this.balance,
  );
}

// Sample figures — mirrors the mockup's `accounts`, with owners anonymised
// to HIS / HERS / JOINT for the public page (never JOSH / JUDY here).
const _wallet = <_CardSpec>[
  _CardSpec('His Chequing', 'Chequing', 'HIS', 'cobalt', 'bank', 4812.40),
  _CardSpec('Her Chequing', 'Chequing', 'HERS', 'tomato', 'wallet', 3960.15),
  _CardSpec('House Fund', 'Savings', 'JOINT', 'forest', 'home', 12400),
  _CardSpec('Travel', 'Savings', 'HIS', 'marigold', 'plane', 1850),
  _CardSpec('Visa Infinite', 'Credit', 'HIS', 'graphite', 'card', -1240.18),
  _CardSpec('TFSA', 'Investment', 'HERS', 'plum', 'trending', 8420),
];

_CardSpec _byName(String name) => _wallet.firstWhere((a) => a.name == name);

class _Row {
  final IconData icon;
  final String title;
  final String phone;
  final String desk;
  const _Row(this.icon, this.title, this.phone, this.desk);
}

const _rows = <_Row>[
  _Row(
    Icons.account_balance_wallet_rounded,
    'Wallet',
    'Reorderable card stack, filtered by owner.',
    'Always open on the left. Every edit updates the cards as you make it.',
  ),
  _Row(
    Icons.receipt_long_rounded,
    'Ledger',
    'One transaction at a time, with receipts.',
    'A table with a keyboard entry row, for catching up on a month in one '
        'sitting.',
  ),
  _Row(
    Icons.event_repeat_rounded,
    'Bills',
    'Swipe to mark paid.',
    'A month calendar next to the due list, with paydays marked on it.',
  ),
  _Row(
    Icons.payments_rounded,
    'Payday',
    'Cheque in, split out, left over.',
    'The whole split on one screen, with the wallet showing where each '
        'dollar lands.',
  ),
  _Row(
    Icons.pie_chart_rounded,
    'Budget',
    'Monthly targets, manual spent.',
    'All categories in one table, plus a "can we afford it?" check.',
  ),
];

class FamFiPage extends StatelessWidget {
  const FamFiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return SiteShell(
      ground: FFColors.ground,
      trailing: _OpenConsoleLink(),
      children: [
        Theme(
          data: famFiTheme(Brightness.dark),
          // Capped so the hero doesn't drift apart on ultra-wide screens.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Column(
                children: [
                  _Hero(isWide: isWide),
                  const SizedBox(height: 40),
                  _PaydayBand(isWide: isWide),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OpenConsoleLink extends StatefulWidget {
  @override
  State<_OpenConsoleLink> createState() => _OpenConsoleLinkState();
}

class _OpenConsoleLinkState extends State<_OpenConsoleLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.push('/famfi/personal'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OPEN CONSOLE',
              style: ff(
                12,
                weight: FontWeight.w700,
                spacing: 2.2,
                color: _hover ? Colors.white : FFColors.accentInk,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: _hover ? Colors.white : FFColors.accentInk,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final bool isWide;
  const _Hero({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandMark(),
        const SizedBox(height: 34),
        Text(
          'Family finance, for the two of us.',
          style: ff(
            isWide ? 76 : 44,
            weight: FontWeight.w800,
            height: 0.98,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: Text(
            'Every account is a card in one shared wallet, stamped with '
            "whose it is. On payday the cheque is split across the cards, "
            'and FamFi shows what\'s left.',
            style: ff(19, height: 1.5, color: const Color(0xFFA2AAB7)),
          ),
        ),
        const SizedBox(height: 38),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 22,
          runSpacing: 16,
          children: [
            _PrimaryButton(onTap: () => context.push('/famfi/personal')),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Private to one household.\niPhone via TestFlight · not on '
                'the App Store.',
                style: ff(13.5, height: 1.45, color: const Color(0xFF8E96A3)),
              ),
            ),
          ],
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _WalletStack(),
        const SizedBox(height: 14),
        Text('Sample figures', style: ff(12.5, color: const Color(0xFF8E96A3))),
      ],
    );

    final pad = isWide ? 120.0 : 24.0;
    if (!isWide) {
      return Padding(
        padding: EdgeInsets.fromLTRB(pad, 56, pad, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 56), right],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 96, pad, 112),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 21, child: left),
          const SizedBox(width: 88),
          Expanded(flex: 20, child: right),
        ],
      ),
    );
  }
}

/// The FamFi mark: a navy tile holding two tilted swatch cards behind a
/// white wallet shape — built from plain Containers, no imagery.
class _BrandMark extends StatelessWidget {
  const _BrandMark();
  static const size = 34.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF12203F),
              borderRadius: BorderRadius.circular(size * 0.26),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: -0.14,
                  child: Container(
                    width: size * 0.62,
                    height: size * 0.42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0B429),
                      borderRadius: BorderRadius.circular(size * 0.09),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(size * 0.04, size * 0.03),
                  child: Container(
                    width: size * 0.62,
                    height: size * 0.42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5BE8),
                      borderRadius: BorderRadius.circular(size * 0.09),
                    ),
                  ),
                ),
                Positioned(
                  bottom: size * 0.02,
                  child: Container(
                    width: size * 0.82,
                    height: size * 0.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFF3),
                      borderRadius: BorderRadius.circular(size * 0.14),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: size * 0.12),
                        child: Container(
                          width: size * 0.13,
                          height: size * 0.13,
                          decoration: const BoxDecoration(
                            color: Color(0xFF12203F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'FamFi',
          style: ff(18, weight: FontWeight.w800, color: Colors.white),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PrimaryButton({required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF3D68F0) : FFColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Open the console',
                style: ff(15, weight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The stacked wallet: six cards, each stepped 64px lower than the last.
/// Hovering a card lifts it 14px (easeOutQuart, ~420ms).
class _WalletStack extends StatelessWidget {
  const _WalletStack();

  static const _cardHeight = 230.0;
  static const _step = 64.0;

  @override
  Widget build(BuildContext context) {
    final stackHeight = _cardHeight + _step * (_wallet.length - 1);
    return SizedBox(
      height: stackHeight,
      child: Stack(
        children: [
          for (var i = 0; i < _wallet.length; i++)
            Positioned(
              top: i * _step,
              left: 0,
              right: 0,
              child: _StackCard(spec: _wallet[i]),
            ),
        ],
      ),
    );
  }
}

class _StackCard extends StatefulWidget {
  final _CardSpec spec;
  const _StackCard({required this.spec});

  @override
  State<_StackCard> createState() => _StackCardState();
}

class _StackCardState extends State<_StackCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 420),
        curve: Curves.easeOutQuart,
        transform: Matrix4.translationValues(0, _hover ? -14 : 0, 0),
        child: FFCard(
          name: widget.spec.name,
          kind: widget.spec.kind,
          stamp: widget.spec.stamp,
          color: widget.spec.color,
          icon: widget.spec.icon,
          balance: widget.spec.balance,
          height: _WalletStack._cardHeight,
        ),
      ),
    );
  }
}

// ─── Payday band ────────────────────────────────────────────────────────────

class _PaydayBand extends StatelessWidget {
  final bool isWide;
  const _PaydayBand({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final pad = isWide ? 120.0 : 24.0;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E222A))),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 112, pad, 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payday takes a minute.',
              style: ff(
                isWide ? 44 : 30,
                weight: FontWeight.w800,
                height: 1.02,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                "Type in the cheque. Each bill due before the next payday is "
                "paid from the account it's assigned to, and the rest is "
                'left in hand.',
                style: ff(17, height: 1.5, color: const Color(0xFFA2AAB7)),
              ),
            ),
            const SizedBox(height: 52),
            _Flow(isWide: isWide),
            const SizedBox(height: 112),
            _Keeps(isWide: isWide),
          ],
        ),
      ),
    );
  }
}

class _Flow extends StatelessWidget {
  final bool isWide;
  const _Flow({required this.isWide});

  @override
  Widget build(BuildContext context) =>
      // The three-column flow needs ~1000px; below that it stacks, even when
      // the hero is still side by side.
      LayoutBuilder(
        builder: (context, box) => _build(isWide && box.maxWidth >= 1000),
      );

  Widget _build(bool isWide) {
    final cheque = _ChequeBox();
    final lanes = _Lanes(isWide: isWide);
    final left = _LeftBox();

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cheque,
          const SizedBox(height: 24),
          lanes,
          const SizedBox(height: 24),
          left,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 260, child: cheque),
          const SizedBox(width: 28),
          Expanded(child: lanes),
          const SizedBox(width: 28),
          SizedBox(width: 250, child: left),
        ],
      ),
    );
  }
}

class _ChequeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "His cheque · Fri, Sep 25",
            style: ff(13, color: const Color(0xFFA2AAB7)),
          ),
          const SizedBox(height: 6),
          Text(
            ffMoney(3250.00),
            style: ff(38, weight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.south_east_rounded,
                size: 15,
                color: Color(0xFF8E96A3),
              ),
              const SizedBox(width: 6),
              Text(
                'into His Chequing',
                style: ff(13, color: const Color(0xFF8E96A3)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeftBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2A2F38), width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Left in hand', style: ff(13, color: const Color(0xFFA2AAB7))),
          const SizedBox(height: 6),
          Text(
            ffMoney(1166.02),
            style: ff(
              38,
              weight: FontWeight.w800,
              color: const Color(0xFF4CC08E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'until Fri, Oct 9',
            style: ff(13, color: const Color(0xFF8E96A3)),
          ),
        ],
      ),
    );
  }
}

class _LaneSpec {
  final String label;
  final String accountName;
  final double delta;
  const _LaneSpec(this.label, this.accountName, this.delta);
}

const _lanes = <_LaneSpec>[
  _LaneSpec('Rent · Oct 1', 'House Fund', 1850),
  _LaneSpec('Car insurance, Gym ×2', 'Visa Infinite', 233.98),
];

class _Lanes extends StatelessWidget {
  final bool isWide;
  const _Lanes({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _lanes.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          _Lane(spec: _lanes[i], isWide: isWide),
        ],
      ],
    );
  }
}

class _Lane extends StatelessWidget {
  final _LaneSpec spec;
  final bool isWide;
  const _Lane({required this.spec, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final account = _byName(spec.accountName);
    final card = SizedBox(
      width: isWide ? 240 : null,
      child: FFCard(
        name: account.name,
        kind: account.kind,
        stamp: account.stamp,
        color: account.color,
        icon: account.icon,
        balance: spec.delta,
        height: 64,
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(spec.label, style: ff(13.5, color: const Color(0xFFA2AAB7))),
          const SizedBox(height: 8),
          card,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            spec.label,
            textAlign: TextAlign.right,
            style: ff(13.5, color: const Color(0xFFA2AAB7)),
          ),
        ),
        const SizedBox(width: 18),
        const SizedBox(
          width: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF2A2F38), width: 2),
              ),
            ),
            child: SizedBox(height: 1),
          ),
        ),
        const SizedBox(width: 18),
        card,
      ],
    );
  }
}

// ─── Comparison table ───────────────────────────────────────────────────────

class _Keeps extends StatelessWidget {
  final bool isWide;
  const _Keeps({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1C2026))),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: isWide
              ? Row(
                  children: const [
                    SizedBox(width: 44),
                    SizedBox(width: 200, child: _HeadLabel('IN THE APP')),
                    SizedBox(width: 20),
                    Expanded(child: _HeadLabel('ON THE PHONE')),
                    SizedBox(width: 20),
                    Expanded(
                      child: _HeadLabel('ON THE DESK · /famfi/personal'),
                    ),
                  ],
                )
              : const Row(
                  children: [
                    SizedBox(width: 44),
                    Expanded(
                      child: _HeadLabel('ON THE DESK · /famfi/personal'),
                    ),
                  ],
                ),
        ),
        for (final row in _rows) _KeepsRow(row: row, isWide: isWide),
      ],
    );
  }
}

class _HeadLabel extends StatelessWidget {
  final String text;
  const _HeadLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: ff(
        12,
        weight: FontWeight.w600,
        spacing: 1.4,
        color: const Color(0xFF8E96A3),
      ),
    );
  }
}

class _KeepsRow extends StatelessWidget {
  final _Row row;
  final bool isWide;
  const _KeepsRow({required this.row, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final title = Text(
      row.title,
      style: ff(20, weight: FontWeight.w700, color: Colors.white),
    );
    final phone = Text(
      row.phone,
      style: ff(15, height: 1.5, color: const Color(0xFFA2AAB7)),
    );
    final desk = Text(
      row.desk,
      style: ff(15, height: 1.5, color: Colors.white),
    );

    final icon = Icon(row.icon, size: 22, color: FFColors.accentInk);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1C2026))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 44, child: icon),
                SizedBox(width: 200, child: title),
                const SizedBox(width: 20),
                Expanded(child: phone),
                const SizedBox(width: 20),
                Expanded(child: desk),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 44, child: icon),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 10), desk],
                  ),
                ),
              ],
            ),
    );
  }
}
