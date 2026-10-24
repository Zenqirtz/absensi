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
    if (client == null) {
      debugPrint('AdminStaffService.addEmployee: client is null');
      return false;
    }
    try {
      debugPrint('AdminStaffService.addEmployee: invoking create-employee...');
      debugPrint('AdminStaffService.addEmployee: email=$email, fullName=$fullName');
      
      final res = await client.functions.invoke(
        'create-employee',
        body: {
          'email': email,
          'password': 'AbsenEase2026!',
          'full_name': fullName,
          'role': 'Staff',
          'department': department,
          'phone': phone,
        },
      );

      debugPrint('AdminStaffService.addEmployee: response status=${res.status}');
      debugPrint('AdminStaffService.addEmployee: response data=${res.data}');
      
      if (res.status == 200 || res.status == 201) {
        debugPrint('AdminStaffService.addEmployee: SUCCESS');
        return true;
      }

      debugPrint('AdminStaffService.addEmployee: FAILED with status ${res.status}');
      return false;
    } catch (error, stackTrace) {
      debugPrint('AdminStaffService.addEmployee EXCEPTION: $error');
      debugPrint('AdminStaffService.addEmployee STACKTRACE: $stackTrace');
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
