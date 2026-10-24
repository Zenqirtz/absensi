import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminLeaveService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getPendingLeaves() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
          .from('leaves')
          .select('*, employees!inner(full_name, department)')
          .eq('status', 'pending');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllLeaves() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
          .from('leaves')
          .select('*, employees!inner(full_name, department)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveLeave(String id) async {
    final client = _client;
    if (client == null) return false;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await client.from('leaves').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': uid,
      }).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectLeave(String id, {String? notes}) async {
    final client = _client;
    if (client == null) return false;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await client.from('leaves').update({
        'status': 'rejected',
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': uid,
        'notes': notes,
      }).eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
