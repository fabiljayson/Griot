from django.urls import path, include
from rest_framework.routers import DefaultRouter

from . import views

app_name = 'gamification'

router = DefaultRouter()
router.register(r'quizzes', views.QuizViewSet, basename='quiz')
router.register(r'badges', views.BadgeViewSet, basename='badge')

urlpatterns = [
    path('', include(router.urls)),
]
