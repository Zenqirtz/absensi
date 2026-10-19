import 'package:flutter/material.dart';
import '../core/theme/absentease_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<Map<String, String>> _items = [
    {
      'title': 'Pengajuan Cuti Disetujui',
      'body': 'Pengajuan cuti tahunan Anda telah disetujui HR.',
      'time': '09:12',
    },
    {
      'title': 'Pengingat Absen Pulang',
      'body': 'Jangan lupa melakukan absen pulang sebelum 18:00 WIB.',
      'time': 'Kemarin',
    },
    {
      'title': 'Pengumuman Perusahaan',
      'body': 'Rapat bulanan digeser ke Jum\'at 03 Maret 2023.',
      'time': '2 hari lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AbsenEaseTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AbsenEaseTheme.magentaLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AbsenEaseTheme.magenta,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AbsenEaseTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['body']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AbsenEaseTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['time']!,
                        style: const TextStyle(fontSize: 10, color: AbsenEaseTheme.textMuted),
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
  }
}
