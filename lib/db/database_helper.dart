import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static SharedPreferences? _prefs;

  DatabaseHelper._init();

  final Map<int, Uint8List> _photos = {};

  Uint8List? getPhoto(int? id) => id == null ? null : _photos[id];

  void setPhoto(int id, Uint8List bytes) => _photos[id] = bytes;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _ensureSeeded() async {
    final prefs = await _preferences;
    if (!prefs.containsKey('users')) {
      final initialUsers = [
        User(name: 'Budi Santoso', role: 'Staff IT'),
        User(name: 'Siti Aminah', role: 'Administrasi'),
        User(name: 'Rian Pratama', role: 'Marketing'),
        User(name: 'Dewi Lestari', role: 'Finance'),
      ];
      await _saveUsers(initialUsers);
    }
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await _preferences;
    await prefs.setString(
      'users',
      jsonEncode(users.map((u) => u.toMap()).toList()),
    );
  }

  Future<List<User>> _loadUsers() async {
    final prefs = await _preferences;
    final raw = prefs.getString('users');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => User.fromMap(j)).toList();
  }

  Future<void> _saveAttendances(List<AttendanceRecord> records) async {
    final prefs = await _preferences;
    await prefs.setString(
      'attendances',
      jsonEncode(
        records
            .map((r) => r.toMap()..['photo_bytes'] = null)
            .toList(),
      ),
    );
  }

  Future<List<AttendanceRecord>> _loadAttendances() async {
    final prefs = await _preferences;
    final raw = prefs.getString('attendances');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((j) => AttendanceRecord.fromMap(j))
        .toList();
  }

  Future<int> insertUser(User user) async {
    await _ensureSeeded();
    final users = await _loadUsers();
    final newId = users.isEmpty
        ? 1
        : users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    users.add(User(id: newId, name: user.name, role: user.role));
    await _saveUsers(users);
    return newId;
  }

  Future<List<User>> getUsers() async {
    await _ensureSeeded();
    final users = await _loadUsers();
    users.sort((a, b) => a.name.compareTo(b.name));
    return users;
  }

  Future<int> deleteUser(int id) async {
    final users = await _loadUsers();
    users.removeWhere((u) => u.id == id);
    await _saveUsers(users);
    return 1;
  }

  Future<int> insertAttendance(AttendanceRecord record) async {
    final records = await _loadAttendances();
    final newId = records.isEmpty
        ? 1
        : records.map((r) => r.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;

    records.insert(
      0,
      AttendanceRecord(
        id: newId,
        userId: record.userId,
        userName: record.userName,
        type: record.type,
        timestamp: record.timestamp,
        photoPath: record.photoPath,
        photoBytes: record.photoBytes,
      ),
    );

    if (record.photoBytes != null) {
      _photos[newId] = record.photoBytes!;
    }

    await _saveAttendances(records);
    return newId;
  }

  Future<List<AttendanceRecord>> getAttendances() async {
    final records = await _loadAttendances();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records.map((r) {
      final bytes = _photos[r.id];
      return bytes != null ? r.copyWith(photoBytes: bytes) : r;
    }).toList();
  }

  Future<List<AttendanceRecord>> getTodayAttendances() async {
    final now = DateTime.now();
    final prefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final records = await _loadAttendances();
    final today = records.where((r) => r.timestamp.startsWith(prefix)).toList();
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today.map((r) {
      final bytes = _photos[r.id];
      return bytes != null ? r.copyWith(photoBytes: bytes) : r;
    }).toList();
  }

  Future<int> deleteAttendance(int id) async {
    final records = await _loadAttendances();
    records.removeWhere((r) => r.id == id);
    _photos.remove(id);
    await _saveAttendances(records);
    return 1;
  }
}
