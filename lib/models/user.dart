class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'passenger', 'admin', or 'traveler'
  final bool verified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.verified,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'verified': verified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'],
      email: map['email'],
      role: map['role'] ?? 'passenger',
      verified: map['verified'] ?? false,
    );
  }
}