import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/absentease_theme.dart';
import '../features/admin/services/admin_attendance_service.dart';
import '../features/admin/services/admin_leave_service.dart';
import '../features/admin/services/admin_overtime_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _leaveService = AdminLeaveService();
  final _overtimeService = AdminOvertimeService();
  final _attendanceService = AdminAttendanceService();

  List<Map<String, dynamic>> _pendingLeaves = [];
  List<Map<String, dynamic>> _pendingOvertimes = [];
  List<Map<String, dynamic>> _todayAttendance = [];
  Map<String, dynamic> _summary = {'present': 0, 'total_employees': 0};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _isLoading = true);
    try {
      final leaves = await _leaveService.getPendingLeaves();
      final overtimes = await _overtimeService.getPendingOvertimes();
      final attendance = await _attendanceService.getTodayAllAttendance();
      final summary = await _attendanceService.getSummaryToday();

      if (mounted) {
        setState(() {
          _pendingLeaves = leaves;
          _pendingOvertimes = overtimes;
          _todayAttendance = attendance;
          _summary = summary;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleApproveLeave(String id) async {
    final success = await _leaveService.approveLeave(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin berhasil disetujui'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _loadAllAdminData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyetujui izin'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleRejectLeave(String id) async {
    final success = await _leaveService.rejectLeave(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin ditolak'),
          backgroundColor: Colors.redAccent,
        ),
      );
      _loadAllAdminData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menolak izin'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleApproveOvertime(String id) async {
    final success = await _overtimeService.approveOvertime(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembur disetujui'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _loadAllAdminData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyetujui lembur'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleRejectOvertime(String id) async {
    final success = await _overtimeService.rejectOvertime(id);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembur ditolak'),
          backgroundColor: Colors.redAccent,
        ),
      );
      _loadAllAdminData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menolak lembur'),
          backgroundColor: Colors.redAccent,
        ),
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
        title: const Text('Panel Administrator'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AbsenEaseTheme.magenta,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
          tabs: [
            Tab(
              text: 'Izin (${_pendingLeaves.length})',
              icon: const Icon(Icons.event_available_rounded, size: 18),
            ),
            Tab(
              text: 'Lembur (${_pendingOvertimes.length})',
              icon: const Icon(Icons.more_time_rounded, size: 18),
            ),
            const Tab(
              text: 'Presensi',
              icon: Icon(Icons.analytics_outlined, size: 18),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAllAdminData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaveTab(),
                  _buildOvertimeTab(),
                  _buildAttendanceTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildLeaveTab() {
    if (_pendingLeaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada pengajuan izin pending',
              style: GoogleFonts.inter(fontSize: 13, color: AbsenEaseTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingLeaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _pendingLeaves[i];
        final id = item['id'].toString();
        final emp = item['employees'] as Map<String, dynamic>?;
        final name = emp?['full_name']?.toString() ?? 'Karyawan';
        final dept = emp?['department']?.toString() ?? 'Staff';
        final type = item['type']?.toString() ?? 'Izin';
        final reason = item['reason']?.toString() ?? 'Tanpa alasan';
        final start = item['start_date']?.toString() ?? '';
        final end = item['end_date']?.toString() ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AbsenEaseTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AbsenEaseTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                dept,
                style: GoogleFonts.inter(fontSize: 11, color: AbsenEaseTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                'Periode: $start s/d $end',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Alasan: $reason',
                style: GoogleFonts.inter(fontSize: 11, color: AbsenEaseTheme.textDark),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _handleRejectLeave(id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleApproveLeave(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOvertimeTab() {
    if (_pendingOvertimes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada pengajuan lembur pending',
              style: GoogleFonts.inter(fontSize: 13, color: AbsenEaseTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingOvertimes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = _pendingOvertimes[i];
        final id = item['id'].toString();
        final emp = item['employees'] as Map<String, dynamic>?;
        final name = emp?['full_name']?.toString() ?? 'Karyawan';
        final date = item['date']?.toString() ?? '';
        final start = item['start_time']?.toString() ?? '';
        final end = item['end_time']?.toString() ?? '';
        final hours = item['hours']?.toString() ?? '0';
        final reason = item['reason']?.toString() ?? 'Tanpa alasan';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AbsenEaseTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AbsenEaseTheme.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$hours JAM',
                      style: const TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tanggal: $date ($start - $end)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Alasan: $reason',
                style: GoogleFonts.inter(fontSize: 11, color: AbsenEaseTheme.textDark),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _handleRejectOvertime(id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleApproveOvertime(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    final present = _summary['present'] ?? 0;
    final total = _summary['total_employees'] ?? 0;
    final notPresent = (total - present).clamp(0, 9999);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards Row
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Hadir Hari Ini',
                value: '$present',
                subtitle: 'Karyawan',
                color: const Color(0xFF10B981),
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'Belum Hadir',
                value: '$notPresent',
                subtitle: 'Karyawan',
                color: const Color(0xFFEF4444),
                icon: Icons.cancel_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Aktivitas Presensi Hari Ini (${_todayAttendance.length})',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AbsenEaseTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),

        if (_todayAttendance.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                'Belum ada aktivitas presensi hari ini',
                style: GoogleFonts.inter(fontSize: 12, color: AbsenEaseTheme.textMuted),
              ),
            ),
          )
        else
          ..._todayAttendance.map((rec) {
            final emp = rec['employees'] as Map<String, dynamic>?;
            final name = emp?['full_name']?.toString() ?? 'Karyawan';
            final type = rec['type'] == 'check_in' ? 'Absen Masuk' : 'Absen Pulang';
            final isCheckIn = rec['type'] == 'check_in';
            final timeStr = rec['check_time'] != null
                ? DateFormat('HH:mm WIB').format(DateTime.parse(rec['check_time']))
                : '-';
            final address = rec['address']?.toString() ?? 'Kantor Pusat';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AbsenEaseTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCheckIn
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    child: Icon(
                      isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                      color: isCheckIn ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$type • $timeStr',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isCheckIn ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AbsenEaseTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 11, color: AbsenEaseTheme.textMuted),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 10, color: AbsenEaseTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
