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
    path('search/', views.StorySearchView.as_view(), name='story-search'),
]
