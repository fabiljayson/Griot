from django.db.models import Sum
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model

from .models import QRCode, QRScanLog
from .serializers import (
    QRCodeSerializer,
    QRCodeScanSerializer,
    QRScanLogSerializer,
)
from apps.users.permissions import IsManagerOrAbove

User = get_user_model()


class QRCodeViewSet(viewsets.ModelViewSet):
    """
    CRUD for QR codes mapping museum artifacts to stories.
    Read: any authenticated user. Write: managers and above.
    """
    queryset = QRCode.objects.select_related('story', 'created_by')
    serializer_class = QRCodeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        return [IsManagerOrAbove()]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def scan(self, request):
        """
        Scan a QR code by its code value.
        Returns the linked story data and logs the scan.
        """
        serializer = QRCodeScanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        qr_code = QRCode.objects.select_related('story').get(
            code=serializer.validated_data['code']
        )

        # Increment scan count
        qr_code.scan_count += 1
        qr_code.save(update_fields=['scan_count'])

        # Log the scan
        QRScanLog.objects.create(
            qr_code=qr_code,
            user=request.user if request.user.is_authenticated else None,
            ip_address=self._get_client_ip(request),
            device_info=request.META.get('HTTP_USER_AGENT', '')[:200],
        )

        return Response({
            'qr_code': QRCodeSerializer(qr_code, context={'request': request}).data,
            'story_slug': qr_code.story.slug,
            'story_id': qr_code.story.id,
            'message': f'Artifact "{qr_code.artifact_name}" linked to story "{qr_code.story.title}"',
        })

    @action(detail=True, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def scans(self, request, pk=None):
        """Get scan history for a specific QR code."""
        qr_code = self.get_object()
        logs = qr_code.scan_logs.all()[:50]
        return Response({
            'qr_code': qr_code.code,
            'total_scans': qr_code.scan_count,
            'recent_scans': QRScanLogSerializer(logs, many=True).data,
        })

    @action(detail=False, methods=['get'], permission_classes=[IsManagerOrAbove])
    def stats(self, request):
        """Get overall QR code usage statistics."""
        total_qr = QRCode.objects.count()
        active_qr = QRCode.objects.filter(status='ACTIVE').count()
        total_scans = QRCode.objects.aggregate(total=Sum('scan_count'))['total'] or 0
        top_scanned = QRCode.objects.order_by('-scan_count')[:5]

        return Response({
            'total_qr_codes': total_qr,
            'active_qr_codes': active_qr,
            'total_scans': total_scans,
            'top_scanned': QRCodeSerializer(top_scanned, many=True, context={'request': request}).data,
        })

    @staticmethod
    def _get_client_ip(request):
        x_forwarded = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded:
            return x_forwarded.split(',')[0].strip()
        return request.META.get('REMOTE_ADDR')
