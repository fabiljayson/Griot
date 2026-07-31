from rest_framework import serializers
from .models import QRCode, QRScanLog


class QRCodeSerializer(serializers.ModelSerializer):
    """Full serializer for QR code CRUD."""
    story_title = serializers.CharField(source='story.title', read_only=True)
    created_by_name = serializers.CharField(source='created_by.get_full_name', read_only=True, default='')
    is_scannable = serializers.BooleanField(read_only=True)
    payload_url = serializers.SerializerMethodField()

    class Meta:
        model = QRCode
        fields = [
            'id', 'code', 'artifact_name', 'artifact_description',
            'museum_location', 'story', 'story_title',
            'artifact_image', 'status', 'scan_count',
            'created_by', 'created_by_name', 'is_scannable',
            'payload_url', 'created_at', 'updated_at', 'expires_at',
        ]
        read_only_fields = ['id', 'code', 'scan_count', 'created_at', 'updated_at']

    def get_payload_url(self, obj):
        """Generate the URL that the QR code points to."""
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(f'/api/stories/stories/{obj.story.slug}/')
        return f'/api/stories/stories/{obj.story.slug}/'


class QRCodeScanSerializer(serializers.Serializer):
    """Serializer for scanning a QR code by its code value."""
    code = serializers.CharField(max_length=32)

    def validate_code(self, value):
        try:
            qr = QRCode.objects.select_related('story').get(code=value)
        except QRCode.DoesNotExist:
            raise serializers.ValidationError('Invalid QR code.')
        if not qr.is_scannable:
            raise serializers.ValidationError('This QR code is no longer active.')
        return value


class QRScanLogSerializer(serializers.ModelSerializer):
    """Serializer for QR scan logs."""
    qr_code_code = serializers.CharField(source='qr_code.code', read_only=True)
    artifact_name = serializers.CharField(source='qr_code.artifact_name', read_only=True)

    class Meta:
        model = QRScanLog
        fields = [
            'id', 'qr_code', 'qr_code_code', 'artifact_name',
            'user', 'scanned_at', 'device_info', 'ip_address',
        ]
        read_only_fields = ['id', 'scanned_at']
