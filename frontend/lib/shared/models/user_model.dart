import 'user_role.dart';

/// User identity representation for SAHAY-AI.
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String preferredLanguage;
  final String? activeCaseId;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.preferredLanguage = 'en',
    this.activeCaseId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'victim'),
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      activeCaseId: json['active_case_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'preferred_language': preferredLanguage,
      'active_case_id': activeCaseId,
    };
  }
}
