import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    _articles = _service.getPublishedArticles(limit: 50);
  }

  Future<void> _reload() async {
    setState(() => _articles = _service.getPublishedArticles(limit: 50));
    await _articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Artikel'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat artikel: ${snapshot.error}'));
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(child: Text('Belum ada artikel yang diterbitkan'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final art = articles[index];
                final title = art['title']?.toString() ?? 'Tanpa Judul';
                final content = art['content']?.toString() ?? '';
                final pub = art['published_at'] != null
                    ? DateFormat('dd MMMM yyyy', 'id_ID')
                        .format(DateTime.parse(art['published_at']))
                    : 'Terbaru';
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AbsenEaseTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                        ),
                        child: const Center(
                          child: Icon(Icons.article_rounded,
                              color: Color(0xFFD1D5DB), size: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(pub,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AbsenEaseTheme.textMuted)),
                            if (content.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12)),
                            ],
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
