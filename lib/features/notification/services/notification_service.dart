import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class NotificationService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getMyNotifications({
    int limit = 10,
  }) async {
    final client = _client;
    if (client == null) return [];
    final uid = client.auth.currentUser?.id;
    if (uid == null) return [];
    final res = await client
        .from('notifications')
        .select()
        .eq('employee_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> markAsRead(String id) async {
    final client = _client;
    if (client == null) return;
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }
}
