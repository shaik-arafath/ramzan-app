import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';

class AddressService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Address>> fetchAddresses() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('addresses')
          .select('*')
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((row) => Address.fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  Future<Address?> addAddress(Address address) async {
    try {
      print('Inserting address data: ${address.toMap(includeId: false)}');
      final response = await _client
          .from('addresses')
          .insert(address.toMap(includeId: false))
          .select()
          .single();

      print('Address inserted successfully: $response');
      return Address.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error adding address: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  Future<bool> updateAddress(Address address) async {
    try {
      await _client
          .from('addresses')
          .update(address.toMap(includeId: true))
          .eq('id', address.id);
      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await _client.from('addresses').delete().eq('id', addressId);
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Unset all default addresses for this user
      await _client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Set the new default
      await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId);

      return true;
    } catch (e) {
      print('Error setting default address: $e');
      return false;
    }
  }

  Future<Address?> getDefaultAddress() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _client
          .from('addresses')
          .select('*')
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return Address.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching default address: $e');
      return null;
    }
  }
}
