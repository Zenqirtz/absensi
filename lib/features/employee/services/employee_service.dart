import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class EmployeeService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<Map<String, dynamic>?> getProfile() async {
    final client = _client;
    if (client == null) return null;
    final user = client.auth.currentUser;
    final uid = user?.id;
    if (uid == null) return null;

    try {
      final res = await client
          .from('employees')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (res != null) return res;

      // Jika belum ada row di employees, buat otomatis dari auth user metadata
      final metaName = user?.userMetadata?['full_name']?.toString();
      final email = user?.email ?? '';
      final fallbackName = (metaName != null && metaName.trim().isNotEmpty)
          ? metaName
          : email.split('@').first;

      final inserted = await client.from('employees').insert({
        'id': uid,
        'email': email,
        'full_name': fallbackName,
        'role': 'Staff',
      }).select().maybeSingle();

      return inserted;
    } catch (_) {
      return null;
    }
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
