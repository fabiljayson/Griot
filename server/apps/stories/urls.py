from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

app_name = 'stories'

router = DefaultRouter()
router.register(r'categories', views.CategoryViewSet, basename='category')
router.register(r'stories', views.StoryViewSet, basename='story')
router.register(r'media', views.MediaAssetViewSet, basename='media')
router.register(r'ai-content', views.AIContentViewSet, basename='ai-content')

urlpatterns = [
    path('', include(router.urls)),
    path('stories/<int:pk>/generate-video/', views.VideoGenerationView.as_view(), name='generate-video'),
    path('stories/<int:pk>/video-status/', views.VideoStatusView.as_view(), name='video-status'),
    path('stories/<int:pk>/reset-video/', views.VideoResetView.as_view(), name='reset-video'),
]
