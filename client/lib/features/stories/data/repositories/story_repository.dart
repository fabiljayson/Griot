import 'package:dio/dio.dart';
import '../models/story_model.dart';

class StoryRepository {
  final Dio _dio;

  StoryRepository({required Dio dio}) : _dio = dio;

  /// Get all published stories
  Future<List<StoryModel>> getStories({
    String? status,
    String? country,
    String? region,
    String? culture,
    int? categoryId,
    String? search,
    String? ordering,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (status != null) queryParams['status'] = status;
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (culture != null) queryParams['culture'] = culture;
      if (categoryId != null) queryParams['categories'] = categoryId;
      if (search != null) queryParams['search'] = search;
      if (ordering != null) queryParams['ordering'] = ordering;

      final response = await _dio.get('/stories/stories/', queryParameters: queryParams);
      final data = response.data;
      final List items = data is Map<String, dynamic> ? (data['results'] ?? []) : data;
      return items.map((e) => StoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single story by slug
  Future<StoryModel> getStory(String slug) async {
    try {
      final response = await _dio.get('/stories/stories/$slug/');
      return StoryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single story by ID
  Future<StoryModel> getStoryById(int id) async {
    try {
      final response = await _dio.get('/stories/stories/$id/');
      return StoryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Increment view count for a story
  Future<int> incrementView(String slug) async {
    try {
      final response = await _dio.post('/stories/stories/$slug/increment_view/');
      return response.data['view_count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Video Generation Methods ───

  /// Trigger AI video generation for a story
  Future<VideoGenerationResponse> generateVideo(
    String slug, {
    String aspectRatio = '16:9',
  }) async {
    try {
      final response = await _dio.post(
        '/stories/stories/$slug/generate-video/',
        data: {'aspect_ratio': aspectRatio},
      );
      return VideoGenerationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check video generation status for a story
  Future<VideoStatusResponse> getVideoStatus(String slug) async {
    try {
      final response = await _dio.get('/stories/stories/$slug/video-status/');
      return VideoStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset video generation status for a story
  Future<VideoStatusResponse> resetVideo(String slug) async {
    try {
      final response = await _dio.post('/stories/stories/$slug/reset-video/');
      return VideoStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }
    return Exception('An unexpected error occurred.');
  }
}

/// Response model for video generation trigger
class VideoGenerationResponse {
  final String message;
  final String generationId;
  final String status;

  VideoGenerationResponse({
    required this.message,
    required this.generationId,
    required this.status,
  });

  factory VideoGenerationResponse.fromJson(Map<String, dynamic> json) {
    return VideoGenerationResponse(
      message: json['message'] ?? '',
      generationId: json['generation_id'] ?? '',
      status: json['status'] ?? 'processing',
    );
  }
}

/// Response model for video status check
class VideoStatusResponse {
  final String status;
  final String? generationId;
  final String? videoUrl;
  final String? message;

  VideoStatusResponse({
    required this.status,
    this.generationId,
    this.videoUrl,
    this.message,
  });

  factory VideoStatusResponse.fromJson(Map<String, dynamic> json) {
    return VideoStatusResponse(
      status: json['status'] ?? 'idle',
      generationId: json['generation_id'],
      videoUrl: json['video_url'],
      message: json['message'],
    );
  }
}
