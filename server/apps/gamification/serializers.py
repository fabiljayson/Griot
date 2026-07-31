from rest_framework import serializers
from django.contrib.auth import get_user_model

from .models import Quiz, Question, Answer, UserScore, Badge, UserBadge

User = get_user_model()


class AnswerSerializer(serializers.ModelSerializer):
    """Serializer for quiz answers — hides is_correct on list."""
    is_correct = serializers.BooleanField(write_only=True, default=False)

    class Meta:
        model = Answer
        fields = ['id', 'text', 'is_correct', 'order']
        read_only_fields = ['id']


class AnswerPublicSerializer(serializers.ModelSerializer):
    """Serializer for answers after submission (shows is_correct)."""
    class Meta:
        model = Answer
        fields = ['id', 'text', 'is_correct', 'order']


class QuestionSerializer(serializers.ModelSerializer):
    answers = AnswerSerializer(many=True, read_only=True)

    class Meta:
        model = Question
        fields = ['id', 'text', 'order', 'points', 'hint', 'answers']
        read_only_fields = ['id']


class QuestionPublicSerializer(serializers.ModelSerializer):
    """Question with answers (for after quiz completion)."""
    answers = AnswerPublicSerializer(many=True, read_only=True)

    class Meta:
        model = Question
        fields = ['id', 'text', 'order', 'points', 'hint', 'answers']


class QuizListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for quiz list views."""
    story_title = serializers.CharField(source='story.title', read_only=True)
    question_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Quiz
        fields = [
            'id', 'title', 'description', 'difficulty',
            'story', 'story_title', 'time_limit_seconds',
            'points_reward', 'question_count', 'is_active',
            'created_at',
        ]


class QuizDetailSerializer(serializers.ModelSerializer):
    """Full serializer with questions and answers."""
    story_title = serializers.CharField(source='story.title', read_only=True)
    questions = QuestionSerializer(many=True, read_only=True)
    question_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Quiz
        fields = [
            'id', 'title', 'description', 'difficulty',
            'story', 'story_title', 'time_limit_seconds',
            'points_reward', 'question_count', 'questions',
            'is_active', 'created_at', 'updated_at',
        ]


class QuizSubmitSerializer(serializers.Serializer):
    """Serializer for submitting quiz answers."""
    answers = serializers.DictField(
        child=serializers.IntegerField(),
        help_text='Mapping of question_id -> answer_id',
    )
    time_taken_seconds = serializers.IntegerField(required=False, default=None)

    def validate_answers(self, value):
        if not value:
            raise serializers.ValidationError('At least one answer is required.')
        return value


class UserScoreSerializer(serializers.ModelSerializer):
    """Serializer for user quiz scores."""
    quiz_title = serializers.CharField(source='quiz.title', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    percentage = serializers.FloatField(read_only=True)

    class Meta:
        model = UserScore
        fields = [
            'id', 'user', 'username', 'quiz', 'quiz_title',
            'score', 'total_possible', 'percentage',
            'time_taken_seconds', 'completed', 'completed_at',
            'created_at',
        ]
        read_only_fields = ['id', 'completed_at', 'created_at']


class BadgeSerializer(serializers.ModelSerializer):
    """Serializer for badges."""
    class Meta:
        model = Badge
        fields = [
            'id', 'name', 'slug', 'description', 'icon',
            'category', 'points_required', 'tier', 'color',
            'is_active', 'created_at',
        ]


class UserBadgeSerializer(serializers.ModelSerializer):
    """Serializer for user-earned badges."""
    badge_name = serializers.CharField(source='badge.name', read_only=True)
    badge_icon = serializers.CharField(source='badge.icon', read_only=True)
    badge_color = serializers.CharField(source='badge.color', read_only=True)
    badge_tier = serializers.IntegerField(source='badge.tier', read_only=True)

    class Meta:
        model = UserBadge
        fields = [
            'id', 'user', 'badge', 'badge_name', 'badge_icon',
            'badge_color', 'badge_tier', 'earned_at',
        ]


class UserProfileGamificationSerializer(serializers.ModelSerializer):
    """Serializer for gamification summary on user profile."""
    total_score = serializers.SerializerMethodField()
    quizzes_completed = serializers.SerializerMethodField()
    badges_count = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'points', 'level', 'total_score', 'quizzes_completed', 'badges_count']

    def get_total_score(self, obj):
        return obj.quiz_scores.filter(completed=True).aggregate(
            total=models.Sum('score')
        )['total'] or 0

    def get_quizzes_completed(self, obj):
        return obj.quiz_scores.filter(completed=True).count()

    def get_badges_count(self, obj):
        return obj.badges.count()


from django.db import models as db_models
