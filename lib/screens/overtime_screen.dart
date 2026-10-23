import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/absentease_theme.dart';
import '../features/overtime/services/overtime_service.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final _service = OvertimeService();
  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _hoursController = TextEditingController();
  final _reasonController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _overtimes;

  @override
  void initState() {
    super.initState();
    _overtimes = _service.getMyOvertimes();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _hoursController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _overtimes = _service.getMyOvertimes());
    await _overtimes;
  }

  Future<void> _submit() async {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(_dateController.text.trim());
      final hours = double.parse(_hoursController.text.trim());
      await _service.submitOvertime(
        date: date,
        startTime: _startController.text.trim(),
        endTime: _endController.text.trim(),
        hours: hours,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
      );
      if (!mounted) return;
      await _reload();
      _dateController.clear();
      _startController.clear();
      _endController.clear();
      _hoursController.clear();
      _reasonController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan lembur dikirim')),
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
        title: const Text('Lembur'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _overtimes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat lembur: ${snapshot.error}'));
          }
          final overtimes = snapshot.data ?? [];
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
                        const Text('Form Pengajuan Lembur',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal (YYYY-MM-DD)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _startController,
                          decoration: const InputDecoration(
                              labelText: 'Jam Mulai (HH:MM)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _endController,
                          decoration: const InputDecoration(
                              labelText: 'Jam Selesai (HH:MM)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Total Jam'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(labelText: 'Alasan'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Kirim Pengajuan'),
                        ),
                      ],
                    ),
                  ),
                  if (overtimes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Riwayat Lembur',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    ...overtimes.map((o) => Container(
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
                              Text(
                                  '${o['date']} - ${o['status']?.toString() ?? 'pending'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                  '${o['start_time']} s/d ${o['end_time']} (${o['hours']} jam)'),
                              if (o['reason'] != null &&
                                  o['reason'].toString().isNotEmpty)
                                Text('Alasan: ${o['reason']}',
                                    style: const TextStyle(
                                        color: AbsenEaseTheme.textMuted)),
                            ],
                          ),
                        ))
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Belum ada pengajuan lembur',
                          style: TextStyle(color: AbsenEaseTheme.textMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
