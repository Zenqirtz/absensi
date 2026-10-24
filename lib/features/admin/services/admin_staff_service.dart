import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminStaffService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client.from('employees').select().order('full_name');
      return List<Map<String, dynamic>>.from(res);
    } catch (_) {
      return [];
    }
  }

  Future<bool> addEmployee({
    required String email,
    required String fullName,
    required String password,
    String? department,
    String? phone,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      final authRes = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'Staff'},
      );
      if (authRes.user == null) return false;
      final uid = authRes.user!.id;
      await client.from('employees').insert({
        'id': uid,
        'email': email,
        'full_name': fullName,
        'role': 'Staff',
        'department': department,
        'phone': phone,
        'is_active': true,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEmployee({
    required String id,
    String? fullName,
    String? department,
    String? phone,
    bool? isActive,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      final payload = <String, dynamic>{};
      if (fullName != null) payload['full_name'] = fullName;
      if (department != null) payload['department'] = department;
      if (phone != null) payload['phone'] = phone;
      if (isActive != null) payload['is_active'] = isActive;
      if (payload.isEmpty) return true;
      await client.from('employees').update(payload).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleAdminRole(String id, bool makeAdmin) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('employees').update({
        'role': makeAdmin ? 'Admin' : 'Staff',
      }).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deactivateEmployee(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('employees').update({'is_active': false}).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
