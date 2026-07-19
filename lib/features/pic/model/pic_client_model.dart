class StaffModel {
  final String id;
  final String name;
  final String username;
  final int jobCount;

  StaffModel({
    required this.id,
    required this.name,
    required this.username,
    this.jobCount = 0,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      jobCount: (map['job_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClientModel {
  final String id;
  final String name;
  final String username;
  final int jobCount;

  ClientModel({
    required this.id,
    required this.name,
    required this.username,
    this.jobCount = 0,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      jobCount: (map['job_count'] as num?)?.toInt() ?? 0,
    );
  }
}