from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

app_name = 'qr_codes'

router = DefaultRouter()
router.register(r'codes', views.QRCodeViewSet, basename='qrcode')

urlpatterns = [
    path('', include(router.urls)),
]
