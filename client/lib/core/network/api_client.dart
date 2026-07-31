import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:8000/api';
  late Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            final prefs = await SharedPreferences.getInstance();
            final newToken = prefs.getString('access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await _dio.post('/token/refresh/', data: {
        'refresh': refreshToken,
      });
      
      if (response.statusCode == 200) {
        await prefs.setString('access_token', response.data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Dio get dio => _dio;
  
  // API methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}