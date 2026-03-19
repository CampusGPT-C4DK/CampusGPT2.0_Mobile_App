class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? organization;
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.organization,
    this.profilePicture,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      organization: json['organization'],
      profilePicture: json['profile_picture'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'organization': organization,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
