import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens AbsenEase.
/// Diturunkan langsung dari tangkapan layar referensi:
/// - Navy: `#0F1240` (header beranda)
/// - Magenta: `#E40066` (tombol utama, dot carousel aktif, tanggal aktif kalender)
/// - Pink lembut: `#FDE8EF` (kotak detail sukses absen)
/// - Putih: latar layar login, modal, kalender, kartu konten
/// - Abu-abu pembatas: `#E5E7EB`
class AbsenEaseTheme {
  static const Color navy = Color(0xFF0F1240);
  static const Color magenta = Color(0xFFE40066);
  static const Color magentaSoft = Color(0xFFFDE8EF);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color placeholder = Color(0xFFE5E7EB);
  static const Color canvas = Color(0xFFF8F9FD);
  static const Color magentaLight = magentaSoft;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      primaryColor: navy,
      colorScheme: const ColorScheme.light(
        primary: navy,
        secondary: magenta,
        surface: white,
        error: Colors.redAccent,
        onPrimary: white,
        onSecondary: white,
        onSurface: textDark,
      ),
      textTheme: baseText.copyWith(
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: magenta,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: magenta, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 13,
        ),
      ),
    );
  }
}
