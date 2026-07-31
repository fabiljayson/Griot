from django.contrib import admin
from .models import Quiz, Question, Answer, UserScore, Badge, UserBadge


class AnswerInline(admin.TabularInline):
    model = Answer
    extra = 2
    fields = ('text', 'is_correct', 'order')


class QuestionInline(admin.StackedInline):
    model = Question
    extra = 1
    fields = ('text', 'order', 'points', 'hint')
    inlines = [AnswerInline]


@admin.register(Quiz)
class QuizAdmin(admin.ModelAdmin):
    list_display = (
        'title', 'story', 'difficulty', 'points_reward',
        'question_count', 'is_active', 'created_at',
    )
    list_filter = ('difficulty', 'is_active', 'created_at')
    search_fields = ('title', 'description')
    inlines = [QuestionInline]


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ('text', 'quiz', 'order', 'points')
    list_filter = ('quiz',)
    inlines = [AnswerInline]


@admin.register(Answer)
class AnswerAdmin(admin.ModelAdmin):
    list_display = ('text', 'question', 'is_correct', 'order')
    list_filter = ('is_correct',)


@admin.register(UserScore)
class UserScoreAdmin(admin.ModelAdmin):
    list_display = (
        'user', 'quiz', 'score', 'total_possible',
        'percentage', 'completed', 'completed_at',
    )
    list_filter = ('completed', 'created_at')
    search_fields = ('user__username', 'quiz__title')
    readonly_fields = ('answers_submitted', 'created_at')


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'tier', 'points_required', 'color', 'is_active')
    list_filter = ('category', 'tier', 'is_active')
    search_fields = ('name', 'description')
    prepopulated_fields = {'slug': ('name',)}


@admin.register(UserBadge)
class UserBadgeAdmin(admin.ModelAdmin):
    list_display = ('user', 'badge', 'earned_at')
    list_filter = ('badge__category', 'earned_at')
    search_fields = ('user__username', 'badge__name')
