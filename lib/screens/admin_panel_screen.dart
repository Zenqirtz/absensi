import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/absentease_theme.dart';
import '../features/admin/services/admin_attendance_service.dart';
import '../features/admin/services/admin_leave_service.dart';
import '../features/admin/services/admin_overtime_service.dart';
import '../features/admin/services/admin_staff_service.dart';
import '../features/admin/services/admin_article_service.dart';
import '../features/admin/services/admin_settings_service.dart';

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
  final _staffService = AdminStaffService();
  final _articleService = AdminArticleService();
  final _settingsService = AdminSettingsService();

  List<Map<String, dynamic>> _pendingLeaves = [];
  List<Map<String, dynamic>> _pendingOvertimes = [];
  List<Map<String, dynamic>> _todayAttendance = [];
  List<Map<String, dynamic>> _employees = [];
  Map<String, dynamic> _summary = {'present': 0, 'total_employees': 0};
  bool _isLoading = false;
  bool _settingsLoading = false;

  // settings form controllers
  final _workStartCtrl = TextEditingController(text: '08:00');
  final _lateThresholdCtrl = TextEditingController(text: '15');
  final _officLatCtrl = TextEditingController(text: '-6.2');
  final _officLngCtrl = TextEditingController(text: '106.816666');
  final _radiusCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLeaves();
    _loadOvertimes();
    _loadAttendance();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 3:
          _loadStaff();
          break;
        case 4:
          _loadSettings();
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _workStartCtrl.dispose();
    _lateThresholdCtrl.dispose();
    _officLatCtrl.dispose();
    _officLngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeaves() async {
    final leaves = await _leaveService.getPendingLeaves();
    if (mounted) setState(() => _pendingLeaves = leaves);
  }

  Future<void> _loadOvertimes() async {
    final ot = await _overtimeService.getPendingOvertimes();
    if (mounted) setState(() => _pendingOvertimes = ot);
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final att = await _attendanceService.getTodayAllAttendance();
    final sum = await _attendanceService.getSummaryToday();
    if (mounted) {
      setState(() {
        _todayAttendance = att;
        _summary = sum;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStaff() async {
    final staff = await _staffService.getAllEmployees();
    if (mounted) setState(() => _employees = staff);
  }

  Future<void> _loadSettings() async {
    setState(() => _settingsLoading = true);
    final s = await _settingsService.getSettings();
    if (mounted) {
      _workStartCtrl.text = s['work_start_time']?.toString() ?? '08:00';
      _lateThresholdCtrl.text =
          s['late_threshold_minutes']?.toString() ?? '15';
      _officLatCtrl.text = s['office_latitude']?.toString() ?? '-6.2';
      _officLngCtrl.text =
          s['office_longitude']?.toString() ?? '106.816666';
      _radiusCtrl.text = s['radius_meters']?.toString() ?? '100';
      setState(() {
        _settingsLoading = false;
      });
    }
  }

  // ──────────────── Approve/Reject Leave ────────────────
  Future<void> _approveLeave(String id) async {
    final ok = await _leaveService.approveLeave(id);
    _showResult(ok, 'Izin disetujui', 'Gagal menyetujui');
    if (ok) _loadLeaves();
  }

  Future<void> _rejectLeave(String id) async {
    final note = await _askNote('Alasan penolakan izin (opsional)');
    if (note == null) return;
    final ok = await _leaveService.rejectLeave(id, notes: note);
    _showResult(ok, 'Izin ditolak', 'Gagal menolak');
    if (ok) _loadLeaves();
  }

  // ──────────────── Approve/Reject Overtime ────────────────
  Future<void> _approveOvertime(String id) async {
    final ok = await _overtimeService.approveOvertime(id);
    _showResult(ok, 'Lembur disetujui', 'Gagal menyetujui');
    if (ok) _loadOvertimes();
  }

  Future<void> _rejectOvertime(String id) async {
    final note = await _askNote('Alasan penolakan lembur (opsional)');
    if (note == null) return;
    final ok = await _overtimeService.rejectOvertime(id, notes: note);
    _showResult(ok, 'Lembur ditolak', 'Gagal menolak');
    if (ok) _loadOvertimes();
  }

  // ──────────────── Settings save ────────────────
  Future<void> _saveSettings() async {
    final ok = await _settingsService.saveSettings(
      workStartTime: _workStartCtrl.text.trim(),
      lateThresholdMinutes:
          int.tryParse(_lateThresholdCtrl.text.trim()) ?? 15,
      officeLat: double.tryParse(_officLatCtrl.text.trim()) ?? -6.2,
      officeLng:
          double.tryParse(_officLngCtrl.text.trim()) ?? 106.816666,
      radiusMeters: int.tryParse(_radiusCtrl.text.trim()) ?? 100,
    );
    _showResult(ok, 'Pengaturan tersimpan', 'Gagal menyimpan');
  }

  // ──────────────── Helpers ────────────────
  void _showResult(bool ok, String successMsg, String failMsg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? successMsg : failMsg),
        backgroundColor: ok ? const Color(0xFF10B981) : Colors.redAccent,
      ),
    );
  }

  Future<String?> _askNote(String label) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Kosongkan jika tidak perlu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AbsenEaseTheme.magenta),
              child: const Text('Konfirmasi')),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  // ══════════════════════════════════════════════════════════
  //   BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbsenEaseTheme.canvas,
      appBar: AppBar(
        backgroundColor: AbsenEaseTheme.navy,
        foregroundColor: Colors.white,
        title: Text('Panel Administrator',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AbsenEaseTheme.magenta,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11),
          tabs: [
            Tab(
              text: 'Izin (${_pendingLeaves.length})',
              icon: const Icon(Icons.event_available_rounded, size: 16),
            ),
            Tab(
              text: 'Lembur (${_pendingOvertimes.length})',
              icon: const Icon(Icons.more_time_rounded, size: 16),
            ),
            const Tab(
              text: 'Presensi',
              icon: Icon(Icons.bar_chart_rounded, size: 16),
            ),
            const Tab(
              text: 'Karyawan',
              icon: Icon(Icons.people_rounded, size: 16),
            ),
            const Tab(
              text: 'Pengaturan',
              icon: Icon(Icons.settings_rounded, size: 16),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveTab(),
          _buildOvertimeTab(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadAttendance,
                  child: _buildAttendanceTab()),
          RefreshIndicator(
              onRefresh: _loadStaff, child: _buildStaffTab()),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   TAB 1 — Izin pending
  // ──────────────────────────────────────────────────────────
  Widget _buildLeaveTab() {
    if (_pendingLeaves.isEmpty) {
      return _emptyState(
          'Tidak ada pengajuan izin pending', Icons.check_circle_outline);
    }
    return RefreshIndicator(
      onRefresh: _loadLeaves,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingLeaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final item = _pendingLeaves[i];
          final id = item['id'].toString();
          final emp = item['employees'] as Map<String, dynamic>?;
          final name = emp?['full_name']?.toString() ?? 'Karyawan';
          final dept = emp?['department']?.toString() ?? '';
          final type = item['type']?.toString() ?? 'Izin';
          final reason = item['reason']?.toString() ?? '-';
          final start = item['start_date']?.toString() ?? '';
          final end = item['end_date']?.toString() ?? '';

          return _approvalCard(
            name: name,
            subtitle: dept,
            badge: type.toUpperCase(),
            badgeColor: const Color(0xFFFEF3C7),
            badgeTextColor: const Color(0xFFB45309),
            line1: 'Periode: $start s/d $end',
            line2: 'Alasan: $reason',
            onApprove: () => _approveLeave(id),
            onReject: () => _rejectLeave(id),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   TAB 2 — Lembur pending
  // ──────────────────────────────────────────────────────────
  Widget _buildOvertimeTab() {
    if (_pendingOvertimes.isEmpty) {
      return _emptyState(
          'Tidak ada pengajuan lembur pending', Icons.check_circle_outline);
    }
    return RefreshIndicator(
      onRefresh: _loadOvertimes,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingOvertimes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final item = _pendingOvertimes[i];
          final id = item['id'].toString();
          final emp = item['employees'] as Map<String, dynamic>?;
          final name = emp?['full_name']?.toString() ?? 'Karyawan';
          final date = item['date']?.toString() ?? '';
          final start = item['start_time']?.toString() ?? '';
          final end = item['end_time']?.toString() ?? '';
          final hours = item['hours']?.toString() ?? '0';
          final reason = item['reason']?.toString() ?? '-';

          return _approvalCard(
            name: name,
            subtitle: '',
            badge: '$hours JAM',
            badgeColor: const Color(0xFFEEF2FF),
            badgeTextColor: const Color(0xFF4338CA),
            line1: 'Tanggal: $date  ($start – $end)',
            line2: 'Alasan: $reason',
            onApprove: () => _approveOvertime(id),
            onReject: () => _rejectOvertime(id),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   TAB 3 — Presensi Hari Ini
  // ──────────────────────────────────────────────────────────
  Widget _buildAttendanceTab() {
    final present = _summary['present'] ?? 0;
    final late = _summary['late'] ?? 0;
    final leave = _summary['leave'] ?? 0;
    final alpha = _summary['alpha'] ?? 0;
    final total = _summary['total'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
            child: _summaryCard(
              title: 'Hadir',
              value: '$present',
              color: const Color(0xFF10B981),
              icon: Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              title: 'Telat',
              value: '$late',
              color: const Color(0xFFF97316),
              icon: Icons.schedule_rounded,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _summaryCard(
              title: 'Izin',
              value: '$leave',
              color: const Color(0xFF3B82F6),
              icon: Icons.event_available_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              title: 'Alpha',
              value: '$alpha',
              color: const Color(0xFFEF4444),
              icon: Icons.close_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryCard(
              title: 'Total',
              value: '$total',
              color: AbsenEaseTheme.navy,
              icon: Icons.group_outlined,
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Text(
          'Aktivitas Hari Ini (${_todayAttendance.length})',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AbsenEaseTheme.textDark),
        ),
        const SizedBox(height: 10),
        if (_todayAttendance.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('Belum ada aktivitas presensi hari ini',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AbsenEaseTheme.textMuted)),
            ),
          )
        else
          ..._todayAttendance.map(_attendanceRow),
      ],
    );
  }

  Widget _attendanceRow(Map<String, dynamic> rec) {
    final emp = rec['employees'] as Map<String, dynamic>?;
    final name = emp?['full_name']?.toString() ?? 'Karyawan';
    final dept = emp?['department']?.toString() ?? '';
    final isIn = rec['type'] == 'check_in';
    final label = isIn ? 'Absen Masuk' : 'Absen Pulang';
    final color = isIn ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final bgColor =
        isIn ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final timeStr = rec['check_time'] != null
        ? DateFormat('HH:mm').format(DateTime.parse(rec['check_time']))
        : '-';
    final lat = rec['latitude']?.toStringAsFixed(5) ?? '';
    final lng = rec['longitude']?.toStringAsFixed(5) ?? '';
    final loc = (lat.isNotEmpty && lng.isNotEmpty) ? '$lat, $lng' : 'Lokasi tidak tersedia';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: bgColor,
          child:
              Icon(isIn ? Icons.login_rounded : Icons.logout_rounded, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            if (dept.isNotEmpty)
              Text(dept,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AbsenEaseTheme.textMuted)),
            Text('$label • $timeStr',
                style: GoogleFonts.inter(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            Text(loc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 10, color: AbsenEaseTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   TAB 4 — Kelola Karyawan
  // ──────────────────────────────────────────────────────────
  Widget _buildStaffTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Expanded(
            child: Text('${_employees.length} karyawan',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AbsenEaseTheme.textMuted)),
          ),
          FilledButton.icon(
            onPressed: _showAddEmployeeSheet,
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Tambah'),
            style: FilledButton.styleFrom(
              backgroundColor: AbsenEaseTheme.magenta,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ]),
      ),
      if (_employees.isEmpty)
        Expanded(
          child: _emptyState('Belum ada karyawan', Icons.people_outline),
        )
      else
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _staffCard(_employees[i]),
          ),
        ),
    ]);
  }

  Widget _staffCard(Map<String, dynamic> emp) {
    final id = emp['id'].toString();
    final name = emp['full_name']?.toString() ?? 'Karyawan';
    final dept = emp['department']?.toString() ?? '-';
    final role = emp['role']?.toString() ?? 'Staff';
    final isActive = emp['is_active'] == true;
    final isAdmin = role.toLowerCase() == 'admin';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AbsenEaseTheme.navy.withAlpha(20),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: AbsenEaseTheme.navy,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AbsenEaseTheme.textDark)),
              Text(dept,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AbsenEaseTheme.textMuted)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'AKTIF' : 'NONAKTIF',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton.icon(
            onPressed: () => _showEditEmployeeSheet(emp),
            icon: const Icon(Icons.edit_rounded, size: 14),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AbsenEaseTheme.navy,
              side: BorderSide(color: AbsenEaseTheme.navy.withAlpha(60)),
              textStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _toggleRole(id, !isAdmin),
            icon: Icon(
                isAdmin ? Icons.person_remove_rounded : Icons.admin_panel_settings_rounded,
                size: 14),
            label: Text(isAdmin ? 'Jadikan Staff' : 'Jadikan Admin'),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  isAdmin ? Colors.orange : AbsenEaseTheme.magenta,
              side: BorderSide(
                  color: isAdmin
                      ? Colors.orange.withAlpha(100)
                      : AbsenEaseTheme.magenta.withAlpha(100)),
              textStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            ),
          ),
          const Spacer(),
          if (isActive)
            IconButton(
              onPressed: () => _deactivateEmployee(id),
              icon: const Icon(Icons.person_off_outlined, size: 18),
              color: Colors.redAccent,
              tooltip: 'Nonaktifkan',
              style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32)),
            ),
        ]),
      ]),
    );
  }

  Future<void> _toggleRole(String id, bool makeAdmin) async {
    final ok = await _staffService.toggleAdminRole(id, makeAdmin);
    _showResult(ok, makeAdmin ? 'Dijadikan Admin' : 'Dijadikan Staff',
        'Gagal mengubah role');
    if (ok) _loadStaff();
  }

  Future<void> _deactivateEmployee(String id) async {
    final confirm = await _confirm('Nonaktifkan karyawan ini?');
    if (!confirm) return;
    final ok = await _staffService.deactivateEmployee(id);
    _showResult(ok, 'Karyawan dinonaktifkan', 'Gagal menonaktifkan');
    if (ok) _loadStaff();
  }

  void _showAddEmployeeSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Tambah Karyawan',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 10),
              _sheetField(emailCtrl, 'Email', Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _sheetField(passCtrl, 'Password', Icons.lock_outline,
                  obscure: true),
              const SizedBox(height: 10),
              _sheetField(deptCtrl, 'Divisi (opsional)', Icons.business_outlined),
              const SizedBox(height: 10),
              _sheetField(phoneCtrl, 'Telepon (opsional)', Icons.phone_outlined,
                  type: TextInputType.phone),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setSt(() => saving = true);
                          final nav = Navigator.of(ctx);
                          final ok = await _staffService.addEmployee(
                            email: emailCtrl.text.trim(),
                            fullName: nameCtrl.text.trim(),
                            password: passCtrl.text,
                            department: deptCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pop();
                          _showResult(ok, 'Karyawan berhasil ditambahkan',
                              'Gagal menambahkan karyawan');
                          if (ok) _loadStaff();
                        },
                  style: FilledButton.styleFrom(
                      backgroundColor: AbsenEaseTheme.magenta),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan'),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  void _showEditEmployeeSheet(Map<String, dynamic> emp) {
    final id = emp['id'].toString();
    final nameCtrl =
        TextEditingController(text: emp['full_name']?.toString() ?? '');
    final deptCtrl =
        TextEditingController(text: emp['department']?.toString() ?? '');
    final phoneCtrl =
        TextEditingController(text: emp['phone']?.toString() ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Edit Karyawan',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 10),
              _sheetField(deptCtrl, 'Divisi', Icons.business_outlined),
              const SizedBox(height: 10),
              _sheetField(phoneCtrl, 'Telepon', Icons.phone_outlined,
                  type: TextInputType.phone),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setSt(() => saving = true);
                          final nav = Navigator.of(ctx);
                          final ok = await _staffService.updateEmployee(
                            id: id,
                            fullName: nameCtrl.text.trim(),
                            department: deptCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pop();
                          _showResult(ok, 'Data tersimpan', 'Gagal menyimpan');
                          if (ok) _loadStaff();
                        },
                  style: FilledButton.styleFrom(
                      backgroundColor: AbsenEaseTheme.magenta),
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan'),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   TAB 5 — Pengumuman & Pengaturan
  // ──────────────────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return _settingsLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Publikasi Artikel / Broadcast ──
              _sectionTitle('Publikasi Pengumuman & Artikel',
                  Icons.campaign_rounded),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _actionCard(
                    icon: Icons.article_rounded,
                    label: 'Tulis Artikel',
                    color: AbsenEaseTheme.navy,
                    onTap: _showWriteArticleSheet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    icon: Icons.send_rounded,
                    label: 'Broadcast Notif',
                    color: AbsenEaseTheme.magenta,
                    onTap: _showBroadcastSheet,
                  ),
                ),
              ]),
              const SizedBox(height: 28),

              // ── Jam Kerja ──
              _sectionTitle('Jam Kerja', Icons.schedule_rounded),
              const SizedBox(height: 12),
              _settingsCard(children: [
                _settingRow(
                  label: 'Jam Masuk',
                  hint: 'Contoh: 08:00',
                  ctrl: _workStartCtrl,
                  type: TextInputType.text,
                ),
                const Divider(height: 20),
                _settingRow(
                  label: 'Toleransi Telat (menit)',
                  hint: 'Contoh: 15',
                  ctrl: _lateThresholdCtrl,
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ]),
              const SizedBox(height: 20),

              // ── Lokasi Kantor ──
              _sectionTitle('Lokasi Kantor & Geofencing',
                  Icons.location_on_rounded),
              const SizedBox(height: 12),
              _settingsCard(children: [
                _settingRow(
                  label: 'Latitude',
                  hint: '-6.200000',
                  ctrl: _officLatCtrl,
                  type: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const Divider(height: 20),
                _settingRow(
                  label: 'Longitude',
                  hint: '106.816666',
                  ctrl: _officLngCtrl,
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
                const Divider(height: 20),
                _settingRow(
                  label: 'Radius (meter)',
                  hint: '100',
                  ctrl: _radiusCtrl,
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Simpan Pengaturan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AbsenEaseTheme.navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          );
  }

  void _showWriteArticleSheet() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Tulis Artikel',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _sheetField(titleCtrl, 'Judul Artikel', Icons.title_rounded),
              const SizedBox(height: 10),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Isi artikel...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          setSt(() => saving = true);
                          final nav = Navigator.of(ctx);
                          final ok = await _articleService.publishArticle(
                            title: titleCtrl.text.trim(),
                            content: contentCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pop();
                          _showResult(
                              ok, 'Artikel dipublikasikan', 'Gagal mempublikasikan');
                        },
                  icon: const Icon(Icons.publish_rounded, size: 18),
                  label: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Publikasikan'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AbsenEaseTheme.navy,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  void _showBroadcastSheet() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) {
          return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Broadcast Notifikasi',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _sheetField(titleCtrl, 'Judul Notifikasi', Icons.notifications_rounded),
              const SizedBox(height: 10),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Isi pesan...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          setSt(() => saving = true);
                          final nav = Navigator.of(ctx);
                          final ok = await _articleService.broadcastNotification(
                            title: titleCtrl.text.trim(),
                            body: bodyCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pop();
                          _showResult(ok, 'Notifikasi terkirim ke semua karyawan',
                              'Gagal mengirim');
                        },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Kirim ke Semua'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AbsenEaseTheme.magenta,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //   SHARED WIDGETS
  // ──────────────────────────────────────────────────────────

  Widget _approvalCard({
    required String name,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String line1,
    required String line2,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(name,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AbsenEaseTheme.textDark)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6)),
            child: Text(badge,
                style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AbsenEaseTheme.textMuted)),
        ],
        const SizedBox(height: 8),
        Text(line1,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(line2,
            style:
                GoogleFonts.inter(fontSize: 11, color: AbsenEaseTheme.textDark)),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            child: const Text('Tolak'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onApprove,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            child: const Text('Setujui'),
          ),
        ]),
      ]),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 9, color: AbsenEaseTheme.textMuted)),
          ),
          Icon(icon, color: color, size: 16),
        ]),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: const Color(0xFF10B981)),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.inter(fontSize: 13, color: AbsenEaseTheme.textMuted)),
      ]),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 18, color: AbsenEaseTheme.navy),
      const SizedBox(width: 8),
      Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AbsenEaseTheme.textDark)),
    ]);
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AbsenEaseTheme.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingRow({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Row(children: [
      SizedBox(
        width: 130,
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AbsenEaseTheme.textDark)),
      ),
      Expanded(
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          inputFormatters: inputFormatters,
          textAlign: TextAlign.end,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    ]);
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(message,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              child: const Text('Ya')),
        ],
      ),
    );
    return result ?? false;
  }
}
