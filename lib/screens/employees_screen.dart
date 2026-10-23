import 'package:flutter/material.dart';
import '../core/theme/absentease_theme.dart';
import '../features/employee/services/employee_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _service = EmployeeService();
  late Future<List<Map<String, dynamic>>> _employees;

  @override
  void initState() {
    super.initState();
    _employees = _service.getAllEmployees();
  }

  Future<void> _reload() async {
    setState(() => _employees = _service.getAllEmployees());
    await _employees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Daftar Karyawan'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _employees,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          final emps = snapshot.data ?? [];
          if (emps.isEmpty) {
            return const Center(child: Text('Belum ada data karyawan'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: emps.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AbsenEaseTheme.border),
              itemBuilder: (context, index) {
                final emp = emps[index];
                final name = emp['full_name']?.toString() ?? 'Tanpa Nama';
                final position = emp['position']?.toString() ?? '';
                final department = emp['department']?.toString() ?? '';
                final initials = name.isNotEmpty
                    ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                    : '?';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: AbsenEaseTheme.magenta.withAlpha(30),
                    child: Text(initials,
                        style: const TextStyle(
                            color: AbsenEaseTheme.magenta,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: Text('$position${department.isNotEmpty ? ' • $department' : ''}',
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
