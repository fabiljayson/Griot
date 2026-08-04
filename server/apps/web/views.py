from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.views import View
from django.utils.decorators import method_decorator

from apps.stories.models import Story
from apps.users.models import User


def home_view(request):
    """Home page view."""
    featured_stories = Story.objects.filter(status='published')[:6]
    return render(request, 'pages/home.html', {
        'featured_stories': featured_stories,
    })


class LoginView(View):
    """Login page view."""
    
    def get(self, request):
        if request.user.is_authenticated:
            return redirect('web:home')
        return render(request, 'pages/login.html')
    
    def post(self, request):
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            messages.success(request, f'Welcome back, {user.first_name or user.username}!')
            
            # Redirect admin users to admin dashboard
            if hasattr(user, 'role') and user.role in ['ADMIN', 'MANAGER']:
                return redirect('web:admin_dashboard')
            return redirect('web:home')
        else:
            messages.error(request, 'Invalid username or password.')
            return render(request, 'pages/login.html')


class RegisterView(View):
    """Registration page view."""
    
    def get(self, request):
        if request.user.is_authenticated:
            return redirect('web:home')
        return render(request, 'pages/register.html')
    
    def post(self, request):
        username = request.POST.get('username')
        email = request.POST.get('email')
        first_name = request.POST.get('first_name')
        last_name = request.POST.get('last_name')
        password1 = request.POST.get('password1')
        password2 = request.POST.get('password2')
        
        # Validation
        if password1 != password2:
            messages.error(request, 'Passwords do not match.')
            return render(request, 'pages/register.html')
        
        if User.objects.filter(username=username).exists():
            messages.error(request, 'Username already taken.')
            return render(request, 'pages/register.html')
        
        if User.objects.filter(email=email).exists():
            messages.error(request, 'Email already registered.')
            return render(request, 'pages/register.html')
        
        # Create user
        try:
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password1,
                first_name=first_name,
                last_name=last_name,
            )
            login(request, user)
            messages.success(request, 'Account created successfully! Welcome to African Teller.')
            return redirect('web:home')
        except Exception as e:
            messages.error(request, f'Error creating account: {str(e)}')
            return render(request, 'pages/register.html')


def logout_view(request):
    """Logout view."""
    logout(request)
    messages.success(request, 'You have been logged out successfully.')
    return redirect('web:home')


@method_decorator(login_required(login_url='/login/'), name='dispatch')
class AdminDashboardView(View):
    """Admin dashboard view."""
    
    def get(self, request):
        # Check if user has admin/manager role
        if not hasattr(request.user, 'role') or request.user.role not in ['ADMIN', 'MANAGER']:
            messages.error(request, 'You do not have permission to access the admin dashboard.')
            return redirect('web:home')
        
        # Get stats
        total_stories = Story.objects.count()
        published_stories = Story.objects.filter(status='published').count()
        pending_stories = Story.objects.filter(status='pending').count()
        total_users = User.objects.count()
        
        context = {
            'total_stories': total_stories,
            'published_stories': published_stories,
            'pending_stories': pending_stories,
            'total_users': total_users,
            'active_users': f'{total_users:,}',
            'videos_generated': '156',
            'engagement_rate': '78%',
        }
        
        return render(request, 'pages/admin_dashboard.html', context)


def about_view(request):
    """About page view."""
    return render(request, 'pages/about.html')


def stories_view(request):
    """Stories listing page view."""
    stories = Story.objects.filter(status='published')
    return render(request, 'pages/stories.html', {
        'stories': stories,
    })


def story_detail_view(request, slug):
    """Story detail page view."""
    story = Story.objects.get(slug=slug, status='published')
    
    # Increment view count
    story.view_count += 1
    story.save(update_fields=['view_count'])
    
    return render(request, 'pages/story_detail.html', {
        'story': story,
    })


def profile_view(request):
    """User profile page view."""
    return render(request, 'pages/profile.html', {
        'user': request.user,
    })
