import 'package:flutter/material.dart';
import '../core/theme/absentease_theme.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  static const List<Map<String, String>> _articles = [
    {
      'title': 'Tips Manajemen Waktu untuk Produktivitas Maksimal',
      'date': 'Jum\'at 03 Maret 2023',
      'body':
          'Produktivitas bukan soal bekerja lebih lama, tapi bekerja lebih terarah. Mulai dengan memetakan tugas harian, lalu tentukan tiga prioritas utama. Batasi notifikasi saat sesi fokus berlangsung.',
    },
    {
      'title': 'Pentingnya Disiplin Presensi Karyawan',
      'date': 'Jum\'at 12 Februari 2023',
      'body':
          'Presensi yang konsisten membantu tim HR menghitung beban kerja dan mengatur jadwal shift. Catat kehadiran segera setelah tiba di kantor agar data tetap akurat.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        title: const Text(
          'Artikel',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AbsenEaseTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AbsenEaseTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article['date']!,
                  style: const TextStyle(fontSize: 11, color: AbsenEaseTheme.textMuted),
                ),
                const SizedBox(height: 10),
                Text(
                  article['body']!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AbsenEaseTheme.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
