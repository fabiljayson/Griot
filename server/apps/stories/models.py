from django.db import models
from django.conf import settings
from django.core.validators import FileExtensionValidator


class Category(models.Model):
    """Story categories for organizing content by theme, region, or type."""
    
    class CategoryType(models.TextChoices):
        THEME = 'THEME', 'Theme'
        REGION = 'REGION', 'Region'
        COUNTRY = 'COUNTRY', 'Country'
        TYPE = 'TYPE', 'Story Type'
    
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=120, unique=True)
    description = models.TextField(blank=True)
    category_type = models.CharField(
        max_length=20,
        choices=CategoryType.choices,
        default=CategoryType.THEME,
    )
    icon = models.CharField(
        max_length=50,
        blank=True,
        help_text='Material icon name for the category',
    )
    color = models.CharField(
        max_length=7,
        default='#C85A32',
        help_text='Hex color code for the category',
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Category'
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.get_category_type_display()})"


class Story(models.Model):
    """Core story model — a piece of African cultural heritage content."""

    class Status(models.TextChoices):
        DRAFT = 'DRAFT', 'Draft'
        PUBLISHED = 'PUBLISHED', 'Published'
        ARCHIVED = 'ARCHIVED', 'Archived'

    class VideoStatus(models.TextChoices):
        IDLE = 'idle', 'Idle'
        PROCESSING = 'processing', 'Processing'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'

    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=220, unique=True)
    subtitle = models.CharField(max_length=300, blank=True)
    summary = models.TextField(
        max_length=500,
        help_text='Short summary for story cards',
    )
    content = models.TextField(
        help_text='Full story content (supports Markdown)',
    )
    
    # Relationships
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='authored_stories',
    )
    categories = models.ManyToManyField(
        Category,
        blank=True,
        related_name='stories',
    )
    
    # Geographic / cultural metadata
    country = models.CharField(max_length=100, blank=True)
    region = models.CharField(max_length=100, blank=True)
    culture = models.CharField(
        max_length=150,
        blank=True,
        help_text='Cultural group or tradition',
    )
    language_original = models.CharField(
        max_length=100,
        blank=True,
        help_text='Original language of the story',
    )
    
    # Media
    cover_image = models.ImageField(
        upload_to='stories/covers/',
        blank=True,
        null=True,
    )
    audio_file = models.FileField(
        upload_to='stories/audio/',
        blank=True,
        null=True,
        validators=[FileExtensionValidator(allowed_extensions=['mp3', 'wav', 'ogg', 'm4a'])],
        help_text='Audio narration of the story',
    )
    video_file = models.FileField(
        upload_to='stories/video/',
        blank=True,
        null=True,
        validators=[FileExtensionValidator(allowed_extensions=['mp4', 'webm', 'mov'])],
        help_text='Video content for the story',
    )
    
    # Luma AI Video Generation
    video_generation_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text='Luma AI generation ID for tracking video generation',
    )
    video_status = models.CharField(
        max_length=20,
        choices=VideoStatus.choices,
        default=VideoStatus.IDLE,
        help_text='Current status of AI video generation',
    )
    video_url = models.URLField(
        blank=True,
        null=True,
        help_text='URL of the generated AI video',
    )
    
    # Metadata
    duration_seconds = models.PositiveIntegerField(
        null=True,
        blank=True,
        help_text='Estimated reading/listening time in seconds',
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.DRAFT,
    )
    view_count = models.PositiveIntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    published_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        verbose_name = 'Story'
        verbose_name_plural = 'Stories'
        ordering = ['-created_at']

    def __str__(self):
        return self.title

    @property
    def is_published(self):
        return self.status == self.Status.PUBLISHED


class MediaAsset(models.Model):
    """Supplementary media files attached to stories."""

    class AssetType(models.TextChoices):
        IMAGE = 'IMAGE', 'Image'
        AUDIO = 'AUDIO', 'Audio'
        VIDEO = 'VIDEO', 'Video'
        DOCUMENT = 'DOCUMENT', 'Document'

    story = models.ForeignKey(
        Story,
        on_delete=models.CASCADE,
        related_name='media_assets',
    )
    asset_type = models.CharField(
        max_length=20,
        choices=AssetType.choices,
    )
    file = models.FileField(upload_to='stories/media/')
    title = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Media Asset'
        verbose_name_plural = 'Media Assets'
        ordering = ['order', 'created_at']

    def __str__(self):
        label = self.title or self.file.name
        return f"[{self.get_asset_type_display()}] {label}"


class AIContent(models.Model):
    """AI-generated or AI-enhanced content associated with a story."""

    class ContentType(models.TextChoices):
        SUMMARY = 'SUMMARY', 'AI Summary'
        TRANSLATION = 'TRANSLATION', 'AI Translation'
        QUIZ = 'QUIZ', 'AI Quiz'
        HISTORICAL_CONTEXT = 'HISTORICAL_CONTEXT', 'Historical Context'
        CULTURAL_NOTE = 'CULTURAL_NOTE', 'Cultural Note'

    story = models.ForeignKey(
        Story,
        on_delete=models.CASCADE,
        related_name='ai_content',
    )
    content_type = models.CharField(
        max_length=30,
        choices=ContentType.choices,
    )
    content = models.TextField(
        help_text='AI-generated content',
    )
    model_used = models.CharField(
        max_length=100,
        blank=True,
        help_text='Which AI model generated this content',
    )
    is_verified = models.BooleanField(
        default=False,
        help_text='Whether a human reviewer has verified this content',
    )
    language = models.CharField(
        max_length=10,
        default='en',
        help_text='ISO 639-1 language code',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'AI Content'
        verbose_name_plural = 'AI Content'
        ordering = ['content_type']
        unique_together = ['story', 'content_type', 'language']

    def __str__(self):
        return f"{self.get_content_type_display()} for {self.story.title}"
