import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

/// Smart retry interceptor with exponential backoff
/// Retries on 502, 503, 504, and SocketException
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final List<int> retryableStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryableStatusCodes = const [502, 503, 504],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        // Increment retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Calculate delay with exponential backoff: 1s, 3s, 7s
        final delay = _calculateDelay(retryCount);
        
        print('Retry attempt ${retryCount + 1}/$maxRetries after ${delay.inSeconds}s');
        
        await Future.delayed(delay);
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, continue with original error
          if (e is DioException) {
            handler.next(e);
            return;
          }
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on specific status codes
    if (err.response?.statusCode != null &&
        retryableStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }
    
    // Retry on SocketException (network errors)
    if (err.error is SocketException) {
      return true;
    }
    
    // Retry on connection timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    
    return false;
  }

  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: 1s, 3s, 7s
    final delays = [
      const Duration(seconds: 1),
      const Duration(seconds: 3),
      const Duration(seconds: 7),
    ];
    
    return delays[retryCount.clamp(0, delays.length - 1)];
  }
}
