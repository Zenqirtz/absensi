import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminAttendanceService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getTodayAllAttendance() async {
    final client = _client;
    if (client == null) return [];
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final res = await client
          .from('attendance')
          .select('*, employees(full_name, department)')
          .gte('check_time', startOfDay.toIso8601String())
          .lt('check_time', endOfDay.toIso8601String())
          .order('check_time', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyAllAttendance({
    required int year,
    required int month,
  }) async {
    final client = _client;
    if (client == null) return [];
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);
      final res = await client
          .from('attendance')
          .select('*, employees(full_name, department)')
          .gte('check_time', startDate.toIso8601String())
          .lt('check_time', endDate.toIso8601String())
          .order('check_time', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getSummaryToday() async {
    final client = _client;
    if (client == null) return {'present': 0, 'total_employees': 0};
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final attendanceRes = await client
          .from('attendance')
          .select('employee_id')
          .eq('type', 'check_in')
          .gte('check_time', startOfDay.toIso8601String())
          .lt('check_time', endOfDay.toIso8601String());

      final presentSet = attendanceRes
          .map((r) => r['employee_id']?.toString())
          .where((id) => id != null)
          .toSet();

      final employeesRes = await client
          .from('employees')
          .select('id')
          .eq('is_active', true);

      return {
        'present': presentSet.length,
        'total_employees': employeesRes.length,
      };
    } catch (_) {
      return {'present': 0, 'total_employees': 0};
    }
  }
}
