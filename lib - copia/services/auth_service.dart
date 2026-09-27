import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseService.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static String? get currentUserRole =>
      currentUser?.userMetadata?['role'] as String?;

  static bool get isPropietaria => currentUserRole == 'propietaria';

  static bool get isConductor => currentUserRole == 'conductor';

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        if (phone != null) 'phone': phone,
      },
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDriverProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    try {
      final response = await _client
          .from('driver_profiles')
          .select('*, motos(*), user_profiles(*)')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }
}
