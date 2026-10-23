import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/absentease_theme.dart';
import '../features/notification/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _service.getMyNotifications(limit: 50);
  }

  Future<void> _reload() async {
    setState(() => _notifications = _service.getMyNotifications(limit: 50));
    await _notifications;
  }

  Future<void> _markRead(String id) async {
    await _service.markAsRead(id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Pemberitahuan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat notifikasi: ${snapshot.error}'));
          }
          final notifs = snapshot.data ?? [];
          if (notifs.isEmpty) {
            return const Center(child: Text('Tidak ada pemberitahuan'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifs.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AbsenEaseTheme.border),
              itemBuilder: (context, index) {
                final n = notifs[index];
                final isRead = n['is_read'] == true;
                final dt = n['created_at'] != null
                    ? DateFormat('dd MMM yyyy HH:mm')
                        .format(DateTime.parse(n['created_at']))
                    : '';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: isRead
                        ? AbsenEaseTheme.textMuted
                        : AbsenEaseTheme.magenta,
                    size: 22,
                  ),
                  title: Text(
                    n['title']?.toString() ?? 'Info',
                    style: TextStyle(
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (n['message'] != null &&
                          n['message'].toString().isNotEmpty)
                        Text(n['message'].toString(),
                            style: const TextStyle(fontSize: 12)),
                      Text(dt,
                          style: const TextStyle(
                              fontSize: 10, color: AbsenEaseTheme.textMuted)),
                    ],
                  ),
                  trailing: !isRead
                      ? IconButton(
                          icon: const Icon(Icons.done, size: 18),
                          tooltip: 'Tandai dibaca',
                          onPressed: () => _markRead(n['id'].toString()),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
