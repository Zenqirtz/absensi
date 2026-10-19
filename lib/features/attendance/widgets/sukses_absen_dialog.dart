import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/absentease_theme.dart';

/// Dialog sukses mengikuti referensi: kartu putih, centang magenta,
/// judul dan detail dua baris di panel pink, tombol magenta pill.
class SuksesAbsenDialog extends StatelessWidget {
  final String nama;
  final String tanggal;
  final String waktu;
  final String status;
  final VoidCallback onTutup;

  const SuksesAbsenDialog({
    super.key,
    required this.nama,
    required this.tanggal,
    required this.waktu,
    required this.status,
    required this.onTutup,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: AbsenEaseTheme.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AbsenEaseTheme.magenta,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 14),
            Text(
              'Anda berhasil Absen',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AbsenEaseTheme.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selamat data absen Anda berhasil di rekam',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AbsenEaseTheme.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: AbsenEaseTheme.magentaSoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Absen',
                    style: GoogleFonts.inter(
                      color: AbsenEaseTheme.textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailLine(Icons.calendar_month_rounded, tanggal),
                  const SizedBox(height: 9),
                  _detailLine(Icons.access_time_rounded, waktu),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTutup,
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AbsenEaseTheme.magenta, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
