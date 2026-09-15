/// What the desk shows. One file, so wiring it to Firestore later is one
/// file's worth of work.
///
/// Applications and the advisor roster are live, via [DeskOwnerData] —
/// `advisors` where status == pending / approved on PlanSync's own Firestore.
///
/// ponytail: the request pipeline, advisor inbox, and profile editor are
/// still `sample*` data below. Wire them the same way once the desk needs to
/// do more than show who's applied.
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'plansync_desk_service.dart';

/// Which set of sections the signed-in person gets.
enum DeskRole {
  /// Studio staff: applications, advisor roster, the whole request pipeline.
  owner,

  /// An approved advisor: their own inbox and public page.
  advisor,
}

enum ReqState { waiting, accepted, declined }

/// Someone asking to join the advisor list — `advisors/{uid}` with
/// `status: 'pending'`.
class Application {
  final String name;
  final String city;
  final String kind;
  final int years;
  final int rate;
  final String languages;
  final int travels;
  final String quote;
  final int daysWaiting;

  const Application({
    required this.name,
    required this.city,
    required this.kind,
    required this.years,
    required this.rate,
    required this.languages,
    required this.travels,
    required this.quote,
    required this.daysWaiting,
  });

  /// From `advisors/{uid}` — same shape the app's `ApplyScreen` writes.
  factory Application.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final allAround = d['allAround'] as bool? ?? false;
    final city = (d['city'] as Map?)?.cast<String, dynamic>();
    final submittedAt = (d['submittedAt'] as Timestamp?)?.toDate();
    final languages = (d['languages'] as List?)?.cast<String>() ?? const [];
    return Application(
      name: (d['name'] ?? '') as String,
      city: allAround
          ? 'All-around'
          : [
              city?['city'],
              city?['country'],
            ].whereType<String>().where((s) => s.isNotEmpty).join(', '),
      kind: allAround ? 'Generalist' : 'City specialist',
      years: (d['yearsExperience'] as num?)?.toInt() ?? 0,
      rate: (d['pricePerPlan'] as num?)?.toInt() ?? 0,
      languages: languages.isEmpty ? '—' : languages.join(' · '),
      travels: 0,
      quote: (d['bio'] ?? '') as String,
      daysWaiting: submittedAt == null
          ? 0
          : DateTime.now().difference(submittedAt).inDays,
    );
  }
}

/// A traveller's plan request — one `requests` document.
class DeskRequest {
  final String traveller;
  final String destination;
  final String dates;
  final int nights;
  final int party;
  final int budget;
  final String advisor;
  final ReqState state;
  final int daysAgo;
  final String message;

  const DeskRequest({
    required this.traveller,
    required this.destination,
    required this.dates,
    required this.nights,
    required this.party,
    required this.budget,
    required this.advisor,
    required this.state,
    required this.daysAgo,
    this.message = '',
  });

  /// Unanswered for over a week — the only row on the pipeline that is
  /// actually a problem.
  bool get stale => state == ReqState.waiting && daysAgo >= 7;
}

/// A row on the approved roster.
class AdvisorRow {
  final String name;
  final String city;
  final int plans;
  final double rating;
  final int rate;
  final int waiting;

  const AdvisorRow({
    required this.name,
    required this.city,
    required this.plans,
    required this.rating,
    required this.rate,
    required this.waiting,
  });

  /// From `advisors/{uid}` where `status == 'approved'`.
  factory AdvisorRow.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final allAround = d['allAround'] as bool? ?? false;
    final city = (d['city'] as Map?)?.cast<String, dynamic>();
    return AdvisorRow(
      name: (d['name'] ?? '') as String,
      city: allAround
          ? 'All-around'
          : [
              city?['city'],
              city?['country'],
            ].whereType<String>().where((s) => s.isNotEmpty).join(', '),
      plans: (d['tripsPlanned'] as num?)?.toInt() ?? 0,
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      rate: (d['pricePerPlan'] as num?)?.toInt() ?? 0,
      waiting: 0,
    );
  }
}

/// A place on an advisor's own travel list — `advisors/{uid}/places`.
class DeskPlace {
  final String label;
  final int year;
  final String note;
  final bool shown;

  const DeskPlace({
    required this.label,
    required this.year,
    required this.note,
    required this.shown,
  });
}

/// The signed-in advisor's public page, as they edit it.
class AdvisorProfile {
  final String name;
  final String city;
  final String headline;
  final String about;
  final int rate;
  final int years;
  final List<String> languages;
  final double rating;
  final int reviews;
  final int plans;
  final List<DeskPlace> places;

  const AdvisorProfile({
    required this.name,
    required this.city,
    required this.headline,
    required this.about,
    required this.rate,
    required this.years,
    required this.languages,
    required this.rating,
    required this.reviews,
    required this.plans,
    required this.places,
  });

  int get shownPlaces => places.where((p) => p.shown).length;
}

/// Live applications + roster for the signed-in admin, streamed from
/// PlanSync's Firestore. Owns its subscriptions — [dispose] on sign-out.
class DeskOwnerData extends ChangeNotifier {
  List<Application> applications = [];
  List<AdvisorRow> advisors = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _advisorsSub;

  DeskOwnerData() {
    _appsSub = planSyncDb
        .collection('advisors')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
          applications = snap.docs.map(Application.fromDoc).toList()
            ..sort((a, b) => b.daysWaiting.compareTo(a.daysWaiting));
          notifyListeners();
        });
    _advisorsSub = planSyncDb
        .collection('advisors')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snap) {
          advisors = snap.docs.map(AdvisorRow.fromDoc).toList();
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _appsSub?.cancel();
    _advisorsSub?.cancel();
    super.dispose();
  }
}

const sampleRequests = <DeskRequest>[
  DeskRequest(
    traveller: 'R. Whitfield',
    destination: 'Lisbon, PT',
    dates: 'Sep 12–19',
    nights: 7,
    party: 2,
    budget: 3400,
    advisor: 'Marisol Vega',
    state: ReqState.waiting,
    daysAgo: 11,
    message:
        "Anniversary trip. We'd rather eat well than see everything — one "
        'museum, maximum. Staying in Príncipe Real.',
  ),
  DeskRequest(
    traveller: 'K. Nakamura',
    destination: 'Kyoto, JP',
    dates: 'Oct 03–11',
    nights: 8,
    party: 4,
    budget: 7900,
    advisor: 'Ito Kenji',
    state: ReqState.waiting,
    daysAgo: 8,
    message:
        'Two adults, two kids. Temples in the morning, nothing scheduled '
        'after four.',
  ),
  DeskRequest(
    traveller: 'P. Almeida',
    destination: 'Porto, PT',
    dates: 'Oct 05–08',
    nights: 3,
    party: 5,
    budget: 2000,
    advisor: 'Marisol Vega',
    state: ReqState.waiting,
    daysAgo: 3,
    message:
        'Five of us, one car, no fixed plan past the Friday dinner. Wine '
        "country day trip if it's worth it.",
  ),
  DeskRequest(
    traveller: 'A. Bello',
    destination: 'Accra, GH',
    dates: 'Nov 21–28',
    nights: 7,
    party: 1,
    budget: 2100,
    advisor: 'Daniel Osei',
    state: ReqState.waiting,
    daysAgo: 2,
  ),
  DeskRequest(
    traveller: 'M. Duval',
    destination: 'Mexico City, MX',
    dates: 'Sep 02–07',
    nights: 5,
    party: 2,
    budget: 1850,
    advisor: 'Ana Ruiz',
    state: ReqState.accepted,
    daysAgo: 14,
  ),
  DeskRequest(
    traveller: 'S. Okonjo',
    destination: 'Rome, IT',
    dates: 'Aug 28–Sep 4',
    nights: 7,
    party: 3,
    budget: 5200,
    advisor: 'Giulia Ferri',
    state: ReqState.accepted,
    daysAgo: 19,
  ),
  DeskRequest(
    traveller: 'J. Hartley',
    destination: 'Reykjavík, IS',
    dates: 'Dec 14–20',
    nights: 6,
    party: 2,
    budget: 6000,
    advisor: 'Marisol Vega',
    state: ReqState.declined,
    daysAgo: 21,
  ),
];

const sampleProfile = AdvisorProfile(
  name: 'Marisol Vega',
  city: 'Lisbon, Portugal',
  headline: 'Lisbon, eaten properly.',
  about:
      'Seven years running small-group food walks in Alfama and Príncipe '
      'Real. I plan around meals and let the sightseeing fall where it fits.',
  rate: 180,
  years: 7,
  languages: ['Portuguese', 'Spanish', 'English'],
  rating: 4.9,
  reviews: 27,
  plans: 31,
  places: [
    DeskPlace(
      label: 'Lisbon, Portugal',
      year: 2026,
      note: 'Home. Ask me anything.',
      shown: true,
    ),
    DeskPlace(
      label: 'Porto, Portugal',
      year: 2025,
      note: 'Three days is enough, four is better.',
      shown: true,
    ),
    DeskPlace(
      label: 'Sintra, Portugal',
      year: 2025,
      note: 'Go on a weekday or not at all.',
      shown: true,
    ),
    DeskPlace(
      label: 'Sevilla, Spain',
      year: 2024,
      note: 'Spring only. Summer is a mistake.',
      shown: true,
    ),
    DeskPlace(
      label: 'Marrakech, Morocco',
      year: 2021,
      note: 'One long weekend, years ago.',
      shown: false,
    ),
  ],
);

/// Requests the signed-in advisor is waiting on, in the sample data.
List<DeskRequest> requestsFor(String advisor) => [
  for (final r in sampleRequests)
    if (r.advisor == advisor) r,
];
