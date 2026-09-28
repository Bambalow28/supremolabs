// /workit/desk — Challenges tab. Sibling to the referral ledger: same gate,
// same WorkIt Firestore project, same "the desk only ever moves a status
// field" posture. Approve/finalize/publish here are plain Firestore writes;
// the WorkIt Cloud Function does the actual scoring, ranking and
// notifying off the `status` value this page sets — this file never ranks
// anyone itself. It only reads the challenge doc shape it needs to render;
// it does not import anything from the workit app repo.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../wi_colors.dart';
import 'workit_desk_service.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class WorkItChallengesDesk extends StatefulWidget {
  const WorkItChallengesDesk({super.key, required this.isWide});
  final bool isWide;

  @override
  State<WorkItChallengesDesk> createState() => _WorkItChallengesDeskState();
}

class _WorkItChallengesDeskState extends State<WorkItChallengesDesk> {
  bool _showAll = false;

  Query<Map<String, dynamic>> get _query => workItDb
      .collection('challenges')
      .orderBy('submittedAt', descending: true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Couldn’t read challenges. ${snapshot.error}',
            style: wiText(14, color: WIColors.plate25, height: 1.5),
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
        final docs = snapshot.data!.docs;
        final pending = docs.where((d) => d.data()['status'] == 'pending');
        final approved = docs.where((d) => d.data()['status'] == 'approved');
        final finalized = docs.where(
          (d) =>
              d.data()['status'] == 'final' ||
              d.data()['status'] == 'finalizeRequested',
        );
        final now = DateTime.now();
        final readyToFinalize = approved
            .where((d) => _showAll || _pastFinalizeWindow(d.data(), now))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Head('WAITING FOR REVIEW', pending.length),
            const SizedBox(height: 14),
            if (pending.isEmpty)
              _Empty('Nothing waiting on you.')
            else
              for (final doc in pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _PendingCard(doc: doc, isWide: widget.isWide),
                ),
            const SizedBox(height: 36),
            _Head('LIVE & UPCOMING', approved.length),
            const SizedBox(height: 14),
            if (approved.isEmpty)
              _Empty('No approved challenges right now.')
            else
              for (final doc in approved) _ApprovedRow(doc: doc),
            const SizedBox(height: 36),
            Row(
              children: [
                Expanded(
                  child: _Head('READY TO FINALIZE', readyToFinalize.length),
                ),
                _ShowAllToggle(
                  value: _showAll,
                  onChanged: (v) => setState(() => _showAll = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (readyToFinalize.isEmpty)
              _Empty('Nothing past its late window yet.')
            else
              for (final doc in readyToFinalize)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _FinalizeCard(doc: doc, isWide: widget.isWide),
                ),
            const SizedBox(height: 36),
            _Head('FINAL', finalized.length),
            const SizedBox(height: 14),
            if (finalized.isEmpty)
              _Empty('No results published yet.')
            else
              for (final doc in finalized)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _FinalCard(doc: doc, isWide: widget.isWide),
                ),
          ],
        );
      },
    );
  }
}

// ---- shared bits ------------------------------------------------------

DateTime? _parseYmd(String? s) {
  final parts = s?.split('-');
  if (parts == null || parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// Last day of the challenge, as a date. Matches the app's
/// `Challenge.endDate = startDate + (lengthDays - 1)`.
DateTime? _endDate(Map<String, dynamic> data) {
  final start = _parseYmd(data['startDate'] as String?);
  final lengthDays = (data['lengthDays'] as num?)?.toInt();
  if (start == null || lengthDays == null) return null;
  return start.add(Duration(days: lengthDays - 1));
}

/// The last day's late-sync window closes at `dayClose = dayZero +
/// lengthDays + 6h`, i.e. 30h after the end date's local midnight —
/// ponytail: uses this browser's local clock for "now", same as every
/// other date math on this page, not the athlete's own timezone.
bool _pastFinalizeWindow(Map<String, dynamic> data, DateTime now) {
  final end = _endDate(data);
  if (end == null) return false;
  return now.isAfter(end.add(const Duration(hours: 30)));
}

String _fmtDate(DateTime? d) {
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
  return '${months[d.month - 1]} ${d.day}';
}

String _fmtDateTime(DateTime? d) {
  if (d == null) return '—';
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'am' : 'pm';
  return '${_fmtDate(d)}, $hour12:$minute $ampm';
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: WIColors.surface,
      shape: const RoundedRectangleBorder(),
      title: Text(title, style: wiText(16, weight: FontWeight.w700)),
      content: Text(
        body,
        style: wiText(13, color: WIColors.inkMuted, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: wiText(13, color: WIColors.inkFaint)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: wiText(
              13,
              weight: FontWeight.w600,
              color: danger ? WIColors.plate25 : WIColors.tint,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A dialog with one required text field (note/reason). Returns null if
/// cancelled or left blank.
Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: WIColors.surface,
      shape: const RoundedRectangleBorder(),
      title: Text(title, style: wiText(16, weight: FontWeight.w700)),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 3,
        style: wiText(14),
        cursorColor: WIColors.tint,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: wiText(14, color: WIColors.inkFaint),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: wiText(13, color: WIColors.inkFaint)),
        ),
        TextButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.pop(context, text);
          },
          child: Text(
            confirmLabel,
            style: wiText(13, weight: FontWeight.w600, color: WIColors.tint),
          ),
        ),
      ],
    ),
  );
}

class _Head extends StatelessWidget {
  const _Head(this.label, this.count);
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: wiText(
          12,
          color: WIColors.inkFaint,
          weight: FontWeight.w600,
          letterSpacing: 3,
        ),
      ),
      if (count > 0) ...[
        const SizedBox(width: 8),
        Text('$count', style: wiText(12, color: WIColors.inkFaint)),
      ],
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: wiText(14, color: WIColors.inkFaint));
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: WIColors.surface,
      border: Border.all(color: WIColors.rule),
    ),
    child: child,
  );
}

class _DeskButton extends StatelessWidget {
  const _DeskButton({
    required this.label,
    required this.onTap,
    this.danger = false,
    this.fill = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final bool fill;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final color = danger ? WIColors.plate25 : WIColors.tint;
    final disabled = onTap == null && !busy;
    if (fill) {
      return FilledButton(
        onPressed: busy ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(
          busy ? 'Working…' : label,
          style: wiText(
            12,
            weight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      );
    }
    return TextButton(
      onPressed: busy ? null : onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: disabled ? WIColors.rule : color),
        ),
      ),
      child: Text(
        busy ? 'Working…' : label,
        style: wiText(
          11,
          weight: FontWeight.w600,
          letterSpacing: 1,
          color: disabled ? WIColors.inkFaint : color,
        ),
      ),
    );
  }
}

class _ShowAllToggle extends StatelessWidget {
  const _ShowAllToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? WIColors.surfaceAlt : Colors.transparent,
        border: Border.all(color: value ? WIColors.tint : WIColors.rule),
      ),
      child: Text(
        'SHOW ALL',
        style: wiText(
          10,
          weight: FontWeight.w600,
          letterSpacing: 1.4,
          color: value ? WIColors.ink : WIColors.inkFaint,
        ),
      ),
    ),
  );
}

// ---- Waiting for review -------------------------------------------------

class _PendingCard extends StatefulWidget {
  const _PendingCard({required this.doc, required this.isWide});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool isWide;

  @override
  State<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends State<_PendingCard> {
  late final List<TextEditingController> _prizeControllers;
  bool _previewOpen = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final prizes = (widget.doc.data()['prizes'] as List?) ?? const [];
    _prizeControllers = List.generate(
      3,
      (i) =>
          TextEditingController(text: i < prizes.length ? '${prizes[i]}' : ''),
    );
  }

  @override
  void dispose() {
    for (final c in _prizeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _approve() async {
    final ok = await _confirm(
      context,
      title: 'Approve and list?',
      body: 'This lists the challenge for every athlete and locks its dates.',
      confirmLabel: 'Approve',
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.doc.reference.update({
        'status': 'approved',
        'prizes': [for (final c in _prizeControllers) c.text.trim()],
        'approvedAt': FieldValue.serverTimestamp(),
        'reviewNote': '',
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestChanges() async {
    final note = await _promptText(
      context,
      title: 'Request changes',
      hint: 'What needs to change before this can be approved?',
      confirmLabel: 'Send',
    );
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.doc.reference.update({
        'status': 'changesRequested',
        'reviewNote': note,
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data();
    final title = data['title'] as String? ?? 'Untitled';
    final creator = data['creatorName'] as String? ?? 'Unknown';
    final start = _parseYmd(data['startDate'] as String?);
    final end = _endDate(data);
    final lengthDays = (data['lengthDays'] as num?)?.toInt() ?? 0;
    final summary = data['summary'] as String? ?? '';
    final submittedAt = (data['submittedAt'] as Timestamp?)?.toDate();
    final goal = data['nutritionGoal'] as Map<String, dynamic>?;
    final schedule = (data['schedule'] as List?) ?? const [];

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: wiText(19, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('by $creator', style: wiText(13, color: WIColors.inkFaint)),
        const SizedBox(height: 8),
        Text(
          '${_fmtDate(start)} – ${_fmtDate(end)} · $lengthDays days'
          '${goal != null ? ' · ${_describeGoal(goal)}' : ''}',
          style: wiText(12, color: WIColors.inkMuted, tabularFigures: true),
        ),
        Text(
          'Submitted ${_fmtDateTime(submittedAt)}',
          style: wiText(12, color: WIColors.inkFaint),
        ),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            summary,
            style: wiText(13.5, color: WIColors.inkMuted, height: 1.4),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            _DeskButton(
              label: _previewOpen ? 'Hide days' : 'Preview days',
              onTap: () => setState(() => _previewOpen = !_previewOpen),
            ),
            const SizedBox(width: 8),
            _DeskButton(
              label: 'Request changes',
              danger: true,
              busy: _busy,
              onTap: _busy ? null : _requestChanges,
            ),
          ],
        ),
        if (_previewOpen) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: WIColors.rule),
          const SizedBox(height: 10),
          for (var i = 0; i < schedule.length && start != null; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _scheduleLine(start.add(Duration(days: i)), schedule[i]),
            ),
        ],
      ],
    );

    final prizes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIZES',
          style: wiText(
            11,
            weight: FontWeight.w600,
            letterSpacing: 1.6,
            color: WIColors.inkFaint,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    ['1st', '2nd', '3rd'][i],
                    style: wiText(12, color: WIColors.inkFaint),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _prizeControllers[i],
                    style: wiText(13),
                    cursorColor: WIColors.tint,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Prize for ${['1st', '2nd', '3rd'][i]}',
                      hintStyle: wiText(13, color: WIColors.inkFaint),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: WIColors.rule),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(color: WIColors.rule),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: WIColors.tint),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: _DeskButton(
            label: 'Approve and list',
            fill: true,
            busy: _busy,
            onTap: _busy ? null : _approve,
          ),
        ),
      ],
    );

    return _Card(
      child: widget.isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 13, child: details),
                const SizedBox(width: 28),
                Expanded(flex: 10, child: prizes),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 20),
                Container(height: 1, color: WIColors.rule),
                const SizedBox(height: 16),
                prizes,
              ],
            ),
    );
  }
}

String _describeGoal(Map<String, dynamic> goal) {
  final metric = goal['metric'] as String?;
  final min = (goal['min'] as num?)?.toInt();
  final max = (goal['max'] as num?)?.toInt();
  if (metric == 'protein') return 'protein ≥ ${min ?? 0} g';
  if (min != null && max != null) return 'calories $min–$max';
  if (min != null) return 'calories ≥ $min';
  if (max != null) return 'calories ≤ $max';
  return 'calories';
}

Widget _scheduleLine(DateTime date, dynamic dayJson) {
  final label = _weekdayNames[(date.weekday - 1) % 7];
  if (dayJson == null) {
    return Text(
      '$label — Rest',
      style: wiText(12.5, color: WIColors.inkFaint, tabularFigures: true),
    );
  }
  final map = dayJson as Map<String, dynamic>;
  final name = map['name'] as String? ?? 'Workout';
  final slots = (map['slots'] as List?) ?? const [];
  var sets = 0;
  for (final slot in slots) {
    sets += ((slot as Map)['sets'] as num?)?.toInt() ?? 0;
  }
  return Text(
    '$label — $name · $sets sets',
    style: wiText(12.5, color: WIColors.inkMuted, tabularFigures: true),
  );
}

// ---- Live & upcoming ----------------------------------------------------

class _ApprovedRow extends StatelessWidget {
  const _ApprovedRow({required this.doc});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled';
    final start = _parseYmd(data['startDate'] as String?);
    final end = _endDate(data);
    final participantCount = (data['participantCount'] as num?)?.toInt() ?? 0;
    final now = DateTime.now();
    final phase = start == null || end == null
        ? '—'
        : now.isBefore(start)
        ? 'Opens ${_fmtDate(start)}'
        : now.isAfter(end.add(const Duration(days: 1)))
        ? 'Ended ${_fmtDate(end)}'
        : 'Live · ends ${_fmtDate(end)}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WIColors.rule)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: wiText(15, weight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(phase, style: wiText(12.5, color: WIColors.inkFaint)),
          const SizedBox(width: 20),
          Text(
            '$participantCount joined',
            style: wiText(12.5, color: WIColors.inkMuted, tabularFigures: true),
          ),
        ],
      ),
    );
  }
}

// ---- Ready to finalize ---------------------------------------------------

class _ParticipantVM {
  _ParticipantVM({required this.uid, required this.data, required this.flags});
  final String uid;
  final Map<String, dynamic> data;
  final List<String> flags;
}

class _FinalizeCard extends StatefulWidget {
  const _FinalizeCard({required this.doc, required this.isWide});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool isWide;

  @override
  State<_FinalizeCard> createState() => _FinalizeCardState();
}

class _FinalizeCardState extends State<_FinalizeCard> {
  bool _expanded = false;
  bool _loading = false;
  List<_ParticipantVM>? _participants;
  bool _publishing = false;

  Future<void> _toggle() async {
    setState(() => _expanded = !_expanded);
    // Lazy: only ever hit participants/days once per card, on first expand.
    if (_expanded && _participants == null) {
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snap = await widget.doc.reference.collection('participants').get();
      final lengthDays =
          (widget.doc.data()['lengthDays'] as num?)?.toInt() ?? 0;
      final vms = await Future.wait(
        snap.docs.map((p) async {
          final dayZero = p.data()['dayZero'] as Timestamp?;
          final days = await p.reference.collection('days').get();
          final flags = dayZero == null
              ? const <String>[]
              : _computeFlags(
                  dayZero: dayZero,
                  lengthDays: lengthDays,
                  days: days.docs,
                );
          return _ParticipantVM(uid: p.id, data: p.data(), flags: flags);
        }),
      );
      vms.sort((a, b) {
        final byScore = (b.data['score'] as num? ?? 0).compareTo(
          a.data['score'] as num? ?? 0,
        );
        if (byScore != 0) return byScore;
        final at = (a.data['reachedScoreAt'] as Timestamp?)?.toDate();
        final bt = (b.data['reachedScoreAt'] as Timestamp?)?.toDate();
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return at.compareTo(bt);
      });
      if (mounted) setState(() => _participants = vms);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _disqualify(_ParticipantVM p) async {
    final reason = await _promptText(
      context,
      title: 'Disqualify ${p.data['displayName'] ?? p.uid}?',
      hint: 'Reason',
      confirmLabel: 'Disqualify',
    );
    if (reason == null) return;
    await widget.doc.reference.collection('participants').doc(p.uid).update({
      'disqualified': true,
      'dqReason': reason,
    });
    if (!mounted) return;
    setState(() {
      p.data['disqualified'] = true;
      p.data['dqReason'] = reason;
    });
  }

  Future<void> _publish() async {
    final ok = await _confirm(
      context,
      title: 'Publish results?',
      body:
          'Writes the top 3, gives every participant their final place, and '
          'sends notifications. It can’t be undone.',
      confirmLabel: 'Publish',
      danger: true,
    );
    if (!ok || !mounted) return;
    setState(() => _publishing = true);
    try {
      await widget.doc.reference.update({'status': 'finalizeRequested'});
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data();
    final title = data['title'] as String? ?? 'Untitled';
    final end = _endDate(data);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: wiText(17, weight: FontWeight.w700),
                  ),
                ),
                Text(
                  'ended ${_fmtDate(end)}',
                  style: wiText(12, color: WIColors.inkFaint),
                ),
                const SizedBox(width: 10),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: WIColors.inkFaint,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: WIColors.rule),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(color: WIColors.tint),
                ),
              )
            else if (_participants == null || _participants!.isEmpty)
              const _Empty('No participants.')
            else ...[
              for (var i = 0; i < _participants!.length; i++)
                _ParticipantRow(
                  rank: i + 1,
                  vm: _participants![i],
                  isWide: widget.isWide,
                  onDisqualify: () => _disqualify(_participants![i]),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Publishing writes the top 3, gives every participant '
                      'their final place, and sends notifications. It can’t '
                      'be undone.',
                      style: wiText(12, color: WIColors.inkFaint, height: 1.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _DeskButton(
                    label: 'Publish results',
                    fill: true,
                    busy: _publishing,
                    onTap: _publishing ? null : _publish,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// sessions < 10 min; an identical protein total held for 5+ days running;
/// 3+ days synced inside the last 10 minutes before that day's close.
/// Heuristics that point attention, never automatic disqualifications.
List<String> _computeFlags({
  required Timestamp dayZero,
  required int lengthDays,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> days,
}) {
  final byIndex = <int, Map<String, dynamic>>{};
  for (final d in days) {
    final i = int.tryParse(d.id);
    if (i != null) byIndex[i] = d.data();
  }

  final flags = <String>[];

  var shortSessions = 0;
  for (final data in byIndex.values) {
    final workout = data['workout'] as Map<String, dynamic>?;
    final durationMin = (workout?['durationMin'] as num?)?.toInt();
    if (workout != null && durationMin != null && durationMin < 10) {
      shortSessions++;
    }
  }
  if (shortSessions > 0) {
    flags.add(
      '$shortSessions session${shortSessions == 1 ? '' : 's'} under 10 min',
    );
  }

  var streak = 0;
  var bestStreak = 0;
  int? prevProtein;
  for (var i = 0; i < lengthDays; i++) {
    final protein = (byIndex[i]?['proteinG'] as num?)?.toInt();
    if (protein != null && protein == prevProtein) {
      streak++;
    } else {
      streak = protein == null ? 0 : 1;
    }
    if (streak > bestStreak) bestStreak = streak;
    prevProtein = protein;
  }
  if (bestStreak >= 5) {
    flags.add('Same protein total $bestStreak days in a row');
  }

  final zero = dayZero.toDate();
  var lastMinuteSyncs = 0;
  byIndex.forEach((i, data) {
    final syncedAt = (data['syncedAt'] as Timestamp?)?.toDate();
    if (syncedAt == null) return;
    final close = zero.add(Duration(days: i + 1, hours: 6));
    if (!syncedAt.isBefore(close.subtract(const Duration(minutes: 10))) &&
        syncedAt.isBefore(close)) {
      lastMinuteSyncs++;
    }
  });
  if (lastMinuteSyncs >= 3) {
    flags.add(
      '$lastMinuteSyncs days synced in the last 10 min of their window',
    );
  }

  return flags;
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.rank,
    required this.vm,
    required this.isWide,
    required this.onDisqualify,
  });

  final int rank;
  final _ParticipantVM vm;
  final bool isWide;
  final VoidCallback onDisqualify;

  @override
  Widget build(BuildContext context) {
    final data = vm.data;
    final name = data['displayName'] as String? ?? vm.uid;
    final score = (data['score'] as num?)?.toInt() ?? 0;
    final reachedAt = (data['reachedScoreAt'] as Timestamp?)?.toDate();
    final disqualified = data['disqualified'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WIColors.rule)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank',
              style: wiText(13, color: WIColors.inkFaint, tabularFigures: true),
            ),
          ),
          SizedBox(
            width: isWide ? 140 : 96,
            child: Text(
              name,
              style: wiText(
                14,
                weight: FontWeight.w600,
                color: disqualified ? WIColors.inkFaint : WIColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$score',
              style: wiText(13, tabularFigures: true, color: WIColors.inkMuted),
            ),
          ),
          if (isWide)
            SizedBox(
              width: 150,
              child: Text(
                _fmtDateTime(reachedAt),
                style: wiText(
                  12,
                  color: WIColors.inkFaint,
                  tabularFigures: true,
                ),
              ),
            ),
          Expanded(
            child: disqualified
                ? Text(
                    'Disqualified — ${data['dqReason'] ?? ''}',
                    style: wiText(12, color: WIColors.plate25),
                  )
                : vm.flags.isEmpty
                ? Text('None', style: wiText(12, color: WIColors.inkFaint))
                : Text(
                    vm.flags.join('\n'),
                    style: wiText(12, color: WIColors.plate15, height: 1.4),
                  ),
          ),
          if (!disqualified)
            _DeskButton(label: 'Disqualify', danger: true, onTap: onDisqualify),
        ],
      ),
    );
  }
}

// ---- Final ----------------------------------------------------------------

class _FinalCard extends StatelessWidget {
  const _FinalCard({required this.doc, required this.isWide});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final title = data['title'] as String? ?? 'Untitled';
    final status = data['status'] as String?;

    if (status == 'finalizeRequested') {
      return _Card(
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: wiText(16, weight: FontWeight.w700)),
            ),
            Text('Finalizing…', style: wiText(12, color: WIColors.inkFaint)),
          ],
        ),
      );
    }

    return _Card(
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.reference.collection('results').doc('final').snapshots(),
        builder: (context, resultSnap) {
          final results = resultSnap.data?.data();
          final top = (results?['top'] as List?) ?? const [];
          final participantCount =
              (results?['participantCount'] as num?)?.toInt() ?? 0;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: workItDb
                .collection('prizeClaims')
                .where('challengeId', isEqualTo: doc.id)
                .snapshots(),
            builder: (context, claimSnap) {
              final claims = {
                for (final c in claimSnap.data?.docs ?? const [])
                  c.data()['uid'] as String? ?? '': c,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: wiText(17, weight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '$participantCount finished',
                        style: wiText(12, color: WIColors.inkFaint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (top.isEmpty)
                    Text(
                      'No results yet.',
                      style: wiText(13, color: WIColors.inkFaint),
                    )
                  else
                    for (var i = 0; i < top.length; i++)
                      _ResultRow(
                        rank: i + 1,
                        entry: (top[i] as Map).cast<String, dynamic>(),
                        claim: claims[(top[i] as Map)['uid']],
                        isWide: isWide,
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.rank,
    required this.entry,
    required this.claim,
    required this.isWide,
  });

  final int rank;
  final Map<String, dynamic> entry;
  final QueryDocumentSnapshot<Map<String, dynamic>>? claim;
  final bool isWide;

  Future<void> _fulfil(BuildContext context) => claim!.reference.delete();

  @override
  Widget build(BuildContext context) {
    final name = entry['displayName'] as String? ?? '—';
    final score = (entry['score'] as num?)?.toInt() ?? 0;
    final prize = entry['prize'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WIColors.rule)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text('$rank', style: wiText(13, color: WIColors.inkFaint)),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: wiText(14, weight: FontWeight.w600)),
                Text(
                  '$score pts · $prize',
                  style: wiText(12, color: WIColors.inkFaint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (claim == null)
            Text('Not claimed', style: wiText(12, color: WIColors.inkFaint))
          else ...[
            Expanded(
              child: Text(
                '${claim!.data()['fullName'] ?? ''} · ${claim!.data()['email'] ?? ''}',
                style: wiText(12, color: WIColors.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _DeskButton(label: 'Fulfilled', onTap: () => _fulfil(context)),
          ],
        ],
      ),
    );
  }
}
