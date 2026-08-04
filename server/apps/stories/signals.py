"""
Django signals for automatic BlurHash generation on story cover image uploads.
"""
import logging
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.core.files.storage import default_storage
from PIL import Image
import io

try:
    import blurhash
except ImportError:
    blurhash = None

logger = logging.getLogger(__name__)


def generate_blurhash(image_file, x_components=6, y_components=5):
    """
    Generate a BlurHash string from an image file.
    
    Args:
        image_file: The image file object (Django FileField)
        x_components: Number of horizontal components (default: 6)
        y_components: Number of vertical components (default: 5)
    
    Returns:
        str: BlurHash string or None if generation fails
    """
    if blurhash is None:
        logger.warning("blurhash module not installed, skipping BlurHash generation")
        return None
    
    try:
        if not image_file:
            return None
            
        # Open the image
        image_file.open('rb')
        image = Image.open(image_file)
        
        # Resize for performance (BlurHash works best on smaller images)
        max_size = 100
        image.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        
        # Convert to RGB if necessary (handles RGBA, L, etc.)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Get image data as bytes
        img_bytes = io.BytesIO()
        image.save(img_bytes, format='JPEG', quality=85)
        img_bytes.seek(0)
        
        # Generate BlurHash
        hash_string = blurhash.encode(
            img_bytes,
            x_components=x_components,
            y_components=y_components
        )
        
        image_file.close()
        return hash_string
        
    except Exception as e:
        logger.error(f"Failed to generate BlurHash: {e}")
        return None


@receiver(pre_save, sender='stories.Story')
def generate_story_blurhash(sender, instance, **kwargs):
    """
    Auto-generate BlurHash when a story's cover image is uploaded or changed.
    """
    if not instance.cover_image:
        return
    
    # Check if this is a new image or the image has changed
    if not instance.pk:
        # New story - generate blurhash
        instance.blurhash = generate_blurhash(instance.cover_image)
    else:
        # Existing story - check if image changed
        try:
            old_story = sender.objects.get(pk=instance.pk)
            if old_story.cover_image != instance.cover_image:
                instance.blurhash = generate_blurhash(instance.cover_image)
        except sender.DoesNotExist:
            instance.blurhash = generate_blurhash(instance.cover_image)
