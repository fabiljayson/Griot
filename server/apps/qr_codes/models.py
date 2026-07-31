from django.db import models
from django.conf import settings
from django.utils.crypto import get_random_string
from django.utils import timezone


class QRCode(models.Model):
    """QR code payload mapping physical museum artifacts to story IDs."""

    class Status(models.TextChoices):
        ACTIVE = 'ACTIVE', 'Active'
        INACTIVE = 'INACTIVE', 'Inactive'
        EXPIRED = 'EXPIRED', 'Expired'

    # Unique code that gets encoded into the QR image
    code = models.CharField(
        max_length=32,
        unique=True,
        db_index=True,
        help_text='Unique identifier encoded in the QR code',
    )

    # Artifact metadata
    artifact_name = models.CharField(
        max_length=200,
        help_text='Name of the physical museum artifact',
    )
    artifact_description = models.TextField(
        blank=True,
        help_text='Description of the artifact',
    )
    museum_location = models.CharField(
        max_length=200,
        blank=True,
        help_text='Location within the museum (e.g., Gallery A, Shelf 3)',
    )

    # Link to story
    story = models.ForeignKey(
        'stories.Story',
        on_delete=models.CASCADE,
        related_name='qr_codes',
        help_text='Story linked to this QR code',
    )

    # Optional media for the artifact
    artifact_image = models.ImageField(
        upload_to='qr_codes/artifacts/',
        blank=True,
        null=True,
    )

    # Status and tracking
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.ACTIVE,
    )
    scan_count = models.PositiveIntegerField(default=0)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_qr_codes',
    )

    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expires_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Optional expiration date for the QR code',
    )

    class Meta:
        verbose_name = 'QR Code'
        verbose_name_plural = 'QR Codes'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.code} -> {self.artifact_name}"

    def save(self, *args, **kwargs):
        if not self.code:
            self.code = self._generate_unique_code()
        super().save(*args, **kwargs)

    @staticmethod
    def _generate_unique_code():
        """Generate a unique code for the QR payload."""
        while True:
            code = get_random_string(length=16)
            if not QRCode.objects.filter(code=code).exists():
                return code

    @property
    def is_scannable(self):
        """Check if the QR code can currently be scanned."""
        if self.status != self.Status.ACTIVE:
            return False
        if self.expires_at and self.expires_at < timezone.now():
            return False
        return True


class QRScanLog(models.Model):
    """Log of QR code scans for analytics."""

    qr_code = models.ForeignKey(
        QRCode,
        on_delete=models.CASCADE,
        related_name='scan_logs',
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='qr_scans',
    )
    scanned_at = models.DateTimeField(auto_now_add=True)
    device_info = models.CharField(max_length=200, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)

    class Meta:
        verbose_name = 'QR Scan Log'
        verbose_name_plural = 'QR Scan Logs'
        ordering = ['-scanned_at']

    def __str__(self):
        return f"Scan {self.qr_code.code} at {self.scanned_at}"
