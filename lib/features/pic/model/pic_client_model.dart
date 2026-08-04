class StaffModel {
  final String id;
  final String name;
  final String username;
  final String password; // ⚡ DITAMBAHKAN
  final int jobCount;

  StaffModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password, // ⚡ DITAMBAHKAN
    this.jobCount = 0,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '', // ⚡ DITAMBAHKAN
      jobCount: (map['job_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClientModel {
  final String id;
  final String name;
  final String username;
  final String password; // ⚡ DITAMBAHKAN
  final int jobCount;

  ClientModel({
    required this.id,
    required this.name,
    required this.username,
    required this.password, // ⚡ DITAMBAHKAN
    this.jobCount = 0,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '', // ⚡ DITAMBAHKAN
      jobCount: (map['job_count'] as num?)?.toInt() ?? 0,
    );
  }
}