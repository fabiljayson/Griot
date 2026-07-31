from django.db import models
from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

from .models import Category, Story, MediaAsset, AIContent
from .serializers import (
    CategorySerializer,
    StoryListSerializer,
    StoryDetailSerializer,
    MediaAssetSerializer,
    AIContentSerializer,
)
from apps.users.permissions import IsContributorOrAbove, IsManagerOrAbove

User = get_user_model()


class IsAuthorOrReadOnly(permissions.BasePermission):
    """Allow only the author of a story (or managers/admins) to edit it."""

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        user = request.user
        return (
            obj.author == user
            or user.role in [User.Role.MANAGER, User.Role.ADMIN]
            or user.is_superuser
        )


class CategoryViewSet(viewsets.ModelViewSet):
    """
    CRUD for story categories.
    Read: any authenticated user. Write: contributors and above.
    """
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    lookup_field = 'slug'

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [IsContributorOrAbove()]

    def perform_destroy(self, instance):
        # Soft-delete: mark inactive instead of deleting
        instance.is_active = False
        instance.save()


class StoryViewSet(viewsets.ModelViewSet):
    """
    CRUD for stories.
    List / Retrieve: any user (published stories public, drafts visible to author).
    Create / Update / Delete: contributors and above.
    """
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    filterset_fields = ['status', 'country', 'region', 'culture', 'categories']
    search_fields = ['title', 'subtitle', 'summary', 'content']
    ordering_fields = ['created_at', 'published_at', 'view_count', 'title']
    lookup_field = 'slug'

    def get_queryset(self):
        qs = Story.objects.select_related('author').prefetch_related('categories', 'media_assets', 'ai_content')
        user = self.request.user

        if user.is_authenticated and user.role in [User.Role.MANAGER, User.Role.ADMIN]:
            return qs
        elif user.is_authenticated:
            return qs.filter(
                models.Q(status=Story.Status.PUBLISHED)
                | models.Q(author=user)
            )
        else:
            return qs.filter(status=Story.Status.PUBLISHED)

    def get_serializer_class(self):
        if self.action == 'list':
            return StoryListSerializer
        return StoryDetailSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [IsContributorOrAbove(), IsAuthorOrReadOnly()]

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def increment_view(self, request, slug=None):
        """Increment the view count for a story."""
        story = self.get_object()
        story.view_count += 1
        story.save(update_fields=['view_count'])
        return Response({'view_count': story.view_count})

    @action(detail=True, methods=['post'], permission_classes=[IsManagerOrAbove])
    def publish(self, request, slug=None):
        """Publish a draft story."""
        from django.utils import timezone
        story = self.get_object()
        story.status = Story.Status.PUBLISHED
        story.published_at = timezone.now()
        story.save(update_fields=['status', 'published_at'])
        return Response({'status': 'published', 'published_at': story.published_at})

    @action(detail=True, methods=['post'], permission_classes=[IsManagerOrAbove])
    def archive(self, request, slug=None):
        """Archive a story."""
        story = self.get_object()
        story.status = Story.Status.ARCHIVED
        story.save(update_fields=['status'])
        return Response({'status': 'archived'})

    # ─── Luma AI Video Generation Actions ───

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def generate_video(self, request, slug=None):
        """Trigger AI video generation for a story using Luma AI.

        POST /api/stories/stories/{slug}/generate-video/
        """
        story = self.get_object()

        # Check if video is already being generated
        if story.video_status == 'processing':
            return Response(
                {'error': 'Video generation is already in progress.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if user is the author or has manager/admin role
        if story.author and story.author != request.user:
            if not hasattr(request.user, 'role') or request.user.role not in ['MANAGER', 'ADMIN']:
                return Response(
                    {'error': 'You do not have permission to generate video for this story.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        try:
            from .services.luma_service import get_luma_service
            luma_service = get_luma_service()

            # Build prompt from story content
            prompt_text = self._build_video_prompt(story)

            # Trigger generation
            generation_id = luma_service.trigger_generation(
                prompt_text=prompt_text,
                aspect_ratio=request.data.get('aspect_ratio', '16:9'),
            )

            # Update story with generation info
            story.video_generation_id = generation_id
            story.video_status = 'processing'
            story.save(update_fields=['video_generation_id', 'video_status'])

            return Response({
                'message': 'Video generation started successfully.',
                'generation_id': generation_id,
                'status': 'processing',
            }, status=status.HTTP_202_ACCEPTED)

        except ImportError:
            return Response(
                {'error': 'Video generation service is not available. Please install lumaai package.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        except Exception as e:
            return Response(
                {'error': f'Failed to start video generation: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=True, methods=['get'], permission_classes=[permissions.IsAuthenticatedOrReadOnly])
    def video_status(self, request, slug=None):
        """Check the status of a video generation job.

        GET /api/stories/stories/{slug}/video-status/
        """
        story = self.get_object()

        if not story.video_generation_id:
            return Response({
                'status': 'idle',
                'message': 'No video generation has been initiated for this story.',
            })

        # Check status if still processing
        if story.video_status == 'processing':
            try:
                from .services.luma_service import get_luma_service
                luma_service = get_luma_service()
                generation = luma_service.check_status(story.video_generation_id)

                # Update status based on Luma AI response
                if hasattr(generation, 'state'):
                    state = generation.state.lower()
                    if state == 'completed':
                        story.video_status = 'completed'
                        if generation.assets and generation.assets.video:
                            story.video_url = generation.assets.video
                        story.save(update_fields=['video_status', 'video_url'])
                    elif state == 'failed':
                        story.video_status = 'failed'
                        story.save(update_fields=['video_status'])

            except Exception as e:
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Failed to check video status: {e}")

        return Response({
            'status': story.video_status,
            'generation_id': story.video_generation_id,
            'video_url': story.video_url,
        })

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def reset_video(self, request, slug=None):
        """Reset video generation status for a story.

        POST /api/stories/stories/{slug}/reset-video/
        """
        story = self.get_object()

        # Check if user is the author or has manager/admin role
        if story.author and story.author != request.user:
            if not hasattr(request.user, 'role') or request.user.role not in ['MANAGER', 'ADMIN']:
                return Response(
                    {'error': 'You do not have permission to reset video for this story.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        # Reset video fields
        story.video_generation_id = None
        story.video_status = 'idle'
        story.video_url = None
        story.save(update_fields=['video_generation_id', 'video_status', 'video_url'])

        return Response({
            'message': 'Video generation status has been reset.',
            'status': 'idle',
        })

    def _build_video_prompt(self, story):
        """Build a cinematic prompt for video generation from story content."""
        prompt_parts = [
            f"Cinematic scene of {story.title},",
            f"{story.summary[:400] if story.summary else ''},",
            'hyper-realistic, African folklore visual style,',
        ]
        if story.culture:
            prompt_parts.append(f"{story.culture} cultural heritage,")
        prompt_parts.append('vibrant colors, traditional African architecture, cinematic lighting, 4K quality.')
        return ' '.join(prompt_parts)


class MediaAssetViewSet(viewsets.ModelViewSet):
    """
    CRUD for media assets attached to stories.
    Write access: contributors (own stories) and above.
    """
    serializer_class = MediaAssetSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        qs = MediaAsset.objects.select_related('story')
        story_id = self.request.query_params.get('story')
        if story_id:
            qs = qs.filter(story_id=story_id)
        return qs

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [IsContributorOrAbove()]

    def perform_create(self, serializer):
        serializer.save()


class AIContentViewSet(viewsets.ModelViewSet):
    """
    CRUD for AI-generated content.
    Write access: contributors and above.
    """
    serializer_class = AIContentSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        qs = AIContent.objects.select_related('story')
        story_id = self.request.query_params.get('story')
        if story_id:
            qs = qs.filter(story_id=story_id)
        return qs

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [IsContributorOrAbove()]


# ─── Luma AI Video Generation Views ───


class VideoGenerationView(APIView):
    """
    Trigger AI video generation for a story using Luma AI.

    POST /api/stories/stories/{id}/generate-video/
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        story = get_object_or_404(Story, pk=pk)

        # Check if video is already being generated
        if story.video_status == 'processing':
            return Response(
                {'error': 'Video generation is already in progress.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if user is the author or has manager/admin role
        if story.author and story.author != request.user:
            if not hasattr(request.user, 'role') or request.user.role not in ['MANAGER', 'ADMIN']:
                return Response(
                    {'error': 'You do not have permission to generate video for this story.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        try:
            from .services.luma_service import get_luma_service
            luma_service = get_luma_service()

            # Build prompt from story content
            prompt_text = self._build_prompt(story)

            # Trigger generation
            generation_id = luma_service.trigger_generation(
                prompt_text=prompt_text,
                aspect_ratio=request.data.get('aspect_ratio', '16:9'),
            )

            # Update story with generation info
            story.video_generation_id = generation_id
            story.video_status = 'processing'
            story.save(update_fields=['video_generation_id', 'video_status'])

            return Response({
                'message': 'Video generation started successfully.',
                'generation_id': generation_id,
                'status': 'processing',
            }, status=status.HTTP_202_ACCEPTED)

        except ImportError:
            return Response(
                {'error': 'Video generation service is not available. Please install lumaai package.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        except Exception as e:
            return Response(
                {'error': f'Failed to start video generation: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def _build_prompt(self, story):
        """Build a descriptive prompt for video generation from story content."""
        prompt_parts = [
            f"A cinematic visualization of the African cultural story: '{story.title}'.",
            story.summary[:500] if story.summary else "",
        ]

        if story.culture:
            prompt_parts.append(f"This story represents the {story.culture} cultural heritage of Africa.")

        prompt_parts.append("Beautiful African landscapes, traditional architecture, vibrant colors, cultural richness, cinematic lighting.")

        return " ".join(prompt_parts)


class VideoStatusView(APIView):
    """
    Check the status of a video generation job.

    GET /api/stories/stories/{id}/video-status/
    """
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get(self, request, pk):
        story = get_object_or_404(Story, pk=pk)

        if not story.video_generation_id:
            return Response({
                'status': 'idle',
                'message': 'No video generation has been initiated for this story.',
            })

        # Check status if still processing
        if story.video_status == 'processing':
            try:
                from .services.luma_service import get_luma_service
                luma_service = get_luma_service()
                generation = luma_service.check_status(story.video_generation_id)

                # Update status based on Luma AI response
                if hasattr(generation, 'state'):
                    state = generation.state.lower()
                    if state == 'completed':
                        story.video_status = 'completed'
                        # Get video URL
                        if hasattr(generation, 'assets') and generation.assets:
                            if hasattr(generation.assets, 'video') and generation.assets.video:
                                story.video_url = generation.assets.video
                        story.save(update_fields=['video_status', 'video_url'])
                    elif state == 'failed':
                        story.video_status = 'failed'
                        story.save(update_fields=['video_status'])

            except Exception as e:
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f"Failed to check video status: {e}")

        return Response({
            'status': story.video_status,
            'generation_id': story.video_generation_id,
            'video_url': story.video_url,
        })


class VideoResetView(APIView):
    """
    Reset video generation status for a story.

    POST /api/stories/stories/{id}/reset-video/
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        story = get_object_or_404(Story, pk=pk)

        # Check if user is the author or has manager/admin role
        if story.author and story.author != request.user:
            if not hasattr(request.user, 'role') or request.user.role not in ['MANAGER', 'ADMIN']:
                return Response(
                    {'error': 'You do not have permission to reset video for this story.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        # Reset video fields
        story.video_generation_id = None
        story.video_status = 'idle'
        story.video_url = None
        story.save(update_fields=['video_generation_id', 'video_status', 'video_url'])

        return Response({
            'message': 'Video generation status has been reset.',
            'status': 'idle',
        })
