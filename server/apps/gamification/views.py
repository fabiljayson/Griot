from django.db.models import Sum
from django.utils import timezone
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model

from .models import Quiz, Question, Answer, UserScore, Badge, UserBadge
from .serializers import (
    QuizListSerializer,
    QuizDetailSerializer,
    QuizSubmitSerializer,
    UserScoreSerializer,
    BadgeSerializer,
    UserBadgeSerializer,
    QuestionPublicSerializer,
    AnswerPublicSerializer,
)
from apps.users.permissions import IsManagerOrAbove

User = get_user_model()


class QuizViewSet(viewsets.ModelViewSet):
    """
    CRUD for quizzes.
    Read: any authenticated user. Write: managers and above.
    """
    queryset = Quiz.objects.select_related('story').prefetch_related('questions__answers')
    serializer_class = QuizListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action in ['list']:
            return QuizListSerializer
        return QuizDetailSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        return [IsManagerOrAbove()]

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def submit(self, request, pk=None):
        """
        Submit answers for a quiz.
        Expects: { "answers": { "question_id": "answer_id", ... }, "time_taken_seconds": 60 }
        """
        quiz = self.get_object()
        serializer = QuizSubmitSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        answers_map = serializer.validated_data['answers']
        time_taken = serializer.validated_data.get('time_taken_seconds')

        # Check if user already completed this quiz
        existing = UserScore.objects.filter(user=request.user, quiz=quiz, completed=True).first()
        if existing:
            return Response(
                {'detail': 'You have already completed this quiz.', 'previous_score': UserScoreSerializer(existing).data},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Calculate score
        score = 0
        total_possible = 0
        correct_answers = {}

        for question in quiz.questions.all():
            total_possible += question.points
            answer_id = answers_map.get(str(question.id))
            if answer_id:
                try:
                    answer = Answer.objects.get(id=answer_id, question=question)
                    correct_answer = question.answers.filter(is_correct=True).first()
                    correct_answers[question.id] = {
                        'selected': answer_id,
                        'correct': answer.is_correct,
                        'correct_answer_id': correct_answer.id if correct_answer else None,
                    }
                    if answer.is_correct:
                        score += question.points
                except Answer.DoesNotExist:
                    pass

        # Create or update score
        user_score, created = UserScore.objects.update_or_create(
            user=request.user,
            quiz=quiz,
            defaults={
                'score': score,
                'total_possible': total_possible,
                'answers_submitted': answers_map,
                'time_taken_seconds': time_taken,
                'completed': True,
                'completed_at': timezone.now(),
            },
        )

        # Award points to user
        if score > 0:
            request.user.add_points(quiz.points_reward)

        # Check for badge eligibility
        self._check_badges(request.user)

        return Response({
            'score': score,
            'total_possible': total_possible,
            'percentage': user_score.percentage,
            'time_taken_seconds': time_taken,
            'points_awarded': quiz.points_reward if score > 0 else 0,
            'correct_answers': correct_answers,
            'message': self._score_message(user_score.percentage),
        })

    @action(detail=True, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def results(self, request, pk=None):
        """Get quiz results for the current user."""
        quiz = self.get_object()
        try:
            user_score = UserScore.objects.get(user=request.user, quiz=quiz)
            return Response(UserScoreSerializer(user_score).data)
        except UserScore.DoesNotExist:
            return Response({'detail': 'You have not taken this quiz yet.'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_scores(self, request):
        """Get all quiz scores for the current user."""
        scores = UserScore.objects.filter(user=request.user, completed=True).select_related('quiz')
        return Response(UserScoreSerializer(scores, many=True).data)

    @staticmethod
    def _score_message(percentage):
        if percentage >= 90:
            return 'Excellent! You are a true scholar!'
        elif percentage >= 70:
            return 'Great job! You know your heritage well!'
        elif percentage >= 50:
            return 'Good effort! Keep learning!'
        else:
            return 'Keep exploring! There is more to discover.'

    def _check_badges(self, user):
        """Check and award badges based on user activity."""
        scores = user.quiz_scores.filter(completed=True)
        total_quizzes = scores.count()
        total_points = scores.aggregate(total=Sum('score'))['total'] or 0

        # Quiz milestone badges
        milestones = {1: 'first-quiz', 5: 'quiz-5', 10: 'quiz-10', 25: 'quiz-25'}
        for count, slug in milestones.items():
            if total_quizzes >= count:
                self._award_badge(user, slug)

        # Perfect score badge
        perfect_scores = scores.filter(score=models.F('total_possible')).count()
        if perfect_scores >= 1:
            self._award_badge(user, 'perfect-score')

    def _award_badge(self, user, slug):
        """Award a badge to a user if not already earned."""
        try:
            badge = Badge.objects.get(slug=slug)
            UserBadge.objects.get_or_create(user=user, badge=badge)
        except Badge.DoesNotExist:
            pass


from django.db import models


class BadgeViewSet(viewsets.ModelViewSet):
    """
    CRUD for badges.
    Read: any authenticated user. Write: managers and above.
    """
    queryset = Badge.objects.all()
    serializer_class = BadgeSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'slug'

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        return [IsManagerOrAbove()]

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my_badges(self, request):
        """Get all badges earned by the current user."""
        user_badges = UserBadge.objects.filter(user=request.user).select_related('badge')
        return Response(UserBadgeSerializer(user_badges, many=True).data)

    @action(detail=True, methods=['post'], permission_classes=[IsManagerOrAbove])
    def award(self, request, slug=None):
        """Manually award a badge to a user."""
        badge = self.get_object()
        user_id = request.data.get('user_id')
        if not user_id:
            return Response({'detail': 'user_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        user_badge, created = UserBadge.objects.get_or_create(user=user, badge=badge)
        return Response({
            'message': f'Badge "{badge.name}" awarded to {user.username}',
            'created': created,
        }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)
