import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../core/config/supabase_config.dart';
import '../core/theme/absentease_theme.dart';
import '../core/widgets/absentease_brand.dart';
import '../features/attendance/services/attendance_service.dart';
import '../features/attendance/widgets/sukses_absen_dialog.dart';
import '../features/employee/services/employee_service.dart';
import '../features/article/services/article_service.dart';
import '../features/notification/services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _attendanceService = AttendanceService();
  final _employeeService = EmployeeService();
  final _articleService = ArticleService();
  final _notificationService = NotificationService();

  bool _checkedIn = false;
  bool _isLoading = false;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _articles = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final checked = await _attendanceService.hasCheckedInToday();
      final profile = await _employeeService.getProfile();
      final articles = await _articleService.getPublishedArticles(limit: 5);
      final notifs = await _notificationService.getMyNotifications(limit: 3);
      if (mounted) {
        setState(() {
          _checkedIn = checked;
          _profile = profile;
          _articles = articles;
          _notifications = notifs;
        });
      }
    } catch (_) {}
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        throw TimeoutException('Lokasi tidak terdeteksi');
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleCheckIn() async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);

    setState(() => _isLoading = true);
    try {
      if (!SupabaseConfig.isConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Supabase belum dikonfigurasi. Isi .env dan restart.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final pos = await _getCurrentLocation();
      final lat = pos?.latitude ?? -6.2088;
      final lng = pos?.longitude ?? 106.8456;

      if (!_checkedIn) {
        await _attendanceService.checkIn(
          latitude: lat,
          longitude: lng,
          address: pos != null ? 'Koordinat ($lat, $lng)' : 'Kantor Pusat',
        );
      } else {
        await _attendanceService.checkOut(
          latitude: lat,
          longitude: lng,
          address: pos != null ? 'Koordinat ($lat, $lng)' : 'Kantor Pusat',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat presensi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    setState(() => _checkedIn = !_checkedIn);

    final currentUser = SupabaseConfig.clientOrNull?.auth.currentUser;
    final metadataName = currentUser?.userMetadata?['full_name']?.toString().trim();
    final profileName = _profile?['full_name']?.toString().trim();
    final displayName = (metadataName != null && metadataName.isNotEmpty)
        ? metadataName
        : (profileName != null && profileName.isNotEmpty)
            ? profileName
            : currentUser?.email?.split('@').first ?? 'John Doe';

    showDialog<void>(
      context: context,
      builder: (context) => SuksesAbsenDialog(
        nama: displayName,
        tanggal: dateStr.isNotEmpty ? dateStr : 'Jum\'at 03 Maret 2023',
        waktu: '$timeStr WIB',
        status: _checkedIn ? 'Absen Masuk' : 'Absen Pulang',
        onTutup: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('EEEE dd MMMM yyyy', 'id_ID').format(now);

    final currentUser = SupabaseConfig.clientOrNull?.auth.currentUser;
    final metadataName = currentUser?.userMetadata?['full_name']?.toString().trim();
    final profileName = _profile?['full_name']?.toString().trim();
    final displayName = (metadataName != null && metadataName.isNotEmpty)
        ? metadataName
        : (profileName != null && profileName.isNotEmpty)
            ? profileName
            : currentUser?.email?.split('@').first ?? 'John Doe';
    final displayRole = _profile?['role'] ?? 'Staff';
    final initials = displayName.length >= 2
        ? displayName.substring(0, 2).toUpperCase()
        : 'JD';

    return Scaffold(
      backgroundColor: AbsenEaseTheme.navy,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AbsenEaseTheme.navy,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AbsenEaseWordmark(fontSize: 16),
                      IconButton(
                        tooltip: 'Pemberitahuan',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE8D2C1),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AbsenEaseTheme.navy,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              displayRole,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$timeStr WIB',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Kalender presensi',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/calendar'),
                        icon: const Icon(
                          Icons.event_note_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleCheckIn,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_checkedIn ? 'Absen Pulang' : 'Absen Masuk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: RefreshIndicator(
                  onRefresh: _loadAllData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _menuItem(
                              'Daftar\nKaryawan',
                              Icons.people_alt_rounded,
                              () => Navigator.pushNamed(context, '/employees')),
                          _menuItem(
                              'Izin Cuti',
                              Icons.event_available_rounded,
                              () => Navigator.pushNamed(context, '/leave')),
                          _menuItem(
                              'Kalender',
                              Icons.calendar_month_rounded,
                              () => Navigator.pushNamed(context, '/calendar')),
                          _menuItem(
                              'Lembur',
                              Icons.more_time_rounded,
                              () => Navigator.pushNamed(context, '/overtime')),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _sectionHeading(
                        'Artikel',
                        'Lihat Semua',
                        () => Navigator.pushNamed(context, '/news'),
                        subtitle: 'Baca artikel dari perusahaan',
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 153,
                        child: _articles.isEmpty
                            ? Center(
                                child: Text(
                                  'Belum ada artikel',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AbsenEaseTheme.textMuted,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _articles.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final art = _articles[i];
                                  final title = art['title'] ?? 'Tanpa Judul';
                                  final pub = art['published_at'] != null
                                      ? DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(art['published_at']))
                                      : 'Terbaru';
                                  return _articleCard(title, pub);
                                },
                              ),
                      ),
                      const SizedBox(height: 17),
                      _sectionHeading(
                        'Pemberitahuan',
                        'Lihat Semua',
                        () => Navigator.pushNamed(context, '/notifications'),
                        subtitle: 'Daftar pemberitahuan terbaru',
                      ),
                      const SizedBox(height: 8),
                      if (_notifications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Tidak ada pemberitahuan baru',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AbsenEaseTheme.textMuted,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._notifications.map((n) {
                          final title = n['title'] ?? 'Info';
                          final msg = n['message'] ?? '';
                          final dt = n['created_at'] != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(n['created_at']))
                              : '';
                          return Column(
                            children: [
                              _notificationRow(title, msg, dt),
                              const Divider(
                                  height: 1, color: AbsenEaseTheme.border),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Icon(icon, color: AbsenEaseTheme.magenta, size: 22),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AbsenEaseTheme.textDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String action,
    VoidCallback onTap, {
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AbsenEaseTheme.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                action,
                style: GoogleFonts.inter(
                  color: AbsenEaseTheme.magenta,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _articleCard(String title, String date) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlaceholderImage(height: 91, radius: 9),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 3),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AbsenEaseTheme.textDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              date,
              style: GoogleFonts.inter(
                color: AbsenEaseTheme.textMuted,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationRow(String title, String name, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AbsenEaseTheme.magenta,
            size: 17,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AbsenEaseTheme.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: AbsenEaseTheme.textDark,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: GoogleFonts.inter(
              color: AbsenEaseTheme.textMuted,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
