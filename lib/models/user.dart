class User {
  final int? id;
  final String name;
  final String role;

  User({
    this.id,
    required this.name,
    this.role = 'Karyawan',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      role: (map['role'] as String?) ?? 'Karyawan',
    );
  }
}
