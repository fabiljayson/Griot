from django.contrib import admin
from .models import QRCode, QRScanLog


@admin.register(QRCode)
class QRCodeAdmin(admin.ModelAdmin):
    list_display = (
        'code', 'artifact_name', 'story', 'status',
        'scan_count', 'created_by', 'created_at',
    )
    list_filter = ('status', 'created_at')
    search_fields = ('code', 'artifact_name', 'artifact_description')
    readonly_fields = ('code', 'scan_count', 'created_at', 'updated_at')

    fieldsets = (
        ('QR Code', {
            'fields': ('code', 'status', 'expires_at'),
        }),
        ('Artifact Info', {
            'fields': ('artifact_name', 'artifact_description', 'museum_location', 'artifact_image'),
        }),
        ('Linked Story', {
            'fields': ('story',),
        }),
        ('Tracking', {
            'fields': ('created_by', 'scan_count', 'created_at', 'updated_at'),
        }),
    )


@admin.register(QRScanLog)
class QRScanLogAdmin(admin.ModelAdmin):
    list_display = ('qr_code', 'user', 'scanned_at', 'ip_address')
    list_filter = ('scanned_at',)
    readonly_fields = ('scanned_at',)
