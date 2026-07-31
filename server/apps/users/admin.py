from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth import get_user_model

User = get_user_model()


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom admin for African Teller User model."""
    model = User

    list_display = (
        'username', 'email', 'first_name', 'last_name',
        'role', 'points', 'level', 'is_staff', 'is_active',
    )
    list_filter = ('role', 'is_staff', 'is_active', 'country')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('-created_at',)

    fieldsets = BaseUserAdmin.fieldsets + (
        ('African Teller Profile', {
            'fields': (
                'role', 'bio', 'profile_picture', 'country',
                'points', 'level',
            ),
        }),
    )

    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        ('African Teller Profile', {
            'fields': ('role', 'first_name', 'last_name', 'country'),
        }),
    )
