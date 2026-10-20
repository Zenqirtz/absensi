import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

/// Service otentikasi Supabase.
class AuthService {
  AuthService();

  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  bool get isConfigured => SupabaseConfig.isConfigured;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Masuk dengan email & kata sandi.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException('Supabase belum dikonfigurasi di file .env');
    }
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Daftar akun baru dan buat baris employee awal.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthException('Supabase belum dikonfigurasi di file .env');
    }
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      await client.from('employees').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
      });
    }

    return response;
  }

  /// Keluar dari sesi.
  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
