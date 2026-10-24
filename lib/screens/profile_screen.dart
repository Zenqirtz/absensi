import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/theme/absentease_theme.dart';
import '../features/employee/services/employee_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _employeeService = EmployeeService();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _avatarUrl;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = SupabaseConfig.clientOrNull?.auth.currentUser;
    _email = user?.email ?? '';

    // Ambil metadata auth sebagai default awal
    final metaName = user?.userMetadata?['full_name']?.toString() ?? '';
    final metaRole = user?.userMetadata?['role']?.toString() ?? '';
    final metaDept = user?.userMetadata?['department']?.toString() ?? '';
    final metaAvatar = user?.userMetadata?['avatar_url']?.toString() ?? '';

    _nameController.text = metaName;
    _roleController.text = metaRole.isNotEmpty ? metaRole : 'Staff';
    _departmentController.text = metaDept;
    _avatarUrl = metaAvatar;

    try {
      final profile = await _employeeService.getProfile();
      if (profile != null && mounted) {
        if ((profile['full_name']?.toString().isNotEmpty ?? false)) {
          _nameController.text = profile['full_name'];
        }
        if ((profile['role']?.toString().isNotEmpty ?? false)) {
          _roleController.text = profile['role'];
        }
        if ((profile['department']?.toString().isNotEmpty ?? false)) {
          _departmentController.text = profile['department'];
        }
        if ((profile['phone']?.toString().isNotEmpty ?? false)) {
          _phoneController.text = profile['phone'];
        }
        if ((profile['avatar_url']?.toString().isNotEmpty ?? false)) {
          _avatarUrl = profile['avatar_url'];
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final role = _roleController.text.trim();
    final department = _departmentController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // 1. Update auth user metadata
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': name,
            'role': role,
            'department': department,
            if (_avatarUrl != null) 'avatar_url': _avatarUrl,
          },
        ),
      );

      // 2. Update atau upsert baris tabel employees
      final uid = SupabaseConfig.client.auth.currentUser?.id;
      if (uid != null) {
        try {
          await SupabaseConfig.client.from('employees').upsert({
            'id': uid,
            'email': _email,
            'full_name': name,
            'role': role,
            'department': department,
            'phone': phone,
            'avatar_url': _avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _changeAvatar() {
    final controller = TextEditingController(text: _avatarUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tautan Foto Profil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/foto.jpg',
            labelText: 'URL Gambar',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _avatarUrl = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Gunakan'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Anda harus login kembali untuk mengakses presensi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await SupabaseConfig.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim().substring(0, _nameController.text.trim().length >= 2 ? 2 : 1).toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Profil Pengguna'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFE8D2C1),
                          backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty
                              ? Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AbsenEaseTheme.navy,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _changeAvatar,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AbsenEaseTheme.magenta,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AbsenEaseTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Kartu
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AbsenEaseTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Karyawan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AbsenEaseTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _roleController,
                          decoration: const InputDecoration(
                            labelText: 'Jabatan / Posisi',
                            hintText: 'Contoh: UI/UX Designer, Frontend Dev',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Divisi / Departemen',
                            hintText: 'Contoh: IT, Marketing, HR',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            hintText: '08123456789',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan Perubahan'),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Keluar
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFEE2E2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
