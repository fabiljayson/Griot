from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class Quiz(models.Model):
    """Quiz attached to a story for post-reading engagement."""

    class Difficulty(models.TextChoices):
        EASY = 'EASY', 'Easy'
        MEDIUM = 'MEDIUM', 'Medium'
        HARD = 'HARD', 'Hard'

    story = models.ForeignKey(
        'stories.Story',
        on_delete=models.CASCADE,
        related_name='quizzes',
    )
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    difficulty = models.CharField(
        max_length=10,
        choices=Difficulty.choices,
        default=Difficulty.EASY,
    )
    time_limit_seconds = models.PositiveIntegerField(
        default=120,
        help_text='Time limit in seconds (0 = no limit)',
    )
    points_reward = models.PositiveIntegerField(
        default=10,
        help_text='Points awarded for completing the quiz',
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Quiz'
        verbose_name_plural = 'Quizzes'
        ordering = ['created_at']

    def __str__(self):
        return f"{self.title} ({self.get_difficulty_display()})"

    @property
    def question_count(self):
        return self.questions.count()


class Question(models.Model):
    """A question within a quiz."""

    quiz = models.ForeignKey(
        Quiz,
        on_delete=models.CASCADE,
        related_name='questions',
    )
    text = models.TextField(help_text='The question text')
    order = models.PositiveIntegerField(default=0)
    points = models.PositiveIntegerField(
        default=1,
        help_text='Points for this question',
    )
    hint = models.CharField(max_length=300, blank=True)

    class Meta:
        verbose_name = 'Question'
        verbose_name_plural = 'Questions'
        ordering = ['order', 'id']

    def __str__(self):
        return f"Q{self.order}: {self.text[:60]}"


class Answer(models.Model):
    """An answer option for a question."""

    question = models.ForeignKey(
        Question,
        on_delete=models.CASCADE,
        related_name='answers',
    )
    text = models.CharField(max_length=300)
    is_correct = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)

    class Meta:
        verbose_name = 'Answer'
        verbose_name_plural = 'Answers'
        ordering = ['order', 'id']

    def __str__(self):
        marker = '✓' if self.is_correct else '✗'
        return f"[{marker}] {self.text[:50]}"


class UserScore(models.Model):
    """Tracks a user's quiz attempt and score."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='quiz_scores',
    )
    quiz = models.ForeignKey(
        Quiz,
        on_delete=models.CASCADE,
        related_name='user_scores',
    )
    score = models.PositiveIntegerField(default=0)
    total_possible = models.PositiveIntegerField(default=0)
    answers_submitted = models.JSONField(
        default=dict,
        help_text='JSON mapping question_id -> answer_id',
    )
    time_taken_seconds = models.PositiveIntegerField(
        null=True,
        blank=True,
        help_text='Time the user took to complete the quiz',
    )
    completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'User Score'
        verbose_name_plural = 'User Scores'
        ordering = ['-completed_at']
        unique_together = ['user', 'quiz']  # One attempt per user per quiz

    def __str__(self):
        return f"{self.user.username} - {self.quiz.title}: {self.score}/{self.total_possible}"

    @property
    def percentage(self):
        if self.total_possible == 0:
            return 0
        return round((self.score / self.total_possible) * 100, 1)


class Badge(models.Model):
    """Achievement badges users can earn."""

    class BadgeCategory(models.TextChoices):
        QUIZ = 'QUIZ', 'Quiz Achievement'
        STREAK = 'STREAK', 'Streak'
        EXPLORER = 'EXPLORER', 'Explorer'
        SOCIAL = 'SOCIAL', 'Social'
        SPECIAL = 'SPECIAL', 'Special'

    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=120, unique=True)
    description = models.TextField()
    icon = models.CharField(
        max_length=50,
        help_text='Material icon name or emoji',
    )
    category = models.CharField(
        max_length=20,
        choices=BadgeCategory.choices,
        default=BadgeCategory.QUIZ,
    )
    points_required = models.PositiveIntegerField(
        default=0,
        help_text='Points needed to unlock (0 = manual award only)',
    )
    tier = models.PositiveIntegerField(
        default=1,
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text='Badge tier (1-5, higher = harder to earn)',
    )
    color = models.CharField(
        max_length=7,
        default='#DAA520',
        help_text='Hex color for the badge',
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Badge'
        verbose_name_plural = 'Badges'
        ordering = ['category', 'tier']

    def __str__(self):
        return f"{self.name} (Tier {self.tier})"


class UserBadge(models.Model):
    """Tracks which badges a user has earned."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='badges',
    )
    badge = models.ForeignKey(
        Badge,
        on_delete=models.CASCADE,
        related_name='earned_by',
    )
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'User Badge'
        verbose_name_plural = 'User Badges'
        unique_together = ['user', 'badge']
        ordering = ['-earned_at']

    def __str__(self):
        return f"{self.user.username} earned {self.badge.name}"
