import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/masjid.dart';

class MasjidService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all masjids
  Future<List<Masjid>> fetchAllMasjids() async {
    try {
      final response = await _client
          .from('masjids')
          .select('*')
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      return data.map((row) => Masjid.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching masjids: $e');
      return [];
    }
  }

  // Search masjids by address or name
  Future<List<Masjid>> searchMasjids(String query) async {
    try {
      final response = await _client
          .from('masjids')
          .select('*')
          .or('name.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%')
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      return data.map((row) => Masjid.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error searching masjids: $e');
      return [];
    }
  }

  // Fetch nearby masjids within a radius (in kilometers)
  Future<List<Masjid>> fetchNearbyMasjids(double userLat, double userLng, {double radiusKm = 10}) async {
    try {
      // Simple bounding box query (not exact but works for most cases)
      // 1 degree of latitude ≈ 111 km
      // 1 degree of longitude ≈ 111 km * cos(latitude)
      final double latDelta = radiusKm / 111;
      final double lngDelta = radiusKm / (111 * (userLat * 3.141592653589793 / 180).cos());

      final minLat = userLat - latDelta;
      final maxLat = userLat + latDelta;
      final minLng = userLng - lngDelta;
      final maxLng = userLng + lngDelta;

      final response = await _client
          .from('masjids')
          .select('*')
          .gte('latitude', minLat)
          .lte('latitude', maxLat)
          .gte('longitude', minLng)
          .lte('longitude', maxLng)
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      final masjids = data.map((row) => Masjid.fromMap(row as Map<String, dynamic>)).toList();

      // Filter by exact distance and sort by distance
      masjids.sort((a, b) => a.distanceFrom(userLat, userLng).compareTo(b.distanceFrom(userLat, userLng)));

      return masjids.where((m) => m.distanceFrom(userLat, userLng) <= radiusKm).toList();
    } catch (e) {
      print('Error fetching nearby masjids: $e');
      return [];
    }
  }

  // Fetch masjid by ID
  Future<Masjid?> fetchMasjidById(String id) async {
    try {
      final response = await _client
          .from('masjids')
          .select('*')
          .eq('id', id)
          .single();

      return Masjid.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching masjid: $e');
      return null;
    }
  }

  // Add new masjid (admin only)
  Future<Masjid?> createMasjid(Masjid masjid) async {
    try {
      final response = await _client
          .from('masjids')
          .insert(masjid.toMap(includeId: false))
          .select()
          .single();

      return Masjid.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating masjid: $e');
      return null;
    }
  }

  // Update masjid (admin only)
  Future<bool> updateMasjid(Masjid masjid) async {
    try {
      await _client
          .from('masjids')
          .update(masjid.toMap(includeId: false))
          .eq('id', masjid.id);
      return true;
    } catch (e) {
      print('Error updating masjid: $e');
      return false;
    }
  }

  // Delete masjid (admin only)
  Future<bool> deleteMasjid(String id) async {
    try {
      await _client
          .from('masjids')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting masjid: $e');
      return false;
    }
  }
}
