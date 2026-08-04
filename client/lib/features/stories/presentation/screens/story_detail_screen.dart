import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data - in real app, this would come from API
    const story = {
      'title': 'The Legend of Anansi',
      'category': 'Folklore',
      'culture': 'Ashanti',
      'country': 'Ghana',
      'views': '1,234',
      'summary': 'Anansi is a spider who is a figure of great wisdom and cunning in West African folklore.',
      'content': 'Anansi the Spider is one of the most important characters in West African folklore. He is a trickster, a keeper of stories, and a symbol of wisdom and cunning.\n\nIn Ashanti tradition, Anansi is credited with bringing all stories to the world. He obtained them from Nyame, the Sky God, by solving seemingly impossible riddles.\n\nThe tales of Anansi have traveled across the Atlantic through the African diaspora, becoming an important part of Caribbean and African American folklore as well.',
      'hasAudio': true,
      'hasVideo': true,
    };

    return Scaffold(
      backgroundColor: AppTheme.parchment,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                story['title']!,
                style: GoogleFonts.notoSerif(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.terracotta, Color(0xFFA03C1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  // Share functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {
                  // Bookmark functionality
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(story['category']!, AppTheme.terracotta),
                      _buildTag(story['culture']!, AppTheme.savannahGreen),
                      _buildTag(story['country']!, AppTheme.ochre),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStat(Icons.visibility_outlined, '${story['views']} views'),
                      const SizedBox(width: 16),
                      _buildStat(Icons.access_time_rounded, '5 min read'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.ivory,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.terracotta.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: GoogleFonts.notoSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.charcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story['summary']!,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: AppTheme.warmGray,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Audio Player
                  if (story['hasAudio'] == true) ...[
                    _buildMediaPlayer(
                      icon: Icons.headphones_rounded,
                      title: 'Listen to Story',
                      subtitle: '3:45 minutes',
                      color: AppTheme.terracotta,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Video Player
                  if (story['hasVideo'] == true) ...[
                    _buildMediaPlayer(
                      icon: Icons.play_circle_rounded,
                      title: 'Watch Video',
                      subtitle: 'AI-generated cinematic narrative',
                      color: AppTheme.ochre,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Story Content
                  Text(
                    'The Story',
                    style: GoogleFonts.notoSerif(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story['content']!,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: AppTheme.charcoal,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Related Stories
                  Text(
                    'Related Stories',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return _buildRelatedStoryCard();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.warmGray),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppTheme.warmGray,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPlayer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppTheme.warmGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_circle_fill_rounded, color: color, size: 40),
            onPressed: () {
              // Play media
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedStoryCard() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.terracotta.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 32,
              color: AppTheme.terracotta.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Story',
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Folklore',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppTheme.warmGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
