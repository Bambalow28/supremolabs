/// EXIF-derived metadata for a single trip photo, index-aligned with
/// [TravelCard.photoUrls]. Any field may be null when the source photo didn't
/// carry it (screenshots have no GPS, downloads no date).
class PhotoMeta {
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final String? place; // reverse-geocoded, e.g. "Shibuya, Japan"

  const PhotoMeta({this.takenAt, this.latitude, this.longitude, this.place});

  bool get isEmpty =>
      takenAt == null && latitude == null && longitude == null && place == null;

  factory PhotoMeta.fromJson(Map<String, dynamic> json) => PhotoMeta(
    takenAt: json['taken_at'] != null
        ? DateTime.tryParse(json['taken_at'] as String)
        : null,
    latitude: (json['lat'] as num?)?.toDouble(),
    longitude: (json['lng'] as num?)?.toDouble(),
    place: json['place'] as String?,
  );
}

class TravelCard {
  final String id;
  final String city;
  final String country;
  final String year;
  final String dateRange;
  final int nights;
  final List<String> citiesVisited;
  final String personalNote;
  final int cardNumber;
  final String originAirport;
  final String destinationAirport;
  final String? cardImageUrl;
  final String theme;
  final List<String> photoUrls;
  final List<PhotoMeta> photoMeta;
  final String userId;

  const TravelCard({
    required this.id,
    required this.city,
    required this.country,
    required this.year,
    required this.dateRange,
    required this.nights,
    required this.citiesVisited,
    required this.personalNote,
    required this.cardNumber,
    this.originAirport = '',
    this.destinationAirport = '',
    this.cardImageUrl,
    required this.theme,
    required this.photoUrls,
    this.photoMeta = const [],
    required this.userId,
  });

  factory TravelCard.fromJson(Map<String, dynamic> json) {
    return TravelCard(
      id: json['id'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      year: json['year'] as String,
      dateRange: json['date_range'] as String? ?? '',
      nights: json['nights'] as int? ?? 0,
      citiesVisited: List<String>.from(json['cities_visited'] ?? []),
      personalNote: json['personal_note'] as String? ?? '',
      cardNumber: json['card_number'] as int? ?? 0,
      originAirport: json['origin_airport'] as String? ?? '',
      destinationAirport: json['destination_airport'] as String? ?? '',
      cardImageUrl: json['card_image_url'] as String?,
      theme: json['theme'] as String? ?? 'night',
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      photoMeta: ((json['photo_meta'] as List?) ?? [])
          .map(
            (e) => e == null
                ? const PhotoMeta()
                : PhotoMeta.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      userId: json['user_id'] as String,
    );
  }

  /// The trip's primary city — used as the page/card title. The full list of
  /// places lives in [citiesVisited] and is shown separately.
  String get displayTitle => city;

  String get daysLabel => '$nights days';
}
