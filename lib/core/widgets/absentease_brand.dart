import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/absentease_theme.dart';

/// Mark AbsenEase: dua kotak berputar 45 derajat yang bertumpuk.
/// Alasan: mark referensi berbentuk belah ketupat ganda, dibentuk dari bentuk
/// geometris dasar supaya tidak perlu aset gambar (R-23, R-38).
class AbsenEaseLogo extends StatelessWidget {
  final double size;
  final Color mark;

  const AbsenEaseLogo({
    super.key,
    this.size = 22,
    this.mark = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final double unit = size * 0.66;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _diamond(unit, mark),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _diamond(unit, AbsenEaseTheme.magenta),
          ),
        ],
      ),
    );
  }

  Widget _diamond(double unit, Color color) {
    return Transform.rotate(
      angle: 0.785398,
      child: Container(
        width: unit,
        height: unit,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(unit * 0.14),
        ),
      ),
    );
  }
}

/// Judul brand: mark + wordmark.
class AbsenEaseWordmark extends StatelessWidget {
  final Color textColor;
  final double fontSize;

  const AbsenEaseWordmark({
    super.key,
    this.textColor = Colors.white,
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AbsenEaseLogo(size: fontSize + 6, mark: textColor),
        const SizedBox(width: 8),
        Text(
          'AbsenEase',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Placeholder gambar.
/// Alasan: referensi memakai foto asli (tangan, buku agenda). Foto belum
/// tersedia, jadi dipakai blok abu dengan label "Foto" supaya jelas placeholder
/// dan tidak menyamar sebagai aset final (R-23, R-38).
class PlaceholderImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const PlaceholderImage({
    super.key,
    this.width,
    this.height,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(asset): ganti dengan foto asli saat aset tersedia (R-23).
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AbsenEaseTheme.placeholder,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_outlined,
              color: AbsenEaseTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              'Foto',
              style: GoogleFonts.inter(
                color: AbsenEaseTheme.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
