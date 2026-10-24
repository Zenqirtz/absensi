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
    if (client == null) {
      return {'present': 0, 'late': 0, 'leave': 0, 'alpha': 0, 'total': 0};
    }
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 1. Ambil setting jam kerja
      int workHour = 8;
      int workMinute = 0;
      int lateThreshold = 15;
      try {
        final settingRes = await client
            .from('app_settings')
            .select()
            .eq('id', 'global')
            .maybeSingle();
        if (settingRes != null) {
          final timeStr = settingRes['work_start_time']?.toString() ?? '08:00';
          final parts = timeStr.split(':');
          if (parts.isNotEmpty) workHour = int.tryParse(parts[0]) ?? 8;
          if (parts.length > 1) workMinute = int.tryParse(parts[1]) ?? 0;
          lateThreshold = (settingRes['late_threshold_minutes'] as num?)?.toInt() ?? 15;
        }
      } catch (_) {}

      final lateCutoff = DateTime(now.year, now.month, now.day, workHour, workMinute)
          .add(Duration(minutes: lateThreshold));

      // 2. Ambil attendance hari ini
      final attendanceRes = await client
          .from('attendance')
          .select('employee_id, check_time')
          .eq('type', 'check_in')
          .gte('check_time', startOfDay.toIso8601String())
          .lt('check_time', endOfDay.toIso8601String());

      final onTimeSet = <String>{};
      final lateSet = <String>{};

      for (final r in attendanceRes) {
        final empId = r['employee_id']?.toString();
        if (empId == null) continue;
        final checkTimeStr = r['check_time']?.toString();
        if (checkTimeStr != null) {
          final checkTime = DateTime.tryParse(checkTimeStr);
          if (checkTime != null && checkTime.isAfter(lateCutoff)) {
            lateSet.add(empId);
            continue;
          }
        }
        onTimeSet.add(empId);
      }

      // 3. Ambil izin hari ini
      int leaveCount = 0;
      try {
        final leaveRes = await client
            .from('leaves')
            .select('employee_id')
            .eq('status', 'approved')
            .lte('start_date', todayStr)
            .gte('end_date', todayStr);
        final leaveSet = (leaveRes as List)
            .map((e) => e['employee_id']?.toString())
            .where((id) => id != null)
            .toSet();
        leaveCount = leaveSet.length;
      } catch (_) {}

      // 4. Total karyawan aktif
      final employeesRes = await client
          .from('employees')
          .select('id')
          .eq('is_active', true);
      final total = employeesRes.length;

      final totalHadir = onTimeSet.length;
      final totalTelat = lateSet.length;
      final alpha = (total - (totalHadir + totalTelat + leaveCount)).clamp(0, 9999);

      return {
        'present': totalHadir,
        'late': totalTelat,
        'leave': leaveCount,
        'alpha': alpha,
        'total': total,
      };
    } catch (_) {
      return {'present': 0, 'late': 0, 'leave': 0, 'alpha': 0, 'total': 0};
    }
  }
}
