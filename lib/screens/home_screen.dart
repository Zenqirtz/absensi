import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/attendance_record.dart';
import '../widgets/anim.dart';
import 'attendance_screen.dart';
import 'user_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<AttendanceRecord> _records = [];
  bool _isLoading = true;
  bool _onlyToday = true;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadAttendances();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendances() async {
    setState(() => _isLoading = true);
    _refreshController.forward(from: 0);
    final records = _onlyToday
        ? await DatabaseHelper.instance.getTodayAttendances()
        : await DatabaseHelper.instance.getAttendances();

    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _photoWidget(AttendanceRecord record, {double size = 56}) {
    if (record.photoBytes != null) {
      return Image.memory(
        record.photoBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }

  void _showPhotoDialog(AttendanceRecord record) {
    showAnimatedDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  PulseIcon(
                    icon: Icons.person,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: 'photo_${record.id}',
                      child: _photoWidget(record, size: 200),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.login, 'Tipe', record.type),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Waktu',
                      _formatTimestamp(record.timestamp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Text('$label: ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isLoading ? 0.5 : 1,
                child: const Text(
                  'Presensi Kantor',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.people_outline, color: Colors.white),
                tooltip: 'Kelola Karyawan',
                onPressed: () {
                  Navigator.push(
                    context,
                    slideFadeRoute(const UserManagementScreen()),
                  );
                },
              ),
              IconButton(
                icon: AnimatedBuilder(
                  animation: _refreshController,
                  builder: (_, __) => Transform.rotate(
                    angle: _refreshController.value * 2 * 3.14159,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
                tooltip: 'Segarkan',
                onPressed: _loadAttendances,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedFadeSlide(
                          duration: const Duration(milliseconds: 700),
                          offset: const Offset(0, 0.25),
                          child: _buildStatCard(
                            'Masuk',
                            _records.where((r) => r.type == 'Masuk').length,
                            Icons.login,
                            Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedFadeSlide(
                          duration: const Duration(milliseconds: 700),
                          delay: const Duration(milliseconds: 120),
                          offset: const Offset(0, 0.25),
                          child: _buildStatCard(
                            'Pulang',
                            _records.where((r) => r.type == 'Pulang').length,
                            Icons.logout,
                            Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedFadeSlide(
                          duration: const Duration(milliseconds: 700),
                          delay: const Duration(milliseconds: 240),
                          offset: const Offset(0, 0.25),
                          child: _buildStatCard(
                            'Total',
                            _records.length,
                            Icons.people,
                            const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AnimatedFadeSlide(
                    duration: const Duration(milliseconds: 650),
                    delay: const Duration(milliseconds: 300),
                    offset: const Offset(0, 0.2),
                    child: Row(
                      children: [
                        _buildFilterChip('Hari Ini', Icons.today, true),
                        const SizedBox(width: 8),
                        _buildFilterChip('Semua Riwayat', Icons.history, false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_records.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      _onlyToday
                          ? 'Belum ada absensi hari ini'
                          : 'Belum ada data absensi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final record = _records[index];
                  final isMasuk = record.type == 'Masuk';

                  return AnimatedFadeSlide(
                    delay: Duration(milliseconds: 50 * (index.clamp(0, 10))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: GestureDetector(
                            onTap: () => _showPhotoDialog(record),
                            child: Hero(
                              tag: 'photo_${record.id}',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _photoWidget(record),
                              ),
                            ),
                          ),
                          title: Text(record.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(_formatTimestamp(record.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isMasuk ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(record.type, style: TextStyle(color: isMasuk ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w600, fontSize: 11)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _records.length,
              ),
            ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () async {
            final res = await Navigator.push(context, slideFadeRoute(const AttendanceScreen()));
            if (res == true) _loadAttendances();
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Presensi'),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isToday) {
    final selected = _onlyToday == isToday;
    return InkWell(
      onTap: () {
        setState(() => _onlyToday = isToday);
        _loadAttendances();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6366F1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          AnimatedCounter(value: value),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
