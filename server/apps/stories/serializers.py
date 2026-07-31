from rest_framework import serializers
from django.contrib.auth import get_user_model

from .models import Category, Story, MediaAsset, AIContent

User = get_user_model()


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Story categories."""
    story_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = [
            'id', 'name', 'slug', 'description', 'category_type',
            'icon', 'color', 'is_active', 'story_count',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_story_count(self, obj):
        return obj.stories.filter(status=Story.Status.PUBLISHED).count()


class MediaAssetSerializer(serializers.ModelSerializer):
    """Serializer for supplementary media assets."""

    class Meta:
        model = MediaAsset
        fields = [
            'id', 'story', 'asset_type', 'file', 'title',
            'description', 'order', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class AIContentSerializer(serializers.ModelSerializer):
    """Serializer for AI-generated content."""

    class Meta:
        model = AIContent
        fields = [
            'id', 'story', 'content_type', 'content', 'model_used',
            'is_verified', 'language', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class StoryListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for story list views."""
    author_name = serializers.CharField(source='author.get_full_name', read_only=True, default='')
    categories = CategorySerializer(many=True, read_only=True)
    has_audio = serializers.SerializerMethodField()

    class Meta:
        model = Story
        fields = [
            'id', 'title', 'slug', 'subtitle', 'summary',
            'author', 'author_name', 'categories',
            'country', 'region', 'culture',
            'cover_image', 'duration_seconds',
            'status', 'view_count',
            'has_audio', 'created_at', 'published_at',
        ]
        read_only_fields = ['id', 'view_count', 'created_at', 'published_at']

    def get_has_audio(self, obj):
        return bool(obj.audio_file)


class StoryDetailSerializer(serializers.ModelSerializer):
    """Full serializer for story detail views."""
    author_name = serializers.CharField(source='author.get_full_name', read_only=True, default='')
    categories = CategorySerializer(many=True, read_only=True)
    category_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Category.objects.all(),
        source='categories',
        write_only=True,
        required=False,
    )
    media_assets = MediaAssetSerializer(many=True, read_only=True)
    ai_content = AIContentSerializer(many=True, read_only=True)

    class Meta:
        model = Story
        fields = [
            'id', 'title', 'slug', 'subtitle', 'summary', 'content',
            'author', 'author_name', 'categories', 'category_ids',
            'country', 'region', 'culture', 'language_original',
            'cover_image', 'audio_file', 'video_file',
            'duration_seconds', 'status', 'view_count',
            'media_assets', 'ai_content',
            'created_at', 'updated_at', 'published_at',
        ]
        read_only_fields = ['id', 'view_count', 'created_at', 'updated_at', 'published_at']

    def create(self, validated_data):
        categories = validated_data.pop('categories', [])
        story = Story.objects.create(**validated_data)
        if categories:
            story.categories.set(categories)
        return story

    def update(self, instance, validated_data):
        categories = validated_data.pop('categories', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if categories is not None:
            instance.categories.set(categories)
        return instance
