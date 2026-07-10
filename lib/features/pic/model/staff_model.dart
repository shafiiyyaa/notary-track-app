class StaffModel {
  final String id;
  final String name;
  final int jobCount;

  StaffModel({
    required this.id,
    required this.name,
    this.jobCount = 0,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      jobCount: (map['job_count'] as num?)?.toInt() ?? 0,
    );
  }
}