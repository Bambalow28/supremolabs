import 'package:flutter/material.dart';

/// The domains the studio builds in. One product belongs to exactly one.
///
/// This is the site's only taxonomy, and it does double duty: it decides which
/// nodes are tied together in the hub's web, and it groups the lineup below
/// it. Eleven names in a flat list is inventory; five domains is a studio.
enum Cluster {
  journeys('Journeys', 'Getting somewhere, and everything before it.'),
  money('Money', 'Where it goes, and what is left.'),
  everyday('Everyday', 'The small things that run a day.'),
  body('Body', 'Training, and the numbers behind it.'),
  people('People', 'The ones you keep up with.');

  final String label;
  final String note;
  const Cluster(this.label, this.note);
}

/// The liner notes on a product's page: the problem it answers, and what it is
/// to the person who built it. Worded from the founder's own account — nothing
/// here is a metric or a testimonial.
class Story {
  final String problem;

  /// The founder's line about the app.
  final String mine;

  /// Heading over [mine]: "In my day" only where the founder uses it daily.
  final String mineLabel;
  const Story({
    required this.problem,
    required this.mine,
    this.mineLabel = 'In my day',
  });
}

class Product {
  final String name;
  final String category;
  final String tagline;

  /// Which domain this product sits in — its neighbours in the web, and its
  /// group in the lineup.
  final Cluster cluster;

  /// Path under supremolabs.com, e.g. `/travelsync`. Null until the product
  /// has a page here — those render as an unlit node, not a link.
  final String? route;

  /// The product's own ground color, painted behind its page body so
  /// overscroll matches. Null when [route] is null.
  final Color? ground;

  /// The product's own accent — its color in the web, in the lineup, and in
  /// the chrome while you are on its route. Null falls back to muted ink.
  final Color? accent;

  /// A real app screen for the release's sleeve. Null sets the sleeve
  /// typographically — never a stand-in screenshot.
  final String? screen;

  /// Null for products without a page.
  final Story? story;

  const Product({
    required this.name,
    required this.category,
    required this.tagline,
    required this.cluster,
    this.route,
    this.ground,
    this.accent,
    this.screen,
    this.story,
  });

  bool get live => route != null;
}

/// Taglines and hrefs per PRODUCT.md "Evidence on Hand". Products without a
/// [route] have no page here yet.
const products = <Product>[
  Product(
    name: 'WorkIt',
    category: 'Fitness',
    tagline: 'Every set, measured.',
    cluster: Cluster.body,
    route: '/workit',
    ground: Color(0xFF0B0C0E),
    accent: Color(0xFF4A9DFF), // WorkItColors.dark().tint
    screen: 'assets/workit/today.png',
    story: Story(
      problem: "Health tracking gets split across a dozen single-purpose apps.",
      mine:
          "It became my health hub — everything about my health tracking, in one place.",
      mineLabel: 'In my day',
    ),
  ),
  Product(
    name: 'TravelSync',
    category: 'Travel',
    tagline: 'Trip planning, done right.',
    cluster: Cluster.journeys,
    route: '/travelsync',
    ground: Color(0xFF0B0F1A),
    accent: Color(0xFF4B76FA), // ts_colors.dart primaryBlue
    screen: 'assets/travelsync/home.png',
    story: Story(
      problem: "Trip photos and memories get buried in a camera roll.",
      mine: "It keeps my memories from travel, as travel cards.",
      mineLabel: 'In my day',
    ),
  ),
  Product(
    name: 'PlanSync',
    category: 'Planning',
    tagline: 'Plans that actually happen.',
    cluster: Cluster.journeys,
    route: '/plansync',
    ground: Color(0xFF0A0E14),
    accent: Color(0xFF2DD4BF), // ps_colors.dart accent
    story: Story(
      problem:
          "Trip plans end up scattered across emails, screenshots and notes.",
      mine: "It simplified how I put a travel itinerary together.",
      mineLabel: 'In my day',
    ),
  ),
  Product(
    name: 'WealthSync',
    category: 'Finance',
    tagline: 'Personal finance, without the spreadsheet.',
    cluster: Cluster.money,
    route: '/wealthsync',
    ground: Color(0xFF1D1D1D),
    accent: Color(0xFF465C88), // ws_colors.dart toolColor
    screen: 'assets/wealthsync/main_page.png',
    story: Story(
      problem: "Money sits across accounts, apps and spreadsheets.",
      mine:
          "The goal is all-in-one finance management. It is still taking shape.",
      mineLabel: 'Where it is headed',
    ),
  ),
  Product(
    name: 'NoteSync',
    category: 'Notes',
    tagline: 'Notes that stay yours.',
    cluster: Cluster.everyday,
    route: '/notesync',
    ground: Color(0xFF000000),
    accent: Color(0xFF0A84FF), // ns_colors.dart accent
    story: Story(
      problem:
          "Notes, habits, reminders and events usually live in separate apps.",
      mine:
          "My own flavour of note-taking — with habits, reminders and events alongside.",
      mineLabel: 'In my day',
    ),
  ),
  Product(
    name: 'Diamo',
    category: 'Family',
    tagline: 'Every first, kept.',
    cluster: Cluster.people,
    route: '/diamo',
    ground: Color(0xFF1C1216),
    accent: Color(0xFF7A3145), // app_theme.dart diaMoTheme seed color
    story: Story(
      problem:
          "Early motherhood is scattered across group chats, photos and notes.",
      mine: "A hub for mothers.",
      mineLabel: 'What it is for',
    ),
  ),
  Product(
    name: 'Stanverse',
    category: 'Community',
    tagline: 'Your fandom, live.',
    cluster: Cluster.people,
    route: '/stanverse',
    ground: Color(0xFF0E0D10),
    accent: Color(0xFFF5F2EC), // stanverse_theme.dart StanTicker.paper
    story: Story(
      problem:
          "Following an artist means chasing news, dates and merch across a dozen places.",
      mine: "A place for following everything about an artist.",
      mineLabel: 'What it is for',
    ),
  ),
  Product(
    name: 'FamFi',
    category: 'Finance',
    tagline: 'One wallet for the two of us.',
    cluster: Cluster.money,
    route: '/famfi',
    ground: Color(0xFF0C0E12), // juwa_wealth JuwaColors.dark().bg
    accent: Color(0xFF2E5BE8), // juwa_wealth swatch 'cobalt'
    story: Story(
      problem:
          "Two people, shared bills, and no single view of the household's money.",
      mine: "Household finance management — one wallet for the two of us.",
      mineLabel: 'In my day',
    ),
  ),
  Product(
    name: 'HoopSync',
    category: 'Sports',
    tagline: 'Built for the game.',
    cluster: Cluster.body,
  ),
  Product(
    name: 'Jarvis',
    category: 'Productivity',
    tagline: 'Your day, handled.',
    cluster: Cluster.everyday,
  ),
  Product(
    name: 'DressMeUp',
    category: 'Lifestyle',
    tagline: 'Your closet, organized.',
    cluster: Cluster.everyday,
  ),
];

/// Products with a page here — the lit nodes in the web.
List<Product> get liveProducts => products.where((p) => p.live).toList();

/// The products in one domain, in lineup order.
List<Product> productsIn(Cluster c) =>
    products.where((p) => p.cluster == c).toList();

Product? productForRoute(String route) {
  for (final p in products) {
    if (p.route == route) return p;
  }
  return null;
}

/// The product a route belongs to, including sub-routes like
/// `/plansync/desk` — used by the nav breadcrumb to name where you are.
Product? productForPath(String? path) {
  if (path == null) return null;
  for (final p in products) {
    final route = p.route;
    if (route == null) continue;
    if (path == route || path.startsWith('$route/')) return p;
  }
  return null;
}
