"""
Import cultural stories from JSON seed data into the Story model.

This command reads a JSON file containing cultural story data (scraped from
Discover Cameroon) and imports it into the African Teller database with proper
field mapping.

Field Mapping:
    - content_markdown -> Story.content
    - is_published (bool) -> Story.status (PUBLISHED/DRAFT)
    - category (string) -> Story.categories (M2M via Category)
    - historical_context -> AIContent (content_type='HISTORICAL_CONTEXT')
    - tags -> Story.culture (primary culture name)
    - source_url -> AIContent.cultural_note (preserved for reference)
    - hero_image_url -> skipped (requires actual file download)

Usage:
    python manage.py import_cultural_stories
    python manage.py import_cultural_stories --file path/to/file.json
    python manage.py import_cultural_stories --dry-run
    python manage.py import_cultural_stories --clear
    python manage.py import_cultural_stories --published
"""
import json
import os
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils.text import slugify
from django.utils import timezone
from apps.stories.models import Story, Category, AIContent


class Command(BaseCommand):
    help = 'Import cultural stories from JSON seed data into the Story model'

    def add_arguments(self, parser):
        parser.add_argument(
            '--file',
            type=str,
            default='server/seed_data/cameroon_cultural_stories.json',
            help='Path to the JSON file containing story data',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be imported without making changes',
        )
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Clear existing imported stories before importing',
        )
        parser.add_argument(
            '--published',
            action='store_true',
            help='Import stories as published (default: draft)',
        )

    def handle(self, *args, **options):
        file_path = options['file']
        dry_run = options['dry_run']
        clear = options['clear']
        force_published = options['published']

        self.stdout.write(self.style.MIGRATE_HEADING(
            'Importing cultural stories from JSON...\n'
        ))

        # Validate file exists
        if not os.path.exists(file_path):
            raise CommandError(f'File not found: {file_path}')

        # Load JSON data
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except json.JSONDecodeError as e:
            raise CommandError(f'Invalid JSON file: {e}')
        except UnicodeDecodeError as e:
            raise CommandError(f'Encoding error reading file: {e}')

        if not isinstance(data, list):
            raise CommandError('JSON file must contain an array of story objects')

        self.stdout.write(f'  Found {len(data)} stories to import\n')

        if dry_run:
            self._dry_run(data, force_published)
            return

        # Clear existing stories if requested
        if clear:
            self.stdout.write(self.style.WARNING('  Clearing existing imported stories...'))
            # Clear stories that were imported from discover-cameroon
            deleted_count, _ = Story.objects.filter(
                region__in=['West Region', 'Northwest Region', 'South Region',
                           'Far North Region', 'National'],
                country='Cameroon',
            ).delete()
            self.stdout.write(f'  Cleared {deleted_count} stories.\n')

        # Import stories - each in its own transaction so one failure
        # doesn't roll back all imports
        self._import_stories(data, force_published)

    def _dry_run(self, data, force_published):
        """Show what would be imported without making changes."""
        self.stdout.write(self.style.MIGRATE_HEADING('DRY RUN - No changes will be made\n'))

        for i, item in enumerate(data, 1):
            fields = item.get('fields', {})
            title = fields.get('title', 'Untitled')
            category = fields.get('category', 'Uncategorized')
            region = fields.get('region', 'Unknown')
            country = fields.get('country', 'Cameroon')
            is_published = fields.get('is_published', False)
            status = 'PUBLISHED' if (is_published or force_published) else 'DRAFT'

            self.stdout.write(f'  {i}. {self.style.SUCCESS(title)}')
            self.stdout.write(f'     Category: {category}')
            self.stdout.write(f'     Region: {region}, {country}')
            self.stdout.write(f'     Status: {status}')
            self.stdout.write(f'     Tags: {", ".join(fields.get("tags", [])[:5])}')
            self.stdout.write('')

        self.stdout.write(self.style.WARNING(
            f'\nTotal: {len(data)} stories would be imported'
        ))

    def _import_stories(self, data, force_published):
        """Import stories from JSON data, each in its own transaction."""
        created_count = 0
        updated_count = 0
        error_count = 0

        for i, item in enumerate(data, 1):
            try:
                fields = item.get('fields', {})
                if not fields:
                    self.stdout.write(self.style.WARNING(
                        f'  {i}. Skipping item with no fields'
                    ))
                    error_count += 1
                    continue

                # Each story gets its own atomic transaction
                with transaction.atomic():
                    story, was_created = self._create_or_update_story(
                        fields, force_published
                    )

                if was_created:
                    created_count += 1
                    status_label = self.style.SUCCESS('[Created]')
                else:
                    updated_count += 1
                    status_label = self.style.WARNING('[Updated]')

                self.stdout.write(f'  {i}. {status_label} "{story.title}"')

            except Exception as e:
                error_count += 1
                self.stdout.write(self.style.ERROR(
                    f'  {i}. [Error] {str(e)}'
                ))

        # Summary
        self.stdout.write('')
        self.stdout.write(self.style.MIGRATE_HEADING('Import Summary:'))
        self.stdout.write(f'  Created: {self.style.SUCCESS(str(created_count))}')
        self.stdout.write(f'  Updated: {self.style.WARNING(str(updated_count))}')
        self.stdout.write(f'  Errors: {self.style.ERROR(str(error_count))}')
        self.stdout.write('')
        self.stdout.write(self.style.SUCCESS(
            '[Done] Cultural stories import completed!'
        ))

    def _create_or_update_story(self, fields, force_published):
        """Create or update a story from JSON fields."""
        # Extract and map fields
        title = fields.get('title', '')
        # Use allow_unicode for better support of African names
        slug = fields.get('slug', slugify(title, allow_unicode=True))

        # Determine status
        is_published = fields.get('is_published', False)
        if force_published:
            status = Story.Status.PUBLISHED
        else:
            status = Story.Status.PUBLISHED if is_published else Story.Status.DRAFT

        # Extract primary culture from tags
        tags = fields.get('tags', [])
        primary_culture = tags[0] if tags else ''

        # Prepare story data
        story_data = {
            'title': title[:200],  # Enforce max_length
            'slug': slug[:220],  # Enforce max_length
            'subtitle': fields.get('subtitle', '')[:300],
            'summary': fields.get('summary', '')[:500],
            'content': fields.get('content_markdown', ''),
            'country': fields.get('country', 'Cameroon')[:100],
            'region': fields.get('region', '')[:100],
            'culture': primary_culture[:150],
            'language_original': 'en',  # All scraped content is in English
            'status': status,
            'view_count': 0,
        }

        # Create or update story
        story, created = Story.objects.update_or_create(
            slug=slug,
            defaults=story_data
        )

        # Set published_at only if not already set and status is PUBLISHED
        if status == Story.Status.PUBLISHED and not story.published_at:
            story.published_at = timezone.now()
            story.save(update_fields=['published_at'])

        # Handle categories (M2M)
        self._handle_categories(story, fields.get('category', ''))

        # Handle historical context (AIContent)
        self._handle_historical_context(story, fields.get('historical_context', ''))

        # Handle source URL as cultural note (AIContent)
        source_url = fields.get('source_url', '')
        if source_url:
            self._handle_source_url(story, source_url, tags)

        return story, created

    def _handle_categories(self, story, category_name):
        """Create or get category and assign to story."""
        if not category_name:
            return

        # Generate slug for category
        category_slug = slugify(category_name, allow_unicode=True)

        # Determine category type based on name
        category_type = Category.CategoryType.THEME
        region_names = [
            'West Region', 'Northwest Region', 'South Region',
            'Far North Region', 'National'
        ]
        if category_name in region_names:
            category_type = Category.CategoryType.REGION
        elif 'cameroon' in category_name.lower():
            category_type = Category.CategoryType.COUNTRY

        # Get or create category
        category, _ = Category.objects.get_or_create(
            slug=category_slug,
            defaults={
                'name': category_name,
                'category_type': category_type,
                'description': f'Cultural stories about {category_name}',
                'is_active': True,
            }
        )

        # Add to story's categories
        story.categories.add(category)

    def _handle_historical_context(self, story, historical_context):
        """Create AIContent for historical context."""
        if not historical_context:
            return

        # Create or update AIContent
        AIContent.objects.update_or_create(
            story=story,
            content_type=AIContent.ContentType.HISTORICAL_CONTEXT,
            language='en',
            defaults={
                'content': historical_context,
                'model_used': 'scraped-data',
                'is_verified': True,
            }
        )

    def _handle_source_url(self, story, source_url, tags):
        """Store source URL and tags as cultural note in AIContent."""
        # Build a cultural note with source attribution and tags
        note_parts = [f'**Source:** {source_url}']
        if tags:
            note_parts.append(f'**Tags:** {", ".join(tags)}')

        note_content = '\n\n'.join(note_parts)

        AIContent.objects.update_or_create(
            story=story,
            content_type=AIContent.ContentType.CULTURAL_NOTE,
            language='en',
            defaults={
                'content': note_content,
                'model_used': 'scraped-data',
                'is_verified': True,
            }
        )
