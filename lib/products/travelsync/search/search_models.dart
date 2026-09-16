import 'package:flutter/material.dart';

/// A distinct destination (city + country) aggregated from public trips.
/// Mirrors travelsync_website's `PlaceResult`.
class PlaceResult {
  final String city;
  final String country;
  final int tripCount;

  const PlaceResult({
    required this.city,
    required this.country,
    required this.tripCount,
  });

  String get label => country.isNotEmpty ? '$city, $country' : city;
}

/// A public trip's owner. Mirrors travelsync_website's `TripOwner`.
class TripOwner {
  final String userId;
  final String username;
  final String initials;
  final Color avatarColor;
  final String? avatarUrl;

  const TripOwner({
    required this.userId,
    required this.username,
    required this.initials,
    required this.avatarColor,
    this.avatarUrl,
  });

  /// Username without the leading "@", for use in profile URLs.
  String get handle =>
      username.startsWith('@') ? username.substring(1) : username;
}
