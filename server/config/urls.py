"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # Web pages
    path('', include('apps.web.urls', namespace='web')),
    
    # API endpoints
    path('api/users/', include('apps.users.urls', namespace='users')),
    path('api/stories/', include('apps.stories.urls', namespace='stories')),
    path('api/qr/', include('apps.qr_codes.urls', namespace='qr_codes')),
    path('api/gamification/', include('apps.gamification.urls', namespace='gamification')),
    
    # Django admin
    path('django-admin/', admin.site.urls),
]

# Serve media files in development
if settings.DEBUG:
    import debug_toolbar
    urlpatterns += [
        path('__debug__/', include(debug_toolbar.urls)),
    ]
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
