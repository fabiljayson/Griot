import 'package:equatable/equatable.dart';

enum UserRole { visitor, contributor, manager, admin }

class UserModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? bio;
  final String? profilePicture;
  final String? country;
  final int points;
  final int level;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.bio,
    this.profilePicture,
    this.country,
    this.points = 0,
    this.level = 1,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: _parseRole(json['role']),
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      country: json['country'],
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'CONTRIBUTOR':
        return UserRole.contributor;
      case 'MANAGER':
        return UserRole.manager;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.visitor;
    }
  }

  String get roleString {
    switch (role) {
      case UserRole.visitor:
        return 'VISITOR';
      case UserRole.contributor:
        return 'CONTRIBUTOR';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  String get fullName => '$firstName $lastName';

  bool get isVisitor => role == UserRole.visitor;
  bool get isContributor => role == UserRole.contributor;
  bool get isManager => role == UserRole.manager;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        role,
        bio,
        profilePicture,
        country,
        points,
        level,
        createdAt,
      ];
}
