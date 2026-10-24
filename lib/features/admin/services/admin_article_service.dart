import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminArticleService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<bool> publishArticle({
    required String title,
    required String content,
  }) async {
    final client = _client;
    if (client == null) return false;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await client.from('articles').insert({
        'title': title,
        'content': content,
        'author_id': uid,
        'published_at': DateTime.now().toIso8601String(),
        'is_published': true,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> broadcastNotification({
    required String title,
    required String body,
  }) async {
    final client = _client;
    if (client == null) return false;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      final empRes = await client
          .from('employees')
          .select('id')
          .eq('is_active', true);
      final batch = (empRes as List).map((e) => {
            'user_id': e['id'],
            'title': title,
            'body': body,
            'type': 'broadcast',
            'sender_id': uid,
          }).toList();
      if (batch.isNotEmpty) {
        await client.from('notifications').insert(batch);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
