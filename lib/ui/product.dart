class Product {
  final String name;
  final String category;
  final String tagline;

  const Product({required this.name, required this.category, required this.tagline});
}

/// Placeholder lineup + copy — see PRODUCT.md "Evidence on Hand". Replace
/// taglines and wire real hrefs (site / App Store) as each product ships here.
const products = <Product>[
  Product(name: 'TravelSync', category: 'Travel', tagline: 'Trip planning, done right.'),
  Product(name: 'WealthSync', category: 'Finance', tagline: 'Personal finance, without the spreadsheet.'),
  Product(name: 'PlanSync', category: 'Planning', tagline: 'Plans that actually happen.'),
  Product(name: 'NoteSync', category: 'Notes', tagline: 'Notes that stay yours.'),
  Product(name: 'Juwa Wealth', category: 'Finance', tagline: 'One ledger. Two lives, kept separate.'),
  Product(name: 'HoopSync', category: 'Sports', tagline: 'Built for the game.'),
  Product(name: 'Jarvis', category: 'Productivity', tagline: 'Your day, handled.'),
  Product(name: 'DressMeUp', category: 'Lifestyle', tagline: 'Your closet, organized.'),
  Product(name: 'Diamo', category: 'Family', tagline: 'Every first, kept.'),
];
