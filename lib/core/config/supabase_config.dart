import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inisialisasi Supabase untuk AbsenEase.
/// Jika file `.env` belum diisi dengan kredensial asli, aplikasi tetap
/// dapat berjalan dalam mode demo (offline) tanpa mencoba koneksi ke Supabase
/// supaya tidak crash saat pertama kali dipasang (R-38).
class SupabaseConfig {
  SupabaseConfig._();

  /// Sudah dikonfigurasi dengan kredensial Supabase asli?
  static bool isConfigured = false;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

    // Jangan inisialisasi jika kredensial masih placeholder / kosong.
    if (url.isEmpty ||
        anonKey.isEmpty ||
        url.contains('your-project') ||
        anonKey.contains('your-anon')) {
      isConfigured = false;
      return;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      debug: true,
    );
    isConfigured = true;
  }

  static SupabaseClient get client => Supabase.instance.client;

  static SupabaseClient? get clientOrNull =>
      isConfigured ? Supabase.instance.client : null;
}
