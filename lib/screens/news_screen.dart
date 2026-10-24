import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/config/supabase_config.dart';
import '../core/theme/absentease_theme.dart';
import '../features/article/services/article_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = ArticleService();
  late Future<List<Map<String, dynamic>>> _articles;

  @override
  void initState() {
    super.initState();
    _articles = _service.getPublishedArticles(limit: 20);
  }

  Future<void> _reload() async {
    setState(() => _articles = _service.getPublishedArticles(limit: 20));
    await _articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Berita & Artikel'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat artikel: ${snapshot.error}'));
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return Center(
              child: Text(SupabaseConfig.isConfigured
                  ? 'Belum ada artikel yang dipublikasikan'
                  : 'Hubungkan Supabase untuk melihat artikel'),
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final art = articles[i];
                final title = art['title']?.toString() ?? 'Tanpa Judul';
                final content = art['content']?.toString() ?? '';
                final pubDate = art['published_at'] != null
                    ? DateFormat('dd MMMM yyyy', 'id_ID')
                        .format(DateTime.parse(art['published_at']))
                    : 'Terbaru';
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AbsenEaseTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(11)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: AbsenEaseTheme.textMuted,
                            size: 36,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AbsenEaseTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AbsenEaseTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pubDate,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AbsenEaseTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
