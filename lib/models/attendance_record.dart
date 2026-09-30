import 'dart:typed_data';

class AttendanceRecord {
  final int? id;
  final int userId;
  final String userName;
  final String type;
  final String timestamp;
  final String photoPath;
  final Uint8List? photoBytes;

  AttendanceRecord({
    this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.timestamp,
    required this.photoPath,
    this.photoBytes,
  });

  AttendanceRecord copyWith({Uint8List? photoBytes}) {
    return AttendanceRecord(
      id: id,
      userId: userId,
      userName: userName,
      type: type,
      timestamp: timestamp,
      photoPath: photoPath,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type,
      'timestamp': timestamp,
      'photo_path': photoPath,
      'photo_bytes': photoBytes?.toList(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      userName: map['user_name'] as String,
      type: map['type'] as String,
      timestamp: map['timestamp'] as String,
      photoPath: map['photo_path'] as String,
      photoBytes: map['photo_bytes'] != null
          ? Uint8List.fromList(List<int>.from(map['photo_bytes'] as List))
          : null,
    );
  }
}
