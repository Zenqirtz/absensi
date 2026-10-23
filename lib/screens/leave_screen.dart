import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/absentease_theme.dart';
import '../features/leave/services/leave_service.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _service = LeaveService();
  final _typeController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _reasonController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _leaves;

  @override
  void initState() {
    super.initState();
    _leaves = _service.getMyLeaves();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _startController.dispose();
    _endController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _leaves = _service.getMyLeaves());
    await _leaves;
  }

  Future<void> _submit() async {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(_startController.text.trim());
      final end = DateFormat('yyyy-MM-dd').parse(_endController.text.trim());
      await _service.submitLeave(
        type: _typeController.text.trim(),
        startDate: start,
        endDate: end,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );
      if (!mounted) return;
      await _reload();
      _typeController.clear();
      _startController.clear();
      _endController.clear();
      _reasonController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan izin dikirim')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Izin & Cuti'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _leaves,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final leaves = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _reload,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AbsenEaseTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Form Pengajuan Cuti',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              labelText: 'Tipe Izin'),
                          items: const [
                            DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                            DropdownMenuItem(value: 'annual', child: Text('Cuti Tahunan')),
                            DropdownMenuItem(value: 'emergency', child: Text('Darurat')),
                            DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                          ],
                          onChanged: (v) => _typeController.text = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _startController,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Mulai (YYYY-MM-DD)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _endController,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Akhir (YYYY-MM-DD)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Keterangan'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Kirim Pengajuan')),
                      ],
                    ),
                  ),
                  if (leaves.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Riwayat Izin',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    ...leaves.map((l) {
                      final type = l['type']?.toString() ?? '';
                      final typeLabel = {
                        'sick': 'Sakit',
                        'annual': 'Cuti Tahunan',
                        'emergency': 'Darurat',
                        'other': 'Lainnya',
                      }[type] ?? type;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AbsenEaseTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(typeLabel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                _statusBadge(l['status']?.toString() ?? 'pending'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${l['start_date']} s/d ${l['end_date']}'),
                            if (l['reason'] != null &&
                                l['reason'].toString().isNotEmpty)
                              Text('Keterangan: ${l['reason']}',
                                  style: const TextStyle(
                                      color: AbsenEaseTheme.textMuted)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'approved':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status == 'approved'
            ? 'Disetujui'
            : status == 'rejected'
                ? 'Ditolak'
                : 'Menunggu',
        style: TextStyle(
            color: fg, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
