import '../../core/network/api_endpoints.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.gender,
    super.photo,
    super.photoUrl,
    super.emailVerifiedAt,
    super.roles = const [],
    super.walletBalance = 0,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Construct full photo URL from relative path
    final photoUrlPath = json['photo_url'] as String?;
    final fullPhotoUrl = ApiEndpoints.getFullStorageUrl(photoUrlPath);

    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      photo: json['photo'] as String?,
      photoUrl: fullPhotoUrl,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'] as List)
          : const [],
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'photo': photo,
      'photo_url': photoUrl,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'roles': roles,
      'wallet_balance': walletBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      gender: user.gender,
      photo: user.photo,
      photoUrl: user.photoUrl,
      emailVerifiedAt: user.emailVerifiedAt,
      roles: user.roles,
      walletBalance: user.walletBalance,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}

class AuthResultModel {
  final UserModel user;
  final String token;

  const AuthResultModel({
    required this.user,
    required this.token,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  AuthResult toEntity() {
    return AuthResult(
      user: user,
      token: token,
    );
  }
}
