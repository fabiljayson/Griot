from django.urls import path
from . import views

app_name = 'web'

urlpatterns = [
    # Home
    path('', views.home_view, name='home'),
    
    # Authentication
    path('login/', views.LoginView.as_view(), name='login'),
    path('register/', views.RegisterView.as_view(), name='register'),
    path('logout/', views.logout_view, name='logout'),
    
    # Admin Dashboard
    path('admin-dashboard/', views.AdminDashboardView.as_view(), name='admin_dashboard'),
    
    # Stories
    path('stories/', views.stories_view, name='stories'),
    path('stories/<slug:slug>/', views.story_detail_view, name='story_detail'),
    
    # User
    path('profile/', views.profile_view, name='profile'),
    
    # About
    path('about/', views.about_view, name='about'),
]
