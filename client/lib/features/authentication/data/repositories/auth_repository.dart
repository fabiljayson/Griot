import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({required Dio dio, required FlutterSecureStorage secureStorage})
      : _dio = dio,
        _secureStorage = secureStorage;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userUsernameKey = 'user_username';
  static const String _userEmailKey = 'user_email';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';
  static const String _userPointsKey = 'user_points';
  static const String _userLevelKey = 'user_level';

  /// Login with username and password
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/users/token/', data: {
        'username': username,
        'password': password,
      });

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      await _saveTokens(accessToken, refreshToken);

      // Get user profile
      final user = await getProfile();
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register a new user
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    String? bio,
    String? country,
  }) async {
    try {
      final response = await _dio.post('/users/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
        'bio': bio,
        'country': country,
      });

      final userData = response.data['user'];
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/users/profile/');
      final user = UserModel.fromJson(response.data);

      // Cache user data
      await _saveUserData(user);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (country != null) data['country'] = country;

      final response = await _dio.patch('/users/profile/', data: data);
      final user = UserModel.fromJson(response.data);

      await _saveUserData(user);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/users/change-password/', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _userUsernameKey);
    await _secureStorage.delete(key: _userEmailKey);
    await _secureStorage.delete(key: _userFirstNameKey);
    await _secureStorage.delete(key: _userLastNameKey);
    await _secureStorage.delete(key: _userPointsKey);
    await _secureStorage.delete(key: _userLevelKey);
  }

  /// Check if user is authenticated by checking if tokens exist
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    return token != null && refreshToken != null;
  }

  /// Get cached user data
  Future<UserModel?> getCachedUser() async {
    final userIdStr = await _secureStorage.read(key: _userIdKey);
    final username = await _secureStorage.read(key: _userUsernameKey);
    final email = await _secureStorage.read(key: _userEmailKey);

    if (userIdStr == null || username == null || email == null) {
      return null;
    }

    final userId = int.tryParse(userIdStr) ?? 0;

    return UserModel(
      id: userId,
      username: username,
      email: email,
      firstName: await _secureStorage.read(key: _userFirstNameKey) ?? '',
      lastName: await _secureStorage.read(key: _userLastNameKey) ?? '',
      role: UserRole.visitor,
      points: int.tryParse(await _secureStorage.read(key: _userPointsKey) ?? '0') ?? 0,
      level: int.tryParse(await _secureStorage.read(key: _userLevelKey) ?? '1') ?? 1,
      createdAt: DateTime(2000), // Sentinel: cached user, actual createdAt unknown
    );
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Save user data to secure storage
  Future<void> _saveUserData(UserModel user) async {
    await _secureStorage.write(key: _userIdKey, value: user.id.toString());
    await _secureStorage.write(key: _userUsernameKey, value: user.username);
    await _secureStorage.write(key: _userEmailKey, value: user.email);
    await _secureStorage.write(key: _userFirstNameKey, value: user.firstName);
    await _secureStorage.write(key: _userLastNameKey, value: user.lastName);
    await _secureStorage.write(key: _userPointsKey, value: user.points.toString());
    await _secureStorage.write(key: _userLevelKey, value: user.level.toString());
  }

  /// Handle Dio errors
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          message = data['detail'];
        } else if (data.containsKey('non_field_errors')) {
          message = (data['non_field_errors'] as List).join(', ');
        } else {
          final errors = <String>[];
          data.forEach((key, value) {
            if (value is List) {
              errors.add('$key: ${value.join(', ')}');
            }
          });
          if (errors.isNotEmpty) {
            message = errors.join('\n');
          }
        }
      }

      return Exception(message);
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your network.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }

    return Exception('An unexpected error occurred.');
  }
}
