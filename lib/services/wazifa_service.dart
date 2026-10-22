import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wazifa.dart';

class WazifaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Wazifa>> getAllWazifas() async {
    try {
      final response = await _supabase
          .from('wazifas')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List).map((map) => Wazifa.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wazifas: $e');
    }
  }

  Future<List<Wazifa>> getWazifasByCategory(String category) async {
    try {
      final response = await _supabase
          .from('wazifas')
          .select('*')
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((map) => Wazifa.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wazifas by category: $e');
    }
  }

  Future<Wazifa?> getWazifaById(String id) async {
    try {
      final response = await _supabase
          .from('wazifas')
          .select('*')
          .eq('id', id)
          .single();

      return Wazifa.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch wazifa: $e');
    }
  }

  Future<Wazifa> createWazifa(Wazifa wazifa) async {
    try {
      final response = await _supabase
          .from('wazifas')
          .insert(wazifa.toMap()..remove('id'))
          .select()
          .single();

      return Wazifa.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create wazifa: $e');
    }
  }

  Future<Wazifa> updateWazifa(Wazifa wazifa) async {
    try {
      final response = await _supabase
          .from('wazifas')
          .update(wazifa.toMap()..remove('created_at'))
          .eq('id', wazifa.id)
          .select()
          .single();

      return Wazifa.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update wazifa: $e');
    }
  }

  Future<void> deleteWazifa(String id) async {
    try {
      await _supabase.from('wazifas').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete wazifa: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('wazifas')
          .select('category');

      final categories = (response as List)
          .map((map) => map['category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
