/// User model matching the Next.js AuthUser type.
class User {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.name,
  });

  final String id;
  final String email;
  final String? name;
  final String role;
  final String status;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'status': status,
    };
  }

  bool get isAdmin => role == 'admin';

  String get displayName => name ?? email;
}
