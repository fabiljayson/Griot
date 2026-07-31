from django.db import models
from rest_framework import viewsets, permissions, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.contrib.auth import get_user_model

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
