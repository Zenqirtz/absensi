import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminStaffService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final client = _client;
    if (client == null) {
      debugPrint('AdminStaffService: client is null, isConfigured=${SupabaseConfig.isConfigured}');
      return [];
    }
    try {
      final res = await client
          .from('employees')
          .select()
          .eq('is_active', true)
          .order('full_name');
      debugPrint('AdminStaffService: fetched ${res.length} employees');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('AdminStaffService: error fetching employees: $e');
      return [];
    }
  }

  Future<bool> addEmployee({
    required String email,
    required String fullName,
    String? department,
    String? phone,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      debugPrint('AdminStaffService.addEmployee: inserting employee $email...');
      
      // Cek apakah email sudah ada
      final existing = await client
          .from('employees')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      if (existing != null) {
        debugPrint('AdminStaffService.addEmployee: email already exists');
        return false;
      }
      
      // Insert langsung ke tabel employees tanpa auth
      // Karyawan akan mendaftar sendiri nanti dan otomatis terhubung via email
      await client.from('employees').insert({
        'email': email,
        'full_name': fullName,
        'role': 'Staff',
        'department': department,
        'phone': phone,
        'is_active': true,
      });
      debugPrint('AdminStaffService.addEmployee: success');
      return true;
    } catch (error) {
      debugPrint('AdminStaffService.addEmployee error: $error');
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

  Future<bool> deleteEmployee(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      final updated = await client
          .from('employees')
          .update({'is_active': false})
          .eq('id', id)
          .select('id');
      return updated.isNotEmpty;
    } catch (error) {
      debugPrint('AdminStaffService.deleteEmployee failed: $error');
      return false;
    }
  }

  Future<bool> deactivateEmployee(String id) async {
    return deleteEmployee(id);
  }
}
