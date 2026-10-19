import 'package:flutter/material.dart';
import '../../core/theme/absentease_theme.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  final List<Map<String, String>> employees = const [
    {'name': 'John Doe', 'role': 'UI/UX Designer', 'status': 'Hadir'},
    {'name': 'Jane Smith', 'role': 'Product Manager', 'status': 'Hadir'},
    {'name': 'Alex Johnson', 'role': 'Frontend Dev', 'status': 'Izin'},
    {'name': 'Sarah Williams', 'role': 'Backend Dev', 'status': 'Hadir'},
    {'name': 'Michael Brown', 'role': 'QA Engineer', 'status': 'Alpha'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        title: const Text(
          'Daftar Karyawan',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final emp = employees[index];
          final isPresent = emp['status'] == 'Hadir';
          final isLeave = emp['status'] == 'Izin';

          Color badgeColor = isPresent
              ? AbsenEaseTheme.success
              : (isLeave ? AbsenEaseTheme.warning : Colors.red);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AbsenEaseTheme.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AbsenEaseTheme.navy,
                  foregroundColor: Colors.white,
                  child: Text(emp['name']!.substring(0, 2).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emp['name']!,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emp['role']!,
                        style: const TextStyle(color: AbsenEaseTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    emp['status']!,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
