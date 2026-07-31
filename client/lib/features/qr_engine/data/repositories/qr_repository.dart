import 'package:dio/dio.dart';
import '../models/qr_code_model.dart';

class QRRepository {
  final Dio _dio;

  QRRepository({required Dio dio}) : _dio = dio;

  /// Scan a QR code by its code value — returns the linked story data
  Future<QRScanResult> scanQRCode(String code) async {
    try {
      final response = await _dio.post('/qr/codes/scan/', data: {
        'code': code,
      });
      return QRScanResult.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// List all QR codes (requires authentication)
  Future<List<QRCodeModel>> listQRCodes() async {
    try {
      final response = await _dio.get('/qr/codes/');
      final data = response.data;
      final List items = data is Map<String, dynamic> ? (data['results'] ?? []) : data;
      return items.map((e) => QRCodeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get QR code stats (manager/admin only)
  Future<QRCodeStats> getStats() async {
    try {
      final response = await _dio.get('/qr/codes/stats/');
      return QRCodeStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get scan history for a specific QR code
  Future<Map<String, dynamic>> getScanHistory(int qrCodeId) async {
    try {
      final response = await _dio.get('/qr/codes/$qrCodeId/scans/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          message = data['detail'];
        } else if (data.containsKey('code')) {
          message = (data['code'] as List).join(', ');
        } else if (data.containsKey('non_field_errors')) {
          message = (data['non_field_errors'] as List).join(', ');
        }
      }
      return Exception(message);
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }
    return Exception('An unexpected error occurred.');
  }
}
