import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/absentease_theme.dart';
import '../../../core/widgets/absentease_brand.dart';

/// Layar Login — referensi layar tengah.
/// Struktur visual:
/// - Latar putih bersih.
/// - Top bar: brand AbsenEase di kiri, info icon (i) di kanan.
/// - Hero kartu gambar tangan memegang ponsel (placeholder foto jujur R-23).
/// - Tiga dot pagination (tengah aktif magenta).
/// - Judul dua baris: "Presensi kapan saja," dan "dan dimana saja" (kata magenta).
/// - Subjudul: "Dengan absen app presensi menjadi lebih mudah".
/// - Form: input E-mail (ikon mail), Password (ikon gembok).
/// - Link kanan: "Lupa Password?".
/// - Tombol pill magenta: "Login".
class AbsenEaseLoginScreen extends StatefulWidget {
  const AbsenEaseLoginScreen({super.key});

  @override
  State<AbsenEaseLoginScreen> createState() => _AbsenEaseLoginScreenState();
}

class _AbsenEaseLoginScreenState extends State<AbsenEaseLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _handleInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tentang AbsenEase',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Aplikasi presensi mobile. Mode demo: masukkan teks apa saja lalu klik tombol Login.',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AbsenEaseTheme.magenta)),
          ),
        ],
      ),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan reset kata sandi dikirim ke email terdaftar.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AbsenEaseWordmark(
                    textColor: AbsenEaseTheme.navy,
                    fontSize: 16,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: AbsenEaseTheme.textDark,
                      size: 20,
                    ),
                    onPressed: _handleInfo,
                    tooltip: 'Informasi aplikasi',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Hero Carousel Card (placeholder jujur untuk foto tangan + ponsel)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  color: const Color(0xFF2A0815),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: [
                              AbsenEaseTheme.magenta.withOpacity(0.55),
                              const Color(0xFF16030B),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_android_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Foto Presensi Ponsel',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Carousel Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(false),
                  const SizedBox(width: 6),
                  _dot(true),
                  const SizedBox(width: 6),
                  _dot(false),
                ],
              ),
              const SizedBox(height: 20),
              // Headline
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AbsenEaseTheme.textDark,
                    height: 1.3,
                  ),
                  children: const [
                    TextSpan(text: 'Presensi '),
                    TextSpan(
                      text: 'kapan saja,\n',
                      style: TextStyle(color: AbsenEaseTheme.magenta),
                    ),
                    TextSpan(text: 'dan '),
                    TextSpan(
                      text: 'dimana saja',
                      style: TextStyle(color: AbsenEaseTheme.magenta),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dengan absen app presensi menjadi lebih mudah',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AbsenEaseTheme.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 24),
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: AbsenEaseTheme.textMuted,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AbsenEaseTheme.textMuted,
                    size: 19,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AbsenEaseTheme.textMuted,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Lupa Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lupa Password?',
                    style: GoogleFonts.inter(
                      color: AbsenEaseTheme.magenta,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Login pill
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AbsenEaseTheme.magenta : const Color(0xFFD1D5DB),
        shape: BoxShape.circle,
      ),
    );
  }
}
