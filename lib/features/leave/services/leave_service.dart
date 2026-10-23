import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class LeaveService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getMyLeaves() async {
    final client = _client;
    if (client == null) return [];
    final uid = client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await client
        .from('leaves')
        .select()
        .eq('employee_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> submitLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) throw Exception('User belum login');
    await client.from('leaves').insert({
      'employee_id': uid,
      'type': type,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'reason': reason,
      'status': 'pending',
    });
  }
}
