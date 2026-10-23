import 'package:flutter/material.dart';
import '../core/theme/absentease_theme.dart';
import '../features/attendance/services/attendance_service.dart';

/// Kalender Maret 2023 sesuai referensi:
/// - Header putih tanpa bar navy (X tutup + judul "Kalender").
/// - Navigasi bulan: chevron, nama bulan + tahun, chevron.
/// - Header hari: M S S R K J S (Minggu–Sabtu).
/// - Tanggal bulan lain abu-abu; tanggal aktif lingkaran penuh magenta.
/// Titik di bawah tanggal menandai ada presensi (check-in) pada hari itu.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(2023, 3);
  DateTime? _selected = DateTime(2023, 3, 17);

  final _attendanceService = AttendanceService();
  Set<DateTime> _daysWithAttendance = {};

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
      _loadAttendance();
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
      _loadAttendance();
    });
  }

  void _selectDate(int day) {
    setState(() {
      _selected = DateTime(_month.year, _month.month, day);
    });
  }

  Future<void> _loadAttendance() async {
    final days = await _attendanceService.getMonthlyAttendance(
      year: _month.year,
      month: _month.month,
    );
    if (!mounted) return;
    setState(() {
      _daysWithAttendance = days.map((d) {
        final dt = DateTime.parse(d['check_time'].toString());
        return DateTime(dt.year, dt.month, dt.day);
      }).toSet();
    });
  }

  bool _hasDot(DateTime day) {
    return _daysWithAttendance.any((d) => d == day);
  }

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _monthNames[_month.month - 1];
    final year = _month.year;
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = _daysInMonth(_month);
    // Minggu = awal baris: weekday 7 -> offset 0, senin 1 -> offset 1...
    final int startOffset = firstDay.weekday % 7;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header kalender
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black87, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Kalender',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Bulan sebelumnya',
                    onPressed: _prevMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
                  ),
                  Text(
                    '$monthName $year',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bulan berikutnya',
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Header hari: M S S R K J S
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _HeaderDay('M'),
                  _HeaderDay('S'),
                  _HeaderDay('S'),
                  _HeaderDay('R'),
                  _HeaderDay('K'),
                  _HeaderDay('J'),
                  _HeaderDay('S'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Grid tanggal 7 kolom
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < startOffset || index >= startOffset + daysInMonth) {
                    return Container();
                  }
                  final day = index - startOffset + 1;
                  final isSelected = _selected != null &&
                      _selected!.year == _month.year &&
                      _selected!.month == _month.month &&
                      _selected!.day == day;
                  final dayDate = DateTime(_month.year, _month.month, day);
                  final hasAttendance = _hasDot(dayDate);

                  return GestureDetector(
                    onTap: () => _selectDate(day),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AbsenEaseTheme.magenta : Colors.white,
                        shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (hasAttendance)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AbsenEaseTheme.magenta,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _HeaderDay extends StatelessWidget {
  final String label;
  const _HeaderDay(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }
}
