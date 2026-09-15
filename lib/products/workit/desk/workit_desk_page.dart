// /workit/desk — the referral payout ledger. Private back office, not
// linked from any public page, and reading WorkIt's own Firestore
// (project workit-supremolabs) directly, the same rows the app shows a
// referrer for themselves.
//
// One question this page exists to answer: who is owed money, and has it
// been sent. Every row here was written by the revenueCatWebhook Cloud
// Function off a real Apple charge — the desk only ever moves a row's
// `status`, never its amounts, and WorkIt's firestore.rules enforce that
// rather than trusting this page.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../app/site_shell.dart';
import '../wi_colors.dart';
import 'workit_challenges_desk.dart';
import 'workit_desk_service.dart';

enum _DeskTab { referrals, challenges }

class WorkItDeskPage extends StatefulWidget {
  const WorkItDeskPage({super.key});

  @override
  State<WorkItDeskPage> createState() => _WorkItDeskPageState();
}

class _WorkItDeskPageState extends State<WorkItDeskPage> {
  bool _unlocked = false;
  _DeskTab _tab = _DeskTab.referrals;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return SiteShell(
      ground: WIColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 1080 : 760),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 48 : 22,
                isWide ? 56 : 32,
                isWide ? 48 : 22,
                96,
              ),
              child: _unlocked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _FilterChip(
                              label: 'REFERRAL PAYOUTS',
                              selected: _tab == _DeskTab.referrals,
                              onTap: () =>
                                  setState(() => _tab = _DeskTab.referrals),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'CHALLENGES',
                              selected: _tab == _DeskTab.challenges,
                              onTap: () =>
                                  setState(() => _tab = _DeskTab.challenges),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _tab == _DeskTab.referrals
                            ? _Ledger(isWide: isWide)
                            : WorkItChallengesDesk(isWide: isWide),
                      ],
                    )
                  : _Gate(onUnlock: () => setState(() => _unlocked = true)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeskTitle extends StatelessWidget {
  const _DeskTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: wiText(
      12,
      color: WIColors.inkFaint,
      weight: FontWeight.w600,
      letterSpacing: 3,
    ),
  );
}

class _Gate extends StatefulWidget {
  const _Gate({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final isAdmin = await signInWorkItAdmin();
      if (!mounted) return;
      if (isAdmin) {
        widget.onUnlock();
      } else {
        setState(() {
          _busy = false;
          _error = 'That account is not the WorkIt admin.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Sign-in failed. $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DeskTitle('REFERRAL LEDGER'),
        const SizedBox(height: 10),
        Text(
          'Sign in to see who is owed.',
          style: wiText(28, weight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : _signIn,
          style: FilledButton.styleFrom(
            backgroundColor: WIColors.tint,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(
            _busy ? 'Signing in…' : 'Sign in with Google',
            style: wiText(14, weight: FontWeight.w600, color: Colors.white),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Text(_error!, style: wiText(13, color: WIColors.plate25)),
        ],
      ],
    );
  }
}

enum _Filter { owed, paid, all }

class _Ledger extends StatefulWidget {
  const _Ledger({required this.isWide});
  final bool isWide;

  @override
  State<_Ledger> createState() => _LedgerState();
}

class _LedgerState extends State<_Ledger> {
  _Filter _filter = _Filter.owed;
  String? _busyId;

  Query<Map<String, dynamic>> get _query => workItDb
      .collection('referralPayouts')
      .orderBy('createdAt', descending: true);

  Future<void> _setStatus(String id, bool paid) async {
    setState(() => _busyId = id);
    try {
      await workItDb.collection('referralPayouts').doc(id).update({
        'status': paid ? 'paid' : 'unpaid',
        // Cleared on the way back, so a row's stamp never outlives the
        // payment it claims to record.
        'paidAt': paid ? FieldValue.serverTimestamp() : null,
      });
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  bool _matches(String status) => switch (_filter) {
    _Filter.owed => status == 'unpaid',
    _Filter.paid => status == 'paid' || status == 'clawback',
    _Filter.all => true,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DeskTitle('REFERRAL LEDGER'),
              const SizedBox(height: 12),
              Text(
                'Couldn’t read the ledger. ${snapshot.error}',
                style: wiText(14, color: WIColors.plate25, height: 1.5),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(color: WIColors.tint),
            ),
          );
        }
        final all = snapshot.data!.docs;
        var owed = 0.0;
        var paid = 0.0;
        var subscribers = 0;
        for (final doc in all) {
          final status = doc.data()['status'] as String? ?? 'unpaid';
          final amount = (doc.data()['commissionUsd'] as num?)?.toDouble() ?? 0;
          if (status == 'void') continue;
          subscribers++;
          if (status == 'unpaid') owed += amount;
          if (status == 'paid') paid += amount;
        }
        final rows = all.where((d) {
          return _matches(d.data()['status'] as String? ?? 'unpaid');
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DeskTitle('REFERRAL LEDGER'),
            const SizedBox(height: 10),
            Text(
              '20% of every referred first payment.',
              style: wiText(28, weight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 48,
              runSpacing: 20,
              children: [
                _Total(label: 'Owed now', value: _usd(owed), lead: true),
                _Total(label: 'Paid to date', value: _usd(paid)),
                _Total(label: 'Referred subscribers', value: '$subscribers'),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                for (final f in _Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: switch (f) {
                        _Filter.owed => 'OWED',
                        _Filter.paid => 'PAID',
                        _Filter.all => 'ALL',
                      },
                      selected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: WIColors.rule),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(switch (_filter) {
                  _Filter.owed => 'Nobody is owed anything right now.',
                  _Filter.paid => 'Nothing paid out yet.',
                  _Filter.all => 'No referred subscriptions yet.',
                }, style: wiText(15, color: WIColors.inkFaint)),
              )
            else
              for (final doc in rows)
                _Row(
                  data: doc.data(),
                  isWide: widget.isWide,
                  busy: _busyId == doc.id,
                  onToggle: (paid) => _setStatus(doc.id, paid),
                ),
          ],
        );
      },
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, this.lead = false});

  final String label;
  final String value;

  /// The one figure the page is actually opened for gets the size; the
  /// other two are context for it, not peers.
  final bool lead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: wiText(
            11,
            color: WIColors.inkFaint,
            weight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: wiText(
            lead ? 40 : 28,
            weight: FontWeight.w700,
            color: lead ? WIColors.plate15 : WIColors.ink,
            tabularFigures: true,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? WIColors.surfaceAlt : Colors.transparent,
          border: Border.all(color: selected ? WIColors.tint : WIColors.rule),
        ),
        child: Text(
          label,
          style: wiText(
            11,
            weight: FontWeight.w600,
            letterSpacing: 1.6,
            color: selected ? WIColors.ink : WIColors.inkFaint,
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.data,
    required this.isWide,
    required this.busy,
    required this.onToggle,
  });

  final Map<String, dynamic> data;
  final bool isWide;
  final bool busy;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'unpaid';
    final commission = (data['commissionUsd'] as num?)?.toDouble() ?? 0;
    final price = (data['priceUsd'] as num?)?.toDouble() ?? 0;
    // Email first — it is what you actually pay to. The uid is the last
    // resort, for a referrer whose account was deleted after earning.
    final uid = data['referrerUid'] as String? ?? '';
    final who =
        (data['referrerEmail'] as String?) ??
        (data['referrerName'] as String?) ??
        'uid ${uid.length > 8 ? uid.substring(0, 8) : uid}';
    final code = data['referralCode'] as String? ?? '—';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          who,
          style: wiText(15, weight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          '$code · ${_date(createdAt)} · '
          '${data['productId'] ?? 'unknown plan'} at ${_usd(price)}',
          style: wiText(12, color: WIColors.inkFaint),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final amount = Text(
      _usd(commission),
      style: wiText(
        20,
        weight: FontWeight.w700,
        tabularFigures: true,
        color: status == 'void' ? WIColors.inkFaint : WIColors.ink,
      ),
    );

    final action = _Action(status: status, busy: busy, onToggle: onToggle);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WIColors.rule)),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 24),
                amount,
                const SizedBox(width: 24),
                SizedBox(
                  width: 160,
                  child: Align(alignment: Alignment.centerRight, child: action),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [amount, action],
                ),
              ],
            ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.status,
    required this.busy,
    required this.onToggle,
  });

  final String status;
  final bool busy;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    // A refunded row is not a decision to make — it is a fact to read.
    if (status == 'void') {
      return _Tag('REFUNDED — NOT OWED', WIColors.inkFaint);
    }
    if (status == 'clawback') {
      return _Tag('PAID, THEN REFUNDED', WIColors.plate25);
    }
    final paid = status == 'paid';
    return TextButton(
      onPressed: busy ? null : () => onToggle(!paid),
      style: TextButton.styleFrom(
        foregroundColor: paid ? WIColors.inkFaint : WIColors.tint,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: paid ? WIColors.rule : WIColors.tint),
        ),
      ),
      child: Text(
        busy
            ? 'Saving…'
            : paid
            ? 'PAID — UNDO'
            : 'MARK PAID',
        style: wiText(
          11,
          weight: FontWeight.w600,
          letterSpacing: 1.4,
          color: paid ? WIColors.inkFaint : WIColors.tint,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: wiText(
      11,
      weight: FontWeight.w600,
      letterSpacing: 1.4,
      color: color,
    ),
  );
}

String _usd(double amount) => '\$${amount.toStringAsFixed(2)}';

String _date(DateTime? d) {
  if (d == null) return '—';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
