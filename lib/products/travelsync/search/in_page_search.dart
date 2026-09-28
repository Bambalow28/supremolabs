// Live place/people search, ported from travelsync_website's header search
// (LiveSearchField + PlaceSearchBar) — same Supabase query, same debounce,
// same dropdown. Placed in the page body per DESIGN.md rather than the nav,
// since this page scrolls under a transparent header rather than a fixed
// one. A result opens the real page on travelsync.ca — trip/user/place
// pages stay on travelsync_website, not duplicated here.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ts_colors.dart';
import 'search_models.dart';
import 'search_service.dart';

class InPageSearch extends StatefulWidget {
  const InPageSearch({super.key});

  @override
  State<InPageSearch> createState() => _InPageSearchState();
}

class _InPageSearchState extends State<InPageSearch> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  Timer? _debounce;
  int _reqId = 0;
  bool _loading = false;
  String _query = '';
  List<TripOwner> _people = const [];
  List<PlaceResult> _places = const [];

  static const _limit = 5;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _query = value.trim();
    _debounce?.cancel();

    if (_query.isEmpty) {
      setState(() {
        _people = const [];
        _places = const [];
        _loading = false;
      });
      _portal.hide();
      return;
    }

    setState(() => _loading = true);
    if (!_portal.isShowing) _portal.show();
    _debounce = Timer(const Duration(milliseconds: 250), _runQuery);
  }

  Future<void> _runQuery() async {
    final q = _query;
    if (q.isEmpty) return;
    final reqId = ++_reqId;
    final service = TravelSyncSearchService.instance;

    try {
      final results = await Future.wait([
        service.searchProfiles(q),
        service.searchPlaces(q),
      ]);
      if (reqId != _reqId || !mounted) return;
      setState(() {
        _people = (results[0] as List<TripOwner>).take(_limit).toList();
        _places = (results[1] as List<PlaceResult>).take(_limit).toList();
        _loading = false;
      });
    } catch (_) {
      if (reqId != _reqId || !mounted) return;
      setState(() {
        _people = const [];
        _places = const [];
        _loading = false;
      });
    }
  }

  void _hide() => _portal.hide();

  void _openPerson(TripOwner owner) {
    _hide();
    launchUrl(Uri.parse('https://travelsync.ca/user/${owner.handle}'));
  }

  void _openPlace(PlaceResult place) {
    _hide();
    launchUrl(
      Uri.parse(
        'https://travelsync.ca/place/${Uri.encodeComponent(place.city)}'
        '?c=${Uri.encodeComponent(place.country)}',
      ),
    );
  }

  void _clear() {
    _hide();
    _controller.clear();
    _query = '';
    setState(() {
      _people = const [];
      _places = const [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        final width = (_link.leaderSize?.width ?? 320).clamp(300.0, 560.0);
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hide,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 10),
              child: SizedBox(width: width, child: _dropdown()),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: _SearchBar(
          controller: _controller,
          focusNode: _focus,
          busy: _loading,
          showClear: _controller.text.isNotEmpty,
          onChanged: _onChanged,
          onClear: _clear,
        ),
      ),
    );
  }

  Widget _dropdown() {
    final hasResults = _people.isNotEmpty || _places.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF141C30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: (_loading && !hasResults)
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: primaryBlue,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : !hasResults
            ? _NoMatches(query: _query)
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_people.isNotEmpty) ...[
                      const _DropdownLabel('PEOPLE'),
                      for (final p in _people)
                        _PersonRow(owner: p, onTap: () => _openPerson(p)),
                    ],
                    if (_places.isNotEmpty) ...[
                      const _DropdownLabel('PLACES'),
                      for (final pl in _places)
                        _PlaceRow(place: pl, onTap: () => _openPlace(pl)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final bool showClear;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.busy,
    required this.showClear,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: elevatedSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                cursorColor: primaryBlue,
                style: GoogleFonts.anonymousPro(
                  fontSize: 15,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: InputBorder.none,
                  hintText: 'Search user or place',
                  hintStyle: GoogleFonts.anonymousPro(
                    fontSize: 15,
                    color: Colors.white38,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            if (busy)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: primaryBlue,
                  strokeWidth: 2,
                ),
              )
            else if (showClear)
              InkWell(
                onTap: onClear,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  final String text;
  const _DropdownLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text,
        style: GoogleFonts.anonymousPro(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white38,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final TripOwner owner;
  final VoidCallback onTap;
  const _PersonRow({required this.owner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = owner.avatarUrl;
    final hasPhoto = url != null && url.isNotEmpty;
    return _HoverRow(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, _, _) => _initials(owner),
                    )
                  : _initials(owner),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              owner.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const Icon(
            Icons.person_outline_rounded,
            size: 16,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _initials(TripOwner owner) {
    return Container(
      color: owner.avatarColor.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: Text(
        owner.initials,
        style: GoogleFonts.anonymousPro(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final PlaceResult place;
  final VoidCallback onTap;
  const _PlaceRow({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HoverRow(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBlue.withValues(alpha: 0.12),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 17,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${place.tripCount} ${place.tripCount == 1 ? "trip" : "trips"}',
                  style: GoogleFonts.anonymousPro(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.north_east_rounded, size: 15, color: Colors.white24),
        ],
      ),
    );
  }
}

class _HoverRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverRow({required this.child, required this.onTap});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _hovered ? Colors.white.withValues(alpha: 0.06) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: widget.child,
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  final String query;
  const _NoMatches({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        'No matches for “$query”',
        style: GoogleFonts.anonymousPro(fontSize: 13, color: Colors.white54),
      ),
    );
  }
}
