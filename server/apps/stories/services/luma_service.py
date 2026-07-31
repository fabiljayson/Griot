"""
Luma AI Video Generation Service.

This module wraps the lumaai SDK to provide video generation capabilities
for African Teller stories.
"""
import os
import logging
from typing import Optional
from django.conf import settings

logger = logging.getLogger(__name__)


class LumaVideoService:
    """Service class for interacting with Luma AI's Dream Machine API."""

    def __init__(self):
        """Initialize the Luma AI client with the API key from settings."""
        api_key = getattr(settings, 'LUMAAI_API_KEY', '')
        if not api_key:
            logger.warning("LUMAAI_API_KEY is not configured. Video generation will fail.")
        
        try:
            from lumaai import LumaAI
            self.client = LumaAI(auth=api_key)
        except ImportError:
            logger.error("lumaai package is not installed. Run: pip install lumaai")
            raise ImportError("lumaai package is required for video generation. Install it with: pip install lumaai")
        except Exception as e:
            logger.error(f"Failed to initialize LumaAI client: {e}")
            raise

    def trigger_generation(
        self, 
        prompt_text: str, 
        aspect_ratio: str = "16:9",
        model: str = "ray-2",
        loop: bool = False,
    ) -> Optional[str]:
        """
        Trigger a video generation job with Luma AI.
        
        Args:
            prompt_text: The text prompt for video generation.
            aspect_ratio: Aspect ratio for the video (e.g., "16:9", "9:16", "1:1").
            model: The Luma AI model to use (default: "ray-2").
            loop: Whether to create a looping video.
            
        Returns:
            The generation ID string if successful, None otherwise.
        """
        if not self.client:
            raise RuntimeError("LumaAI client is not initialized. Check LUMAAI_API_KEY.")

        try:
            creation = self.client.generations.create(
                prompt=prompt_text,
                model=model,
                aspect_ratio=aspect_ratio,
                loop=loop,
            )
            logger.info(f"Triggered video generation: {creation.id}")
            return creation.id
        except Exception as e:
            logger.error(f"Failed to trigger video generation: {e}")
            raise

    def check_status(self, generation_id: str):
        """
        Check the status of a video generation job.
        
        Args:
            generation_id: The ID of the generation to check.
            
        Returns:
            The generation object with status and asset information.
        """
        if not self.client:
            raise RuntimeError("LumaAI client is not initialized. Check LUMAAI_API_KEY.")

        try:
            generation = self.client.generations.get(id=generation_id)
            return generation
        except Exception as e:
            logger.error(f"Failed to check generation status: {e}")
            raise

    def get_video_url(self, generation_id: str) -> Optional[str]:
        """
        Get the video URL from a completed generation.
        
        Args:
            generation_id: The ID of the completed generation.
            
        Returns:
            The video URL string if available, None otherwise.
        """
        generation = self.check_status(generation_id)
        
        # Check if generation is completed and has assets
        if hasattr(generation, 'assets') and generation.assets:
            if hasattr(generation.assets, 'video') and generation.assets.video:
                return generation.assets.video
        
        return None


def get_luma_service() -> LumaVideoService:
    """Create and return a new LumaVideoService instance."""
    return LumaVideoService()
