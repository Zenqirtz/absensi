import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/attendance_record.dart';
import '../models/user.dart';
import '../widgets/anim.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isProcessing = false;
  Uint8List? _previewBytes;

  List<User> _users = [];
  User? _selectedUser;
  String _attendanceType = 'Masuk';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _selectedUser = users.isNotEmpty ? users.first : null;
      });
    }
  }

  Future<void> _processAttendance() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih karyawan terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final file = result.files.single;
      final photoPath = file.path ?? '';
      final photoBytes = file.bytes;

      if (photoBytes == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      setState(() {
        _previewBytes = photoBytes;
      });

      final now = DateTime.now();
      final record = AttendanceRecord(
        userId: _selectedUser!.id!,
        userName: _selectedUser!.name,
        type: _attendanceType,
        timestamp: now.toIso8601String(),
        photoPath: photoPath,
        photoBytes: photoBytes,
      );

      await DatabaseHelper.instance.insertAttendance(record);

      if (!mounted) return;
      await _showSuccessDialog(record, now);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showSuccessDialog(AttendanceRecord record, DateTime now) async {
    await showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text(
              'Absensi Berhasil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record.photoBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  record.photoBytes!,
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              record.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: record.type == 'Masuk'
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Status: ${record.type}',
                style: TextStyle(
                  color: record.type == 'Masuk'
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Waktu: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Presensi Wajah',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _users.isEmpty
          ? const Center(
              child: Text(
                'Belum ada data karyawan.\nTambahkan karyawan di menu User.',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AnimatedFadeSlide(
                    duration: const Duration(milliseconds: 500),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<User>(
                              value: _selectedUser,
                              decoration: const InputDecoration(
                                labelText: 'Pilih Karyawan',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              items: _users.map((user) {
                                return DropdownMenuItem<User>(
                                  value: user,
                                  child: Text('${user.name} (${user.role})'),
                                );
                              }).toList(),
                              onChanged: _isProcessing
                                  ? null
                                  : (User? val) =>
                                      setState(() => _selectedUser = val),
                            ),
                            const SizedBox(height: 16),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'Masuk',
                                  label: Text('Masuk'),
                                  icon: Icon(Icons.login),
                                ),
                                ButtonSegment(
                                  value: 'Pulang',
                                  label: Text('Pulang'),
                                  icon: Icon(Icons.logout),
                                ),
                              ],
                              selected: {_attendanceType},
                              onSelectionChanged: _isProcessing
                                  ? null
                                  : (newSelection) => setState(
                                        () => _attendanceType =
                                            newSelection.first,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedFadeSlide(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 150),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 280),
                              painter: DashedBorderPainter(
                                color: Colors.white.withOpacity(0.15),
                                radius: 24,
                              ),
                            ),
                            if (_previewBytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.memory(
                                  _previewBytes!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PulseIcon(
                                    icon: Icons.camera_alt_outlined,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 52,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Ambil foto atau pilih gambar\nuntuk verifikasi presensi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedFadeSlide(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 250),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isProcessing ? null : _processAttendance,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt, color: Colors.white),
                          label: Text(
                            _isProcessing ? 'Memproses...' : 'Ambil Foto & Absen',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
