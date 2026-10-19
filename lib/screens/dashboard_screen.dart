import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/absentease_theme.dart';
import '../core/widgets/absentease_brand.dart';
import '../features/attendance/widgets/sukses_absen_dialog.dart';

/// Beranda: komposisi navy di atas + panel putih konten seperti referensi.
/// Menu ditahan dalam satu baris; dua baris kartu diganti ikon label rapat
/// agar urutan visual dan rasio layar mengikuti mockup.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _checkedIn = false;

  void _handleCheckIn() {
    setState(() => _checkedIn = true);
    showDialog<void>(
      context: context,
      builder: (context) => SuksesAbsenDialog(
        nama: 'John Doe',
        tanggal: 'Jum\'at 03 Maret 2023',
        waktu: '08:48 WIB',
        status: 'Absen Masuk',
        onTutup: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Area navy: wordmark, notifikasi, profil, waktu, tombol absen.
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
                        onPressed: () => Navigator.pushNamed(context, '/notifications'),
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
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE8D2C1),
                        child: Text(
                          'JD',
                          style: TextStyle(
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
                              'John Doe',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'UI/UX Designer',
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
                            '09:50 WIB',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Jum\'at 12 Februari 2023',
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
                        onPressed: () => Navigator.pushNamed(context, '/calendar'),
                        icon: const Icon(
                          Icons.event_note_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleCheckIn,
                          child: Text(_checkedIn ? 'Absen Pulang' : 'Absen Masuk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Panel putih seperti lembar konten di referensi.
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _menuItem('Daftar\nKaryawan', Icons.people_alt_rounded,
                            () => Navigator.pushNamed(context, '/employees')),
                        _menuItem('Izin Cuti', Icons.event_available_rounded,
                            () => Navigator.pushNamed(context, '/leave')),
                        _menuItem('Kalender', Icons.calendar_month_rounded,
                            () => Navigator.pushNamed(context, '/calendar')),
                        _menuItem('Lembur', Icons.more_time_rounded,
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _articleCard('Agenda Bulan Januari', '01/01/2023'),
                          const SizedBox(width: 10),
                          _articleCard('WFH vs WFO', '22/12/2022'),
                        ],
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
                    _notificationRow(
                      '23 Mei 2023 Libur',
                      'Ahmad Aswin',
                      '06 Mar 2023',
                    ),
                    const Divider(height: 1, color: AbsenEaseTheme.border),
                    _notificationRow(
                      'Selamat Datang Anisa',
                      'Pengumuman perusahaan',
                      '03 Mar 2023',
                    ),
                    const Divider(height: 1, color: AbsenEaseTheme.border),
                  ],
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
          BoxShadow(color: Color(0x0C000000), blurRadius: 5, offset: Offset(0, 2)),
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
