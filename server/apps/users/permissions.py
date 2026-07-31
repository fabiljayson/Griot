from rest_framework import permissions
from django.contrib.auth import get_user_model

User = get_user_model()


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Custom permission to allow admins full access, others read-only.
    """
    
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return request.user and request.user.is_authenticated
        
        return request.user and request.user.is_authenticated and (
            request.user.role == User.Role.ADMIN or request.user.is_superuser
        )


class IsContributorOrAbove(permissions.BasePermission):
    """
    Custom permission for contributors, managers, and admins.
    """
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and (
            request.user.role in ['CONTRIBUTOR', 'MANAGER', 'ADMIN'] or
            request.user.is_superuser
        )


class IsManagerOrAbove(permissions.BasePermission):
    """
    Custom permission for managers and admins.
    """
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and (
            request.user.role in ['MANAGER', 'ADMIN'] or
            request.user.is_superuser
        )
