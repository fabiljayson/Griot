import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/story_model.dart';
import '../../data/repositories/story_repository.dart';

// ─── Events ───

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadStories extends StoryEvent {
  final String? status;
  final String? country;
  final String? region;
  final String? culture;
  final String? search;
  final int page;

  const LoadStories({
    this.status,
    this.country,
    this.region,
    this.culture,
    this.search,
    this.page = 1,
  });

  @override
  List<Object?> get props => [status, country, region, culture, search, page];
}

class LoadStory extends StoryEvent {
  final String slug;

  const LoadStory({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class GenerateVideo extends StoryEvent {
  final String slug;
  final String aspectRatio;

  const GenerateVideo({
    required this.slug,
    this.aspectRatio = '16:9',
  });

  @override
  List<Object?> get props => [slug, aspectRatio];
}

class CheckVideoStatus extends StoryEvent {
  final String slug;

  const CheckVideoStatus({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class ResetVideo extends StoryEvent {
  final String slug;

  const ResetVideo({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class IncrementView extends StoryEvent {
  final String slug;

  const IncrementView({required this.slug});

  @override
  List<Object?> get props => [slug];
}

// ─── States ───

abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoriesLoaded extends StoryState {
  final List<StoryModel> stories;
  final int currentPage;
  final bool hasMore;

  const StoriesLoaded({
    required this.stories,
    this.currentPage = 1,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [stories, currentPage, hasMore];
}

class StoryDetailLoaded extends StoryState {
  final StoryModel story;

  const StoryDetailLoaded({required this.story});

  @override
  List<Object?> get props => [story];
}

class VideoGenerating extends StoryState {
  final StoryModel story;

  const VideoGenerating({required this.story});

  @override
  List<Object?> get props => [story];
}

class VideoCompleted extends StoryState {
  final StoryModel story;

  const VideoCompleted({required this.story});

  @override
  List<Object?> get props => [story];
}

class VideoFailed extends StoryState {
  final StoryModel story;
  final String error;

  const VideoFailed({required this.story, required this.error});

  @override
  List<Object?> get props => [story, error];
}

class StoryError extends StoryState {
  final String message;

  const StoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ─── BLoC ───

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository _repository;

  StoryBloc({required StoryRepository repository})
      : _repository = repository,
        super(StoryInitial()) {
    on<LoadStories>(_onLoadStories);
    on<LoadStory>(_onLoadStory);
    on<GenerateVideo>(_onGenerateVideo);
    on<CheckVideoStatus>(_onCheckVideoStatus);
    on<ResetVideo>(_onResetVideo);
    on<IncrementView>(_onIncrementView);
  }

  Future<void> _onLoadStories(LoadStories event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final stories = await _repository.getStories(
        status: event.status,
        country: event.country,
        region: event.region,
        culture: event.culture,
        search: event.search,
        page: event.page,
      );
      emit(StoriesLoaded(
        stories: stories,
        currentPage: event.page,
        hasMore: stories.length >= 20,
      ));
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadStory(LoadStory event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final story = await _repository.getStory(event.slug);
      emit(StoryDetailLoaded(story: story));
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }

  Future<void> _onGenerateVideo(GenerateVideo event, Emitter<StoryState> emit) async {
    if (state is StoryDetailLoaded) {
      final currentStory = (state as StoryDetailLoaded).story;
      emit(VideoGenerating(story: currentStory));

      try {
        final response = await _repository.generateVideo(
          event.slug,
          aspectRatio: event.aspectRatio,
        );

        final updatedStory = currentStory.copyWith(
          videoGenerationId: response.generationId,
          videoStatus: VideoStatus.processing,
        );

        emit(VideoGenerating(story: updatedStory));
      } catch (e) {
        emit(VideoFailed(
          story: currentStory,
          error: e.toString().replaceFirst('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onCheckVideoStatus(CheckVideoStatus event, Emitter<StoryState> emit) async {
    try {
      final statusResponse = await _repository.getVideoStatus(event.slug);

      if (state is StoryDetailLoaded) {
        final currentStory = (state as StoryDetailLoaded).story;
        final newStatus = StoryModel._parseVideoStatus(statusResponse.status);

        final updatedStory = currentStory.copyWith(
          videoStatus: newStatus,
          videoUrl: statusResponse.videoUrl,
        );

        if (newStatus == VideoStatus.completed) {
          emit(VideoCompleted(story: updatedStory));
        } else if (newStatus == VideoStatus.failed) {
          emit(VideoFailed(story: updatedStory, error: 'Video generation failed'));
        } else {
          emit(StoryDetailLoaded(story: updatedStory));
        }
      }
    } catch (e) {
      // Silently handle status check failures to avoid disrupting UX
    }
  }

  Future<void> _onResetVideo(ResetVideo event, Emitter<StoryState> emit) async {
    try {
      await _repository.resetVideo(event.slug);

      if (state is StoryDetailLoaded) {
        final currentStory = (state as StoryDetailLoaded).story;
        final resetStory = currentStory.copyWith(
          videoGenerationId: null,
          videoStatus: VideoStatus.idle,
          videoUrl: null,
        );
        emit(StoryDetailLoaded(story: resetStory));
      }
    } catch (e) {
      emit(StoryError(message: e.toString()));
    }
  }

  Future<void> _onIncrementView(IncrementView event, Emitter<StoryState> emit) async {
    try {
      await _repository.incrementView(event.slug);

      if (state is StoryDetailLoaded) {
        final currentStory = (state as StoryDetailLoaded).story;
        final updatedStory = currentStory.copyWith(
          viewCount: currentStory.viewCount + 1,
        );
        emit(StoryDetailLoaded(story: updatedStory));
      }
    } catch (e) {
      // Silently handle view increment failures
    }
  }
}
