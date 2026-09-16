import 'package:flutter/material.dart' show Color;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'search_models.dart';

/// Read-only ports of travelsync_website's `TripService.searchPlaceNames`
/// and `ProfileService.searchProfiles` — the two queries the live header
/// search runs. Everything past a tap (the trip/user/place pages) stays on
/// travelsync_website; this only needs to find and label results.
class TravelSyncSearchService {
  TravelSyncSearchService._();
  static final instance = TravelSyncSearchService._();

  final _client = Supabase.instance.client;

  static const _avatarPalette = [
    Color(0xFF4B76FA),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFF2AB8D0),
    Color(0xFFE8614A),
  ];

  Future<List<PlaceResult>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final response = await _client
        .from('travel_cards')
        .select('city, country')
        .eq('is_public', true)
        .or('city.ilike.%$q%,country.ilike.%$q%')
        .limit(300);

    final byPlace = <String, PlaceResult>{};
    for (final row in (response as List)) {
      final city = (row['city'] as String?)?.trim() ?? '';
      final country = (row['country'] as String?)?.trim() ?? '';
      if (city.isEmpty) continue;
      final key = '${city.toLowerCase()}|${country.toLowerCase()}';
      final existing = byPlace[key];
      byPlace[key] = PlaceResult(
        city: city,
        country: country,
        tripCount: (existing?.tripCount ?? 0) + 1,
      );
    }

    final list = byPlace.values.toList()
      ..sort((a, b) => b.tripCount.compareTo(a.tripCount));
    return list;
  }

  Future<List<TripOwner>> searchProfiles(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    try {
      final rows = await _client
          .from('profiles')
          .select('id, username, avatar_url')
          .ilike('username', '%$q%')
          .limit(20);
      return (rows as List).map((r) {
        final username = ((r['username'] as String?)?.trim() ?? '').isEmpty
            ? '@traveler'
            : (r['username'] as String).trim();
        final userId = r['id'] as String;
        final handle = username.replaceFirst('@', '');
        return TripOwner(
          userId: userId,
          username: username,
          initials: handle.isEmpty
              ? '?'
              : handle.substring(0, handle.length >= 2 ? 2 : 1).toUpperCase(),
          avatarColor:
              _avatarPalette[userId.hashCode.abs() % _avatarPalette.length],
          avatarUrl: (r['avatar_url'] as String?)?.trim(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
