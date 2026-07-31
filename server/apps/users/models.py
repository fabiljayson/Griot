from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """
    Custom User model for African Teller platform.
    Supports role-based access: Visitor, Contributor, Manager, Admin.
    """
    
    class Role(models.TextChoices):
        VISITOR = 'VISITOR', 'Visitor'
        CONTRIBUTOR = 'CONTRIBUTOR', 'Contributor'
        MANAGER = 'MANAGER', 'Manager'
        ADMIN = 'ADMIN', 'Admin'
    
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.VISITOR,
        help_text='User role for access control'
    )
    
    bio = models.TextField(
        max_length=500,
        blank=True,
        help_text='Short biography for contributors'
    )
    
    profile_picture = models.ImageField(
        upload_to='profile_pictures/',
        blank=True,
        null=True,
        help_text='User profile picture'
    )
    
    country = models.CharField(
        max_length=100,
        blank=True,
        help_text='User country of origin'
    )
    
    points = models.IntegerField(
        default=0,
        help_text='Gamification points earned'
    )
    
    level = models.IntegerField(
        default=1,
        help_text='User level based on points'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"
    
    @property
    def is_visitor(self):
        return self.role == self.Role.VISITOR
    
    @property
    def is_contributor(self):
        return self.role == self.Role.CONTRIBUTOR
    
    @property
    def is_manager(self):
        return self.role == self.Role.MANAGER
    
    @property
    def is_admin_user(self):
        return self.role == self.Role.ADMIN or self.is_superuser
    
    def add_points(self, points):
        """Add points and update level."""
        self.points += points
        # Level up every 100 points
        self.level = (self.points // 100) + 1
        self.save(update_fields=['points', 'level'])
