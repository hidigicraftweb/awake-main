import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? photo;
  final String? photoUrl;
  final DateTime? emailVerifiedAt;
  final List<String> roles;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.photo,
    this.photoUrl,
    this.emailVerifiedAt,
    this.roles = const [],
    this.walletBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  bool get hasRole => roles.isNotEmpty;

  bool isRole(String role) => roles.contains(role);

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        gender,
        photo,
        photoUrl,
        emailVerifiedAt,
        roles,
        walletBalance,
        createdAt,
        updatedAt,
      ];
}

class AuthResult extends Equatable {
  final User user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

/// Returned when login credentials are valid but OTP verification is required
class LoginOtpRequired extends Equatable {
  final String email;
  final int expiresInMinutes;

  const LoginOtpRequired({
    required this.email,
    required this.expiresInMinutes,
  });

  @override
  List<Object?> get props => [email, expiresInMinutes];
}
