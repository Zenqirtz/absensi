import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

/// Service untuk mengelola data presensi di Supabase.
class AttendanceService {
  AttendanceService();

  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  String? get _userId => _client?.auth.currentUser?.id;

  /// Ambil data presensi hari ini untuk user yang sedang login.
  Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await client
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .gte('check_time', startOfDay.toIso8601String())
        .lt('check_time', endOfDay.toIso8601String())
        .order('check_time', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Absen masuk.
  Future<void> checkIn({
    required double latitude,
    required double longitude,
    String? address,
    String? photoUrl,
    String? notes,
  }) async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) {
      throw Exception('Supabase belum dikonfigurasi atau user belum login');
    }

    await client.from('attendance').insert({
      'employee_id': userId,
      'type': 'check_in',
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'photo_url': photoUrl,
      'notes': notes,
    });
  }

  /// Absen pulang.
  Future<void> checkOut({
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
  }) async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) {
      throw Exception('Supabase belum dikonfigurasi atau user belum login');
    }

    await client.from('attendance').insert({
      'employee_id': userId,
      'type': 'check_out',
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'notes': notes,
    });
  }

  /// Riwayat presensi bulan ini.
  Future<List<Map<String, dynamic>>> getMonthlyAttendance({
    required int year,
    required int month,
  }) async {
    final client = _client;
    final userId = _userId;
    if (client == null || userId == null) return [];

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final response = await client
        .from('attendance')
        .select()
        .eq('employee_id', userId)
        .gte('check_time', startDate.toIso8601String())
        .lt('check_time', endDate.toIso8601String())
        .order('check_time', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Cek apakah sudah absen masuk hari ini.
  Future<bool> hasCheckedInToday() async {
    final today = await getTodayAttendance();
    return today.any((record) => record['type'] == 'check_in');
  }

  /// Cek apakah sudah absen pulang hari ini.
  Future<bool> hasCheckedOutToday() async {
    final today = await getTodayAttendance();
    return today.any((record) => record['type'] == 'check_out');
  }
}
