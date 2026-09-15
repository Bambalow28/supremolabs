// THESIS: /plansync/desk is the back office of the same folder — the drawer
// the public page's trip folder gets filed into. Applications and requests
// arrive as sheets, not as SaaS cards, and a decision is a rubber stamp.
// OWN-WORLD: PlanSync's own stock and teal (PSColors), Crimson Text for the
// names a human wrote, Anonymous Pro for everything the system printed —
// same rules as /plansync, no new palette.
// FORM: a tab index down the left, one sheet per thing waiting on a person.
// Nothing animates: this is a tool someone opens daily, not a page they see
// once, so the public page's settle is deliberately absent here.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/site_shell.dart';
import '../ps_colors.dart';
import '../widgets/document.dart';
import 'desk_data.dart';
import 'plansync_desk_service.dart';

/// Sheets rest immediately here — see the FORM note above.
const _rest = AlwaysStoppedAnimation<double>(1);

enum _Section { applications, advisors, requests, inbox, profile }

extension on _Section {
  String get label => switch (this) {
    _Section.applications => 'Applications',
    _Section.advisors => 'Advisors',
    _Section.requests => 'Requests',
    _Section.inbox => 'Inbox',
    _Section.profile => 'Profile',
  };

  bool get isAdmin => index < _Section.inbox.index;
}

class PlanSyncDeskPage extends StatefulWidget {
  const PlanSyncDeskPage({super.key});

  @override
  State<PlanSyncDeskPage> createState() => _PlanSyncDeskPageState();
}

class _PlanSyncDeskPageState extends State<PlanSyncDeskPage> {
  /// Null until someone is signed in. Advisor role still opens with sample
  /// data (ponytail: not requested yet); owner role is real — see
  /// [DeskOwnerData].
  DeskRole? _role;
  DeskOwnerData? _ownerData;
  _Section _section = _Section.applications;

  void _enterAdvisor() => setState(() {
    _role = DeskRole.advisor;
    _section = _Section.inbox;
  });

  void _enterOwner(DeskOwnerData data) => setState(() {
    _role = DeskRole.owner;
    _ownerData = data;
    _section = _Section.applications;
  });

  void _signOut() {
    final data = _ownerData;
    setState(() {
      _role = null;
      _ownerData = null;
    });
    data?.dispose();
    if (data != null) planSyncAuth.signOut();
  }

  @override
  void dispose() {
    _ownerData?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final pad = wide ? 64.0 : 22.0;

    return SiteShell(
      ground: PSColors.ground,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1060),
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, wide ? 48 : 32, pad, 96),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _role == null
                    ? _Gate(
                        key: const ValueKey('gate'),
                        onEnterAdvisor: _enterAdvisor,
                        onEnterOwner: _enterOwner,
                      )
                    : _Desk(
                        key: ValueKey(_role),
                        role: _role!,
                        ownerData: _ownerData,
                        section: _section,
                        wide: wide,
                        onSection: (s) => setState(() => _section = s),
                        onSignOut: _signOut,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- the door

class _Gate extends StatefulWidget {
  final VoidCallback onEnterAdvisor;
  final ValueChanged<DeskOwnerData> onEnterOwner;
  const _Gate({
    super.key,
    required this.onEnterAdvisor,
    required this.onEnterOwner,
  });

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInOwner() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final isAdmin = await signInAndCheckAdmin(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!isAdmin) {
        await planSyncAuth.signOut();
        if (mounted) {
          setState(() => _error = 'This account is not a desk admin.');
        }
        return;
      }
      widget.onEnterOwner(DeskOwnerData());
    } on FirebaseAuthException {
      if (mounted) {
        setState(
          () => _error = 'Could not sign in. Check the email and password.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FolderTab(label: 'PLANSYNC / DESK'),
        const SizedBox(height: 40),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: PSDocument(
              entrance: _rest,
              punched: false,
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  psFieldLabel('Staff only'),
                  const SizedBox(height: 14),
                  Text('The desk', style: _serif(34)),
                  const SizedBox(height: 14),
                  Text(
                    'Where advisor applications get answered. Sign in with the '
                    'same account you use in the PlanSync app.',
                    style: _body(15, color: PSColors.inkSecondary),
                  ),
                  const SizedBox(height: 26),
                  const PSPerforation(),
                  const SizedBox(height: 22),
                  _GateField(label: 'Email', controller: _email),
                  const SizedBox(height: 14),
                  _GateField(
                    label: 'Password',
                    controller: _password,
                    obscure: true,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: _body(13, color: PSColors.warning)),
                  ],
                  const SizedBox(height: 20),
                  _DeskButton(
                    label: _busy ? 'Signing in…' : 'Sign in',
                    primary: true,
                    onTap: _busy ? null : _signInOwner,
                  ),
                  const SizedBox(height: 22),
                  const PSPerforation(),
                  const SizedBox(height: 22),
                  psFieldLabel('Advisor inbox — sample data, not wired yet'),
                  const SizedBox(height: 14),
                  _DeskButton(
                    label: 'Open as advisor',
                    onTap: widget.onEnterAdvisor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  const _GateField({
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        psFieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: _body(14, color: PSColors.ink),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: PSColors.stockLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: PSColors.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: PSColors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: PSColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------- the desk

class _Desk extends StatelessWidget {
  final DeskRole role;
  final DeskOwnerData? ownerData;
  final _Section section;
  final bool wide;
  final ValueChanged<_Section> onSection;
  final VoidCallback onSignOut;

  const _Desk({
    super.key,
    required this.role,
    required this.ownerData,
    required this.section,
    required this.wide,
    required this.onSection,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final data = ownerData;
    if (data == null) return _build(context);
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final sections = [
      for (final s in _Section.values)
        if (role == DeskRole.owner ? s.isAdmin : !s.isAdmin) s,
    ];
    final index = _Index(
      sections: sections,
      current: section,
      onSection: onSection,
      onSignOut: onSignOut,
      role: role,
      ownerData: ownerData,
      vertical: wide,
    );

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(section),
        child: switch (section) {
          _Section.applications => _Applications(data: ownerData!),
          _Section.advisors => _Advisors(data: ownerData!),
          _Section.requests => const _Pipeline(),
          _Section.inbox => const _Inbox(),
          _Section.profile => _Profile(wide: wide),
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FolderTab(label: 'PLANSYNC / DESK'),
        SizedBox(height: wide ? 36 : 24),
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 190, child: index),
                const SizedBox(width: 36),
                Expanded(child: body),
              ],
            ),
          )
        else ...[
          index,
          const SizedBox(height: 24),
          body,
        ],
      ],
    );
  }
}

/// The tab index down the binding edge of the drawer.
class _Index extends StatelessWidget {
  final List<_Section> sections;
  final _Section current;
  final ValueChanged<_Section> onSection;
  final VoidCallback onSignOut;
  final DeskRole role;
  final DeskOwnerData? ownerData;
  final bool vertical;

  const _Index({
    required this.sections,
    required this.current,
    required this.onSection,
    required this.onSignOut,
    required this.role,
    required this.ownerData,
    required this.vertical,
  });

  int _count(_Section s) => switch (s) {
    _Section.applications => ownerData?.applications.length ?? 0,
    _Section.advisors => ownerData?.advisors.length ?? 0,
    _Section.requests =>
      sampleRequests.where((r) => r.state == ReqState.waiting).length,
    _Section.inbox => requestsFor(
      sampleProfile.name,
    ).where((r) => r.state == ReqState.waiting).length,
    _Section.profile => 0,
  };

  @override
  Widget build(BuildContext context) {
    final tabs = [
      for (final s in sections)
        _IndexTab(
          label: s.label,
          count: _count(s),
          on: s == current,
          vertical: vertical,
          onTap: () => onSection(s),
        ),
    ];

    if (!vertical) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in tabs)
              Padding(padding: const EdgeInsets.only(right: 8), child: t),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        psFieldLabel(role == DeskRole.owner ? 'Studio' : 'Advisor'),
        const SizedBox(height: 14),
        ...tabs,
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: _DeskButton(label: 'Sign out', quiet: true, onTap: onSignOut),
        ),
      ],
    );
  }
}

class _IndexTab extends StatefulWidget {
  final String label;
  final int count;
  final bool on;
  final bool vertical;
  final VoidCallback onTap;

  const _IndexTab({
    required this.label,
    required this.count,
    required this.on,
    required this.vertical,
    required this.onTap,
  });

  @override
  State<_IndexTab> createState() => _IndexTabState();
}

class _IndexTabState extends State<_IndexTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.on || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: widget.on
                ? PSColors.stock
                : _hover
                ? PSColors.stockLow
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: active ? PSColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: widget.vertical ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Expanded(
                flex: widget.vertical ? 1 : 0,
                child: Text(
                  widget.label,
                  style: _body(
                    14,
                    color: active ? PSColors.ink : PSColors.inkSecondary,
                  ),
                ),
              ),
              if (widget.count > 0) ...[
                const SizedBox(width: 10),
                Text(
                  '${widget.count}',
                  style: _mono(12, color: PSColors.accent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------- admin sections

class _Applications extends StatelessWidget {
  final DeskOwnerData data;
  const _Applications({required this.data});

  @override
  Widget build(BuildContext context) {
    final applications = data.applications;
    if (applications.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Head(title: 'Applications', line: 'Nobody is waiting to hear back.'),
        ],
      );
    }
    final oldest = applications
        .map((a) => a.daysWaiting)
        .reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Head(
          title: 'Applications',
          line:
              '${applications.length} people are waiting to hear back. '
              'Oldest first.',
        ),
        const SizedBox(height: 22),
        _Numbers(
          items: [
            ('Waiting', '${applications.length}'),
            ('Days oldest', '$oldest'),
            ('Approved', '${data.advisors.length}'),
          ],
        ),
        const SizedBox(height: 22),
        for (final a in applications) ...[
          _ApplicationSheet(application: a),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _ApplicationSheet extends StatelessWidget {
  final Application application;
  const _ApplicationSheet({required this.application});

  @override
  Widget build(BuildContext context) {
    final a = application;
    return PSDocument(
      entrance: _rest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: _serif(24)),
                    const SizedBox(height: 4),
                    Text(
                      '${a.city} · ${a.kind}',
                      style: _body(13, color: PSColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                'WAITING ${a.daysWaiting}D',
                style: _mono(11, color: PSColors.accent, tracking: 1.8),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              PSField(
                label: 'Experience',
                value: '${a.years} years',
                valueSize: 15,
              ),
              PSField(
                label: 'Asking',
                value: '\$${a.rate} / plan',
                valueSize: 15,
              ),
              PSField(label: 'Languages', value: a.languages, valueSize: 15),
              PSField(
                label: 'Travels listed',
                value: '${a.travels}',
                valueSize: 15,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(left: 14),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: PSColors.hairline)),
            ),
            child: Text(
              '“${a.quote}”',
              style: _body(14, color: PSColors.inkSecondary),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DeskButton(
                label: 'Approve',
                primary: true,
                onTap: () => _notWired(context),
              ),
              _DeskButton(label: 'Decline', onTap: () => _notWired(context)),
              _DeskButton(
                label: 'Preview public profile →',
                quiet: true,
                onTap: () => _notWired(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Advisors extends StatelessWidget {
  final DeskOwnerData data;
  const _Advisors({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Head(
          title: 'Advisors',
          line: 'Everyone approved, and what each of them is carrying.',
        ),
        const SizedBox(height: 22),
        PSDocument(
          entrance: _rest,
          punched: false,
          padding: const EdgeInsets.all(28),
          child: _Table(
            columns: const [
              'Advisor',
              'Based',
              'Plans',
              'Rating',
              'Rate',
              'Waiting',
            ],
            rows: [
              for (final a in data.advisors)
                [
                  _Cell(a.name, serif: true),
                  _Cell(a.city),
                  _Cell('${a.plans}', mono: true),
                  _Cell(a.rating.toStringAsFixed(1), mono: true),
                  _Cell('\$${a.rate}', mono: true),
                  _Cell(
                    a.waiting == 0 ? '—' : '${a.waiting}',
                    mono: true,
                    accent: a.waiting > 0,
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Pipeline extends StatelessWidget {
  const _Pipeline();

  @override
  Widget build(BuildContext context) {
    final waiting = sampleRequests
        .where((r) => r.state == ReqState.waiting)
        .length;
    final stale = sampleRequests.where((r) => r.stale).length;
    final settled = sampleRequests
        .where((r) => r.state != ReqState.waiting)
        .toList();
    final accepted = settled.where((r) => r.state == ReqState.accepted).length;
    final rate = settled.isEmpty
        ? 0
        : (accepted * 100 / settled.length).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Head(
          title: 'Requests',
          line:
              '${sampleRequests.length} in the pipeline. '
              '$stale have been sitting unanswered for over a week.',
        ),
        const SizedBox(height: 22),
        _Numbers(
          items: [
            ('In pipeline', '${sampleRequests.length}'),
            ('Awaiting reply', '$waiting'),
            ('Stale · 7d+', '$stale'),
            ('Accepted', '$rate%'),
          ],
        ),
        const SizedBox(height: 22),
        PSDocument(
          entrance: _rest,
          punched: false,
          padding: const EdgeInsets.all(28),
          child: _Table(
            columns: const [
              'Traveller',
              'Destination',
              'Dates',
              'Budget',
              'Advisor',
              'State',
            ],
            rows: [
              for (final r in sampleRequests)
                [
                  _Cell(r.traveller, serif: true),
                  _Cell(r.destination),
                  _Cell(r.dates, mono: true),
                  _Cell('\$${r.budget}', mono: true),
                  _Cell(r.advisor),
                  _Cell(
                    _stateLabel(r),
                    mono: true,
                    accent: r.state == ReqState.waiting,
                    dim: r.state == ReqState.declined,
                  ),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Read-only. A stale row is a reason to nudge an advisor, not to answer '
          'for them.',
          style: _body(13, color: PSColors.inkMuted),
        ),
      ],
    );
  }

  static String _stateLabel(DeskRequest r) => switch (r.state) {
    ReqState.waiting =>
      r.stale ? 'STALE ${r.daysAgo}D' : 'WAITING ${r.daysAgo}D',
    ReqState.accepted => 'ACCEPTED',
    ReqState.declined => 'DECLINED',
  };
}

// ------------------------------------------------------- advisor sections

class _Inbox extends StatelessWidget {
  const _Inbox();

  @override
  Widget build(BuildContext context) {
    final mine = requestsFor(sampleProfile.name);
    final waiting = mine.where((r) => r.state == ReqState.waiting).toList();
    final settled = mine.where((r) => r.state != ReqState.waiting).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Head(
          title: 'Inbox',
          line: waiting.isEmpty
              ? 'Nothing waiting.'
              : '${waiting.length} travellers are waiting on you.',
        ),
        const SizedBox(height: 22),
        _Numbers(
          items: [
            ('Waiting', '${waiting.length}'),
            ('Plans made', '${sampleProfile.plans}'),
            ('Rating', sampleProfile.rating.toStringAsFixed(1)),
            ('Per plan', '\$${sampleProfile.rate}'),
          ],
        ),
        const SizedBox(height: 22),
        if (waiting.isEmpty) const _AllCaughtUp(),
        for (final r in waiting) ...[
          _RequestSheet(request: r),
          const SizedBox(height: 18),
        ],
        if (settled.isNotEmpty) ...[
          const SizedBox(height: 6),
          psFieldLabel('Answered'),
          const SizedBox(height: 12),
          for (final r in settled) ...[
            _SettledRow(request: r),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _RequestSheet extends StatelessWidget {
  final DeskRequest request;
  const _RequestSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    return PSDocument(
      entrance: _rest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.traveller, style: _serif(24)),
                    const SizedBox(height: 4),
                    Text(
                      r.destination,
                      style: _body(13, color: PSColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${r.daysAgo} DAYS AGO',
                style: _mono(
                  11,
                  color: r.stale ? PSColors.warning : PSColors.inkMuted,
                  tracking: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              PSField(label: 'Dates', value: r.dates, valueSize: 15),
              PSField(label: 'Nights', value: '${r.nights}', valueSize: 15),
              PSField(label: 'Party', value: '${r.party}', valueSize: 15),
              PSField(
                label: 'Budget',
                value: '\$${r.budget} USD',
                valueSize: 15,
              ),
            ],
          ),
          if (r.message.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(left: 14),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: PSColors.hairline)),
              ),
              child: Text(
                '“${r.message}”',
                style: _body(14, color: PSColors.inkSecondary),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DeskButton(
                label: 'Accept',
                primary: true,
                onTap: () => _notWired(context),
              ),
              _DeskButton(label: 'Decline', onTap: () => _notWired(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettledRow extends StatelessWidget {
  final DeskRequest request;
  const _SettledRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    final accepted = r.state == ReqState.accepted;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: PSColors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.traveller,
                  style: _serif(18, color: PSColors.inkSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${r.destination} · ${r.dates} · ${r.party} travellers',
                  style: _body(12.5, color: PSColors.inkMuted),
                ),
              ],
            ),
          ),
          PSStamp(
            label: accepted ? 'Accepted' : 'Declined',
            color: accepted ? PSColors.accentAlt : PSColors.inkMuted,
          ),
        ],
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        border: Border.all(color: PSColors.hairline),
        color: PSColors.stockLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All caught up', style: _serif(20)),
          const SizedBox(height: 8),
          Text(
            'Every request has an answer. Travellers find you through the '
            'advisor list in the app — the fuller your travels list, the more '
            'places you turn up in.',
            style: _body(14, color: PSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  final bool wide;
  const _Profile({required this.wide});

  @override
  Widget build(BuildContext context) {
    final p = sampleProfile;
    final editor = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Field(label: 'Headline', value: 'Lisbon, eaten properly.'),
        const SizedBox(height: 18),
        _Field(label: 'About', value: p.about, tall: true),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Field(label: 'Rate per plan', value: '\$${p.rate} USD'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Field(label: 'Years advising', value: '${p.years}'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        psFieldLabel('Languages'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final l in p.languages) _Chip(label: l),
            const _Chip(label: '+ Add', dim: true),
          ],
        ),
        const SizedBox(height: 26),
        psFieldLabel('Travels shown · ${p.shownPlaces} of ${p.places.length}'),
        const SizedBox(height: 6),
        for (final place in p.places) _PlaceRow(place: place),
      ],
    );

    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        psFieldLabel('As travellers see it'),
        const SizedBox(height: 12),
        PSDocument(
          entrance: _rest,
          punched: false,
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: _serif(26)),
              const SizedBox(height: 4),
              Text(
                '${p.city} · ${p.rating} · ${p.reviews} reviews',
                style: _body(13, color: PSColors.inkSecondary),
              ),
              const SizedBox(height: 18),
              Text(p.headline, style: _body(15, color: PSColors.ink)),
              const SizedBox(height: 10),
              Text(p.about, style: _body(14, color: PSColors.inkSecondary)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 28,
                runSpacing: 14,
                children: [
                  PSField(
                    label: 'Plans made',
                    value: '${p.plans}',
                    valueSize: 15,
                  ),
                  PSField(label: 'Rate', value: '\$${p.rate}', valueSize: 15),
                  PSField(
                    label: 'Languages',
                    value: 'PT · ES · EN',
                    valueSize: 15,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const PSPerforation(),
              const SizedBox(height: 20),
              PSField(
                label: 'Been there',
                value: [
                  for (final pl in p.places)
                    if (pl.shown) pl.label.split(',').first,
                ].join(' · '),
                valueSize: 14,
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: _DeskButton(
                  label: 'Request a plan',
                  primary: true,
                  onTap: null,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Head(
          title: 'Public profile',
          line:
              'Every field here is really a question about how your public '
              'card reads.',
        ),
        const SizedBox(height: 22),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: editor),
              const SizedBox(width: 32),
              Expanded(child: preview),
            ],
          )
        else ...[
          editor,
          const SizedBox(height: 32),
          preview,
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool tall;
  const _Field({required this.label, required this.value, this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        psFieldLabel(label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: tall ? 86 : 0),
          padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
          decoration: BoxDecoration(
            border: Border.all(color: PSColors.hairline),
            color: PSColors.stockLow,
          ),
          child: Text(value, style: _body(14, color: PSColors.ink)),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool dim;
  const _Chip({required this.label, this.dim = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: PSColors.hairline)),
      child: Text(
        label,
        style: _body(13, color: dim ? PSColors.inkMuted : PSColors.ink),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final DeskPlace place;
  const _PlaceRow({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PSColors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${place.label} · ${place.year}',
                  style: _body(14.5, color: PSColors.ink),
                ),
                const SizedBox(height: 3),
                Text(place.note, style: _body(12.5, color: PSColors.inkMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _Switch(on: place.shown),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool on;
  const _Switch({required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: on ? PSColors.accent : PSColors.hairline),
      ),
      child: Align(
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 12,
            height: 12,
            color: on ? PSColors.accent : PSColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- furniture

class _FolderTab extends StatelessWidget {
  final String label;
  const _FolderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
        decoration: BoxDecoration(
          color: PSColors.stock,
          border: Border.all(color: PSColors.hairline),
        ),
        child: Text(
          label,
          style: _mono(11, color: PSColors.accent, tracking: 2.4),
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  final String title;
  final String line;
  const _Head({required this.title, required this.line});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _serif(32)),
        const SizedBox(height: 8),
        Text(line, style: _body(14.5, color: PSColors.inkSecondary)),
      ],
    );
  }
}

/// The four numbers a section is judged by, set between two hairlines.
class _Numbers extends StatelessWidget {
  final List<(String, String)> items;
  const _Numbers({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: PSColors.hairline),
          bottom: BorderSide(color: PSColors.hairline),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          for (final (label, value) in items)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: _serif(26)),
                  const SizedBox(height: 5),
                  psFieldLabel(label),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell {
  final String text;
  final bool serif;
  final bool mono;
  final bool accent;
  final bool dim;
  const _Cell(
    this.text, {
    this.serif = false,
    this.mono = false,
    this.accent = false,
    this.dim = false,
  });

  TextStyle get style {
    final color = accent
        ? PSColors.accent
        : dim
        ? PSColors.inkMuted
        : serif
        ? PSColors.ink
        : PSColors.inkSecondary;
    if (serif) return _serif(17, color: color);
    if (mono) return _mono(13, color: color);
    return _body(13.5, color: color);
  }
}

/// A printed table — mono values, hairline rules, no zebra striping.
class _Table extends StatelessWidget {
  final List<String> columns;
  final List<List<_Cell>> rows;
  const _Table({required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 620),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          // Columns size to their content — a long destination shortens the
          // gap beside it instead of clipping itself.
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: PSColors.hairline)),
              ),
              children: [
                for (final c in columns)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 10),
                    child: psFieldLabel(c),
                  ),
              ],
            ),
            for (final row in rows)
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: PSColors.hairline)),
                ),
                children: [
                  for (final cell in row)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 13, 8, 13),
                      child: Text(
                        cell.text,
                        style: cell.style,
                        softWrap: false,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DeskButton extends StatefulWidget {
  final String label;
  final bool primary;
  final bool quiet;
  final VoidCallback? onTap;

  const _DeskButton({
    required this.label,
    this.primary = false,
    this.quiet = false,
    required this.onTap,
  });

  @override
  State<_DeskButton> createState() => _DeskButtonState();
}

class _DeskButtonState extends State<_DeskButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hoverable = widget.onTap != null && !widget.quiet;
    final lit = hoverable && _hover;
    final color = widget.primary
        ? PSColors.accent
        : widget.quiet
        ? PSColors.inkSecondary
        : PSColors.ink;
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: widget.quiet ? 2 : 16,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: lit
            ? (widget.primary ? PSColors.accent : PSColors.ink).withValues(
                alpha: 0.08,
              )
            : Colors.transparent,
        border: Border.all(
          color: widget.quiet
              ? Colors.transparent
              : widget.primary
              ? (lit ? PSColors.accentAlt : PSColors.accent)
              : (lit ? PSColors.ink : PSColors.hairline),
        ),
      ),
      child: Text(
        widget.label,
        style: _body(
          13,
          color: widget.primary && lit ? PSColors.accentAlt : color,
        ),
      ),
    );
    if (widget.onTap == null) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: hoverable ? (_) => setState(() => _hover = true) : null,
      onExit: hoverable ? (_) => setState(() => _hover = false) : null,
      child: GestureDetector(onTap: widget.onTap, child: child),
    );
  }
}

void _notWired(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: PSColors.stockHigh,
      behavior: SnackBarBehavior.floating,
      width: 420,
      content: Text(
        "Reading is live; approving and declining aren't wired yet.",
        style: _body(13.5, color: PSColors.ink),
      ),
    ),
  );
}

// PlanSync's own faces, from Google Fonts rather than re-bundling the app's
// asset copies: Crimson Text for what a person wrote, Anonymous Pro for what
// the system printed, Inter for everything else.
TextStyle _serif(double size, {Color? color}) => GoogleFonts.crimsonText(
  fontSize: size,
  fontWeight: FontWeight.bold,
  color: color ?? PSColors.ink,
  height: 1.05,
);

TextStyle _mono(double size, {Color? color, double tracking = 1.2}) =>
    GoogleFonts.anonymousPro(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color ?? PSColors.inkMuted,
      letterSpacing: tracking,
    );

TextStyle _body(double size, {Color? color}) => GoogleFonts.inter(
  fontSize: size,
  color: color ?? PSColors.ink,
  fontWeight: FontWeight.w500,
  height: 1.5,
);
