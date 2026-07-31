from django.contrib import admin
from .models import Category, Story, MediaAsset, AIContent


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'category_type', 'slug', 'is_active', 'created_at')
    list_filter = ('category_type', 'is_active')
    search_fields = ('name', 'description')
    prepopulated_fields = {'slug': ('name',)}


class MediaAssetInline(admin.TabularInline):
    model = MediaAsset
    extra = 0
    fields = ('asset_type', 'file', 'title', 'order')


class AIContentInline(admin.TabularInline):
    model = AIContent
    extra = 0
    fields = ('content_type', 'content', 'language', 'is_verified')


@admin.register(Story)
class StoryAdmin(admin.ModelAdmin):
    list_display = (
        'title', 'author', 'status', 'country', 'region',
        'view_count', 'created_at', 'published_at',
    )
    list_filter = ('status', 'country', 'region', 'created_at')
    search_fields = ('title', 'subtitle', 'summary', 'content')
    prepopulated_fields = {'slug': ('title',)}
    filter_horizontal = ('categories',)
    inlines = [MediaAssetInline, AIContentInline]
    readonly_fields = ('view_count', 'created_at', 'updated_at')

    fieldsets = (
        ('Content', {
            'fields': ('title', 'slug', 'subtitle', 'summary', 'content'),
        }),
        ('Author & Categories', {
            'fields': ('author', 'categories'),
        }),
        ('Geography & Culture', {
            'fields': ('country', 'region', 'culture', 'language_original'),
        }),
        ('Media', {
            'fields': ('cover_image', 'audio_file', 'video_file', 'duration_seconds'),
        }),
        ('Status & Metrics', {
            'fields': ('status', 'published_at', 'view_count', 'created_at', 'updated_at'),
        }),
    )


@admin.register(MediaAsset)
class MediaAssetAdmin(admin.ModelAdmin):
    list_display = ('title', 'story', 'asset_type', 'order', 'created_at')
    list_filter = ('asset_type',)


@admin.register(AIContent)
class AIContentAdmin(admin.ModelAdmin):
    list_display = ('story', 'content_type', 'language', 'is_verified', 'created_at')
    list_filter = ('content_type', 'language', 'is_verified')
