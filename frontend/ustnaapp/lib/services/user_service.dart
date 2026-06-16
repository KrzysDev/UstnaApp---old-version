import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  int _guestFreeTries = 2;

  /// Pobranie liczby darmowych użyć
  Future<int> getFreeTries() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return _guestFreeTries;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select('free_uses_left')
          .eq('id', user.id)
          .single();

      final tries = data['free_uses_left'] as int?;
      print('UserService: Loaded free tries from DB: $tries');
      return tries ?? 2;
    } catch (e) {
      print('UserService: Error getting free tries: $e');
      rethrow;
    }
  }

  /// Konsumpcja użycia wyłącznie przez RPC.
  Future<void> consumeFreeUse() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (_guestFreeTries > 0) {
        _guestFreeTries--;
      }
      return;
    }

    try {
      print('UserService: Consuming free use via RPC decrement_free_use...');
      final result = await _supabase.rpc('decrement_free_use');
      print('UserService: RPC decrement_free_use returned: $result');

      if (result is Map) {
        if (result['success'] == true) {
          print('UserService: RPC reported success.');
          return;
        }

        final msg = result['message']?.toString() ?? 'Brak darmowych użyć';
        throw Exception(msg);
      }

      if (result is bool) {
        if (result == true) {
          print('UserService: RPC returned true.');
          return;
        }

        throw Exception('RPC returned false');
      }

      print('UserService: RPC executed successfully.');
    } catch (rpcError) {
      print('UserService: RPC decrement_free_use failed: $rpcError');
      rethrow;
    }
  }

  /// Reset wyłącznie przez RPC.
  Future<void> resetFreeTries() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _guestFreeTries = 2;
      return;
    }

    try {
      await _supabase.rpc('set_free_uses');
    } catch (e) {
      print('Reset error: $e.');
      rethrow;
    }
  }
}
