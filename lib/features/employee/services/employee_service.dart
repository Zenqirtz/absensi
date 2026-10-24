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

      final metaName = user?.userMetadata?['full_name']?.toString().trim();
      final email = user?.email ?? '';
      final emailPrefix = email.split('@').first;

      if (res != null) {
        // Jika di database masih nama email atau kosong, perbarui dengan metadata
        final currentDbName = res['full_name']?.toString().trim();
        if (metaName != null &&
            metaName.isNotEmpty &&
            (currentDbName == null || currentDbName.isEmpty || currentDbName == emailPrefix)) {
          try {
            await client
                .from('employees')
                .update({'full_name': metaName})
                .eq('id', uid);
            res['full_name'] = metaName;
          } catch (_) {}
        }
        return res;
      }

      // Jika belum ada row di employees, buat baru
      final fallbackName = (metaName != null && metaName.isNotEmpty)
          ? metaName
          : emailPrefix;

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
