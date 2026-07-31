import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthRepository({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

  // Token keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  /// Login with username and password
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/api/users/token/', data: {
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
      final response = await _dio.post('/api/users/register/', data: {
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
      final response = await _dio.get('/api/users/profile/');
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

      final response = await _dio.patch('/api/users/profile/', data: data);
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
      await _dio.put('/api/users/change-password/', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<void> refreshAccessToken() async {
    final refreshToken = _prefs.getString(_refreshTokenKey);
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    // Use a separate Dio instance without interceptors to avoid circular refresh
    final refreshDio = Dio(BaseOptions(
      baseUrl: _dio.options.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    try {
      final response = await refreshDio.post('/api/users/token/refresh/', data: {
        'refresh': refreshToken,
      });

      final newAccessToken = response.data['access'];
      await _prefs.setString(_accessTokenKey, newAccessToken);
    } on DioException catch (e) {
      // If refresh fails, logout
      await logout();
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }

  /// Check if user is authenticated by checking if tokens exist
  Future<bool> isAuthenticated() async {
    final token = _prefs.getString(_accessTokenKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    return token != null && refreshToken != null;
  }

  /// Get cached user data
  Future<UserModel?> getCachedUser() async {
    final userId = _prefs.getInt('user_id');
    final username = _prefs.getString('user_username');
    final email = _prefs.getString('user_email');
    
    if (userId == null || username == null || email == null) {
      return null;
    }
    
    // Return a minimal user model from cache
    // Full profile will be fetched from API
    return UserModel(
      id: userId,
      username: username,
      email: email,
      firstName: _prefs.getString('user_first_name') ?? '',
      lastName: _prefs.getString('user_last_name') ?? '',
      role: UserRole.visitor, // Default, will be updated on refresh
      points: _prefs.getInt('user_points') ?? 0,
      level: _prefs.getInt('user_level') ?? 1,
      createdAt: DateTime.now(),
    );
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Save user data to cache
  Future<void> _saveUserData(UserModel user) async {
    await _prefs.setInt('user_id', user.id);
    await _prefs.setString('user_username', user.username);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_first_name', user.firstName);
    await _prefs.setString('user_last_name', user.lastName);
    await _prefs.setInt('user_points', user.points);
    await _prefs.setInt('user_level', user.level);
  }



  /// Handle Dio errors
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          message = data['detail'];
        } else if (data.containsKey('non_field_errors')) {
          message = (data['non_field_errors'] as List).join(', ');
        } else {
          // Field errors
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
