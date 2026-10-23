import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class OvertimeService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getMyOvertimes() async {
    final client = _client;
    if (client == null) return [];
    final uid = client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await client
        .from('overtime')
        .select()
        .eq('employee_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> submitOvertime({
    required DateTime date,
    required String startTime,
    required String endTime,
    required double hours,
    String? reason,
  }) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) throw Exception('User belum login');
    await client.from('overtime').insert({
      'employee_id': uid,
      'date': date.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'hours': hours,
      'reason': reason,
      'status': 'pending',
    });
  }
}
