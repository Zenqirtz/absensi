import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class ArticleService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<List<Map<String, dynamic>>> getPublishedArticles({
    int limit = 10,
  }) async {
    final client = _client;
    if (client == null) return [];
    final res = await client
        .from('articles')
        .select()
        .eq('is_published', true)
        .order('published_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>?> getArticle(String id) async {
    final client = _client;
    if (client == null) return null;
    final res = await client
        .from('articles')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res;
  }
}
