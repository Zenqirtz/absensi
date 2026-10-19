import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/absentease_theme.dart';

class OvertimeScreen extends StatelessWidget {
  const OvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        title: const Text('Lembur', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AbsenEaseTheme.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Form Pengajuan Lembur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Tanggal Lembur')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Jam Mulai - Selesai')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Alasan'), maxLines: 3),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Ajukan Lembur')),
          ]),
        ),
      ),
    );
  }
}
