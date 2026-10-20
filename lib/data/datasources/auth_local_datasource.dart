import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> cacheToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw CacheException(message: 'Failed to cache token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to read token: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      // Gracefully handle parsing errors
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
