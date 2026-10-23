import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class EmployeeService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<Map<String, dynamic>?> getProfile() async {
    final client = _client;
    if (client == null) return null;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    final res = await client
        .from('employees')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return res;
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final client = _client;
    if (client == null) return [];
    // HR read: coba SELECT semua, kalau RLS blokir kembalikan kosong.
    try {
      final res = await client
          .from('employees')
          .select()
          .eq('is_active', true)
          .order('full_name');
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? role,
    String? department,
    String? phone,
  }) async {
    final client = _client;
    final uid = client?.auth.currentUser?.id;
    if (client == null || uid == null) return;
    await client.from('employees').update({
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }
}
