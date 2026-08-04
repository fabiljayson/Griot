import 'package:equatable/equatable.dart';

enum StoryStatus { draft, published, archived }

enum VideoStatus { idle, processing, completed, failed }

class StoryCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String categoryType;
  final String icon;
  final String color;
  final int storyCount;

  const StoryCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.categoryType = 'THEME',
    this.icon = '',
    this.color = '#C85A32',
    this.storyCount = 0,
  });

  factory StoryCategory.fromJson(Map<String, dynamic> json) {
    return StoryCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      categoryType: json['category_type'] ?? 'THEME',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#C85A32',
      storyCount: json['story_count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, slug];
}

class StoryModel extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String subtitle;
  final String summary;
  final String content;
  final int? authorId;
  final String authorName;
  final List<StoryCategory> categories;
  final String country;
  final String region;
  final String culture;
  final String languageOriginal;
  final String? coverImageUrl;
  final String? audioFileUrl;
  final String? videoFileUrl;
  final int? durationSeconds;
  final StoryStatus status;
  final int viewCount;
  final bool hasAudio;
  final bool hasVideo;

  // Luma AI Video Generation fields
  final String? videoGenerationId;
  final VideoStatus videoStatus;
  final String? videoUrl;

  final DateTime createdAt;
  final DateTime? publishedAt;

  const StoryModel({
    required this.id,
    required this.title,
    required this.slug,
    this.subtitle = '',
    this.summary = '',
    this.content = '',
    this.authorId,
    this.authorName = '',
    this.categories = const [],
    this.country = '',
    this.region = '',
    this.culture = '',
    this.languageOriginal = '',
    this.coverImageUrl,
    this.audioFileUrl,
    this.videoFileUrl,
    this.durationSeconds,
    this.status = StoryStatus.draft,
    this.viewCount = 0,
    this.hasAudio = false,
    this.hasVideo = false,
    this.videoGenerationId,
    this.videoStatus = VideoStatus.idle,
    this.videoUrl,
    required this.createdAt,
    this.publishedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      subtitle: json['subtitle'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      authorId: json['author'],
      authorName: json['author_name'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => StoryCategory.fromJson(c))
              .toList() ??
          [],
      country: json['country'] ?? '',
      region: json['region'] ?? '',
      culture: json['culture'] ?? '',
      languageOriginal: json['language_original'] ?? '',
      coverImageUrl: json['cover_image'],
      audioFileUrl: json['audio_file'],
      videoFileUrl: json['video_file'],
      durationSeconds: json['duration_seconds'],
      status: _parseStatus(json['status']),
      viewCount: json['view_count'] ?? 0,
      hasAudio: json['has_audio'] ?? false,
      hasVideo: json['has_video'] ?? false,
      videoGenerationId: json['video_generation_id'],
      videoStatus: _parseVideoStatus(json['video_status']),
      videoUrl: json['video_url'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
    );
  }

  static StoryStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PUBLISHED':
        return StoryStatus.published;
      case 'ARCHIVED':
        return StoryStatus.archived;
      default:
        return StoryStatus.draft;
    }
  }

  static VideoStatus _parseVideoStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'processing':
        return VideoStatus.processing;
      case 'completed':
        return VideoStatus.completed;
      case 'failed':
        return VideoStatus.failed;
      default:
        return VideoStatus.idle;
    }
  }

  String get videoStatusString {
    switch (videoStatus) {
      case VideoStatus.idle:
        return 'idle';
      case VideoStatus.processing:
        return 'processing';
      case VideoStatus.completed:
        return 'completed';
      case VideoStatus.failed:
        return 'failed';
    }
  }

  StoryModel copyWith({
    String? videoGenerationId,
    VideoStatus? videoStatus,
    String? videoUrl,
    int? viewCount,
  }) {
    return StoryModel(
      id: id,
      title: title,
      slug: slug,
      subtitle: subtitle,
      summary: summary,
      content: content,
      authorId: authorId,
      authorName: authorName,
      categories: categories,
      country: country,
      region: region,
      culture: culture,
      languageOriginal: languageOriginal,
      coverImageUrl: coverImageUrl,
      audioFileUrl: audioFileUrl,
      videoFileUrl: videoFileUrl,
      durationSeconds: durationSeconds,
      status: status,
      viewCount: viewCount ?? this.viewCount,
      hasAudio: hasAudio,
      hasVideo: hasVideo,
      videoGenerationId: videoGenerationId ?? this.videoGenerationId,
      videoStatus: videoStatus ?? this.videoStatus,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt,
      publishedAt: publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        videoStatus,
        videoUrl,
        videoGenerationId,
        viewCount,
      ];
}
