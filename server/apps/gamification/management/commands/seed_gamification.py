"""
Seed gamification data: quizzes, questions, answers, and badges.

Usage:
    python manage.py seed_gamification
"""
from django.core.management.base import BaseCommand
from apps.stories.models import Story
from apps.gamification.models import Quiz, Question, Answer, Badge


class Command(BaseCommand):
    help = 'Seed sample quizzes, questions, answers, and badges for testing'

    def handle(self, *args, **options):
        self.stdout.write(self.style.MIGRATE_HEADING('Seeding gamification data...\n'))

        self._seed_badges()
        self._seed_quizzes()

        self.stdout.write(self.style.SUCCESS('\n[Done] Gamification data seeded successfully!'))

    def _seed_badges(self):
        badges_data = [
            # Quiz achievements
            {
                'name': 'First Quiz',
                'slug': 'first-quiz',
                'description': 'Complete your very first quiz. Every journey begins with a single step!',
                'icon': 'emoji_events',
                'category': 'QUIZ',
                'tier': 1,
                'points_required': 0,
                'color': '#DAA520',
            },
            {
                'name': 'Quiz Apprentice',
                'slug': 'quiz-5',
                'description': 'Complete 5 quizzes. You are building knowledge!',
                'icon': 'school',
                'category': 'QUIZ',
                'tier': 2,
                'points_required': 0,
                'color': '#CD7F32',
            },
            {
                'name': 'Quiz Scholar',
                'slug': 'quiz-10',
                'description': 'Complete 10 quizzes. Your dedication to learning is admirable.',
                'icon': 'auto_stories',
                'category': 'QUIZ',
                'tier': 3,
                'points_required': 0,
                'color': '#C85A32',
            },
            {
                'name': 'Quiz Master',
                'slug': 'quiz-25',
                'description': 'Complete 25 quizzes. You are a true scholar of African heritage!',
                'icon': 'military_tech',
                'category': 'QUIZ',
                'tier': 4,
                'points_required': 0,
                'color': '#2E5A44',
            },
            {
                'name': 'Perfect Score',
                'slug': 'perfect-score',
                'description': 'Achieve a perfect score on any quiz. Exceptional knowledge!',
                'icon': 'stars',
                'category': 'QUIZ',
                'tier': 2,
                'points_required': 0,
                'color': '#FFD700',
            },
            # Explorer badges
            {
                'name': 'Story Explorer',
                'slug': 'story-explorer',
                'description': 'Read your first story. Welcome to the archive!',
                'icon': 'explore',
                'category': 'EXPLORER',
                'tier': 1,
                'points_required': 0,
                'color': '#2E5A44',
            },
            {
                'name': 'Culture Seeker',
                'slug': 'culture-seeker',
                'description': 'Explore stories from 3 different cultures.',
                'icon': 'public',
                'category': 'EXPLORER',
                'tier': 2,
                'points_required': 0,
                'color': '#C85A32',
            },
            # Streak badges
            {
                'name': 'Daily Learner',
                'slug': 'daily-learner',
                'description': 'Log in 3 days in a row.',
                'icon': 'local_fire_department',
                'category': 'STREAK',
                'tier': 1,
                'points_required': 0,
                'color': '#FF6B35',
            },
            # Social badges
            {
                'name': 'QR Scanner',
                'slug': 'qr-scanner',
                'description': 'Scan your first museum QR code.',
                'icon': 'qr_code_scanner',
                'category': 'SOCIAL',
                'tier': 1,
                'points_required': 0,
                'color': '#2E5A44',
            },
            # Special badges
            {
                'name': 'Heritage Guardian',
                'slug': 'heritage-guardian',
                'description': 'Contribute your first story to the archive.',
                'icon': 'shield',
                'category': 'SPECIAL',
                'tier': 2,
                'points_required': 0,
                'color': '#C85A32',
            },
        ]

        for data in badges_data:
            badge, created = Badge.objects.get_or_create(
                slug=data['slug'],
                defaults=data,
            )
            status = self.style.SUCCESS('[Created]') if created else self.style.WARNING('[Exists]')
            self.stdout.write(f'  {status}: Badge "{badge.name}" (Tier {badge.tier})')

    def _seed_quizzes(self):
        stories = Story.objects.all()

        if not stories.exists():
            self.stdout.write(self.style.WARNING('  No stories found. Create stories first.'))
            return

        # Quiz 1: Anansi the Spider (or first story)
        story = stories.first()
        quiz_data = {
            'title': f'{story.title} - Knowledge Check',
            'description': f'Test your knowledge about {story.title}',
            'difficulty': 'EASY',
            'story': story,
            'time_limit_seconds': 120,
            'points_reward': 10,
        }

        quiz, created = Quiz.objects.get_or_create(
            title=quiz_data['title'],
            defaults=quiz_data,
        )

        if created:
            self.stdout.write(f'  {self.style.SUCCESS("[Created]")}: Quiz "{quiz.title}"')

            # Add questions
            questions_data = [
                {
                    'text': 'What type of content does African Teller primarily share?',
                    'order': 1,
                    'points': 1,
                    'hint': 'Think about cultural heritage.',
                    'answers': [
                        ('Modern news articles', False),
                        ('African cultural heritage stories', True),
                        ('Sports scores', False),
                        ('Weather forecasts', False),
                    ],
                },
                {
                    'text': 'Which of these is a key feature of the African Teller platform?',
                    'order': 2,
                    'points': 1,
                    'hint': 'It involves scanning something.',
                    'answers': [
                        ('QR code museum integration', True),
                        ('Social media posting', False),
                        ('Online shopping', False),
                        ('Email notifications', False),
                    ],
                },
                {
                    'text': 'What role can a new user register as?',
                    'order': 3,
                    'points': 1,
                    'hint': 'The default role for new accounts.',
                    'answers': [
                        ('Admin', False),
                        ('Manager', False),
                        ('Visitor', True),
                        ('Contributor', False),
                    ],
                },
                {
                    'text': 'What is the primary language family for stories on African Teller?',
                    'order': 4,
                    'points': 2,
                    'hint': 'The continent where the stories originate.',
                    'answers': [
                        ('European languages', False),
                        ('Asian languages', False),
                        ('African languages and traditions', True),
                        ('American languages', False),
                    ],
                },
                {
                    'text': 'How can users earn gamification points?',
                    'order': 5,
                    'points': 2,
                    'hint': 'It involves answering questions.',
                    'answers': [
                        ('By browsing silently', False),
                        ('By completing quizzes', True),
                        ('By deleting accounts', False),
                        ('By logging out', False),
                    ],
                },
            ]

            for q_data in questions_data:
                answers_data = q_data.pop('answers')
                question = Question.objects.create(quiz=quiz, **q_data)
                for i, (text, is_correct) in enumerate(answers_data):
                    Answer.objects.create(
                        question=question,
                        text=text,
                        is_correct=is_correct,
                        order=i + 1,
                    )
        else:
            self.stdout.write(f'  {self.style.WARNING("[Exists]")}: Quiz "{quiz.title}"')

        # Quiz 2: If there are more stories
        if stories.count() > 1:
            story2 = stories[1]
            quiz2_data = {
                'title': f'{story2.title} - Deep Dive',
                'description': f'Dive deeper into the world of {story2.title}',
                'difficulty': 'MEDIUM',
                'story': story2,
                'time_limit_seconds': 90,
                'points_reward': 15,
            }

            quiz2, created2 = Quiz.objects.get_or_create(
                title=quiz2_data['title'],
                defaults=quiz2_data,
            )

            if created2:
                self.stdout.write(f'  {self.style.SUCCESS("✓ Created")}: Quiz "{quiz2.title}"')

                medium_questions = [
                    {
                        'text': 'What is the purpose of the QR code feature in African Teller?',
                        'order': 1,
                        'points': 2,
                        'hint': 'It connects physical and digital.',
                        'answers': [
                            ('To link museum artifacts to digital stories', True),
                            ('To generate random codes', False),
                            ('To replace passwords', False),
                            ('To send messages', False),
                        ],
                    },
                    {
                        'text': 'Which Django framework is used for the API?',
                        'order': 2,
                        'points': 2,
                        'hint': 'It is abbreviated as DRF.',
                        'answers': [
                            ('Django REST Framework', True),
                            ('Flask', False),
                            ('Express.js', False),
                            ('FastAPI', False),
                        ],
                    },
                    {
                        'text': 'What authentication method does African Teller use?',
                        'order': 3,
                        'points': 2,
                        'hint': 'It uses tokens.',
                        'answers': [
                            ('JWT (JSON Web Tokens)', True),
                            ('Basic Auth only', False),
                            ('Cookie-based sessions', False),
                            ('OAuth with Google', False),
                        ],
                    },
                ]

                for q_data in medium_questions:
                    answers_data = q_data.pop('answers')
                    question = Question.objects.create(quiz=quiz2, **q_data)
                    for i, (text, is_correct) in enumerate(answers_data):
                        Answer.objects.create(
                            question=question,
                            text=text,
                            is_correct=is_correct,
                            order=i + 1,
                        )
            else:
                self.stdout.write(f'  {self.style.WARNING("→ Exists")}: Quiz "{quiz2.title}"')
