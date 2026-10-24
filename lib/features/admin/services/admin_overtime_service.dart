import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminOvertimeService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getPendingOvertimes() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
          .from('overtime')
          .select('*, employees!inner(full_name, department)')
          .eq('status', 'pending');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllOvertimes() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
          .from('overtime')
          .select('*, employees!inner(full_name, department)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveOvertime(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('overtime').update({
        'status': 'approved',
      }).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectOvertime(String id, {String? notes}) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('overtime').update({
        'status': 'rejected',
        'notes': notes,
      }).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
