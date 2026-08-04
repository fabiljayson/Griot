import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.notoSerif(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: AppTheme.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),
            
            // Mission Section
            _buildMissionSection(),
            
            // Values Section
            _buildValuesSection(),
            
            // Team Section
            _buildTeamSection(),
            
            // CTA Section
            _buildCTASection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.savannahGreen, Color(0xFF1C3A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Our Mission',
            style: GoogleFonts.notoSerif(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Preserving and sharing Africa\'s rich cultural heritage through interactive stories, AI-powered video narratives, and gamified learning experiences.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why African Teller?',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Africa is home to one of the world\'s oldest and richest oral traditions. For centuries, stories have been passed down through generations, preserving cultural wisdom, moral lessons, and historical knowledge.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: AppTheme.warmGray,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'African Teller was born from a simple belief: these stories deserve to be heard, seen, and experienced by the world. We combine cutting-edge AI technology with deep respect for cultural authenticity.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: AppTheme.warmGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection() {
    final values = [
      {
        'icon': Icons.verified_rounded,
        'title': 'Authenticity',
        'description': 'Every story is carefully verified to ensure cultural accuracy.',
        'color': AppTheme.terracotta,
      },
      {
        'icon': Icons.bolt_rounded,
        'title': 'Innovation',
        'description': 'We leverage AI technology to transform traditional stories.',
        'color': AppTheme.ochre,
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Community',
        'description': 'Building a global community of culture enthusiasts.',
        'color': AppTheme.savannahGreen,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppTheme.parchment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Values',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...values.map((value) => _buildValueCard(
            icon: value['icon'] as IconData,
            title: value['title'] as String,
            description: value['description'] as String,
            color: value['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
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

  Widget _buildTeamSection() {
    final team = [
      {
        'initials': 'AO',
        'name': 'Adaeze Obi',
        'role': 'Founder & CEO',
        'color': AppTheme.terracotta,
      },
      {
        'initials': 'KM',
        'name': 'Kwame Mensah',
        'role': 'CTO',
        'color': AppTheme.savannahGreen,
      },
      {
        'initials': 'FD',
        'name': 'Fatima Diallo',
        'role': 'Head of Content',
        'color': AppTheme.ochre,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet the Team',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...team.map((member) => _buildTeamMember(
            initials: member['initials'] as String,
            name: member['name'] as String,
            role: member['role'] as String,
            color: member['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String initials,
    required String name,
    required String role,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.terracotta, Color(0xFFA03C1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Join Our Mission',
            style: GoogleFonts.notoSerif(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Help us preserve and share Africa\'s rich cultural heritage with the world.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/stories');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.terracotta,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Explore Stories'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Sign Up Free'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
