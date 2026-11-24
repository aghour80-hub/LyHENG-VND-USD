class AdminUser {
  final String id;
  final String userId;
  final String role;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.userId,
    required this.role,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'admin',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
