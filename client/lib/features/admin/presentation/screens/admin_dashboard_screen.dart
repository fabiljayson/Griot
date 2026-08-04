import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchment,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation
                _buildTopNav(),
                
                // Dashboard Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        _buildStatsSection(),
                        const SizedBox(height: 24),
                        
                        // Pending Submissions & Activity
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildPendingSubmissions(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildRecentActivity(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _isSidebarExpanded ? 260 : 80,
      color: AppTheme.charcoal,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.terracotta,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    'African Teller',
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                children: [
                  _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
                  _buildNavItem(1, Icons.auto_stories_rounded, 'Stories'),
                  _buildNavItem(2, Icons.people_rounded, 'Users'),
                  _buildNavItem(3, Icons.analytics_rounded, 'Analytics'),
                  _buildNavItem(4, Icons.settings_rounded, 'Settings'),
                ],
              ),
            ),
          ),
          
          // User Profile
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white10, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.terracotta,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'admin@africanteller.com',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.terracotta : Colors.white54,
          size: 24,
        ),
        title: _isSidebarExpanded
            ? Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.terracotta : Colors.white70,
                ),
              )
            : null,
        selected: isSelected,
        selectedTileColor: AppTheme.terracotta.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoal,
                ),
              ),
              Text(
                "Welcome back! Here's what's happening today.",
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppTheme.warmGray,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notifications
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.warmGray),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.terracotta,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          // Profile
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.terracotta,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.notoSerif(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.auto_stories_rounded,
          title: 'Total Stories',
          value: '247',
          change: '+12%',
          color: AppTheme.terracotta,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.people_rounded,
          title: 'Active Users',
          value: '1,892',
          change: '+8%',
          color: AppTheme.savannahGreen,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.videocam_rounded,
          title: 'Videos Generated',
          value: '156',
          change: '+24%',
          color: AppTheme.ochre,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.trending_up_rounded,
          title: 'Engagement Rate',
          value: '78%',
          change: '+5%',
          color: AppTheme.terracotta,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    return Expanded(
      child: Container(
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
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.savannahGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.savannahGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.notoSerif(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppTheme.warmGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingSubmissions() {
    final submissions = [
      {
        'title': 'The Legend of Anansi',
        'author': 'Kwame Asante',
        'time': '2 hours ago',
        'category': 'Folklore',
        'color': AppTheme.terracotta,
      },
      {
        'title': "Mansa Musa's Journey",
        'author': 'Amina Diallo',
        'time': '5 hours ago',
        'category': 'History',
        'color': AppTheme.savannahGreen,
      },
      {
        'title': 'The Talking Drum',
        'author': 'Chidi Okonkwo',
        'time': '1 day ago',
        'category': 'Music',
        'color': AppTheme.ochre,
      },
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Submissions',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoal,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All →',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.terracotta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...submissions.map((submission) => _buildSubmissionItem(
            title: submission['title'] as String,
            author: submission['author'] as String,
            time: submission['time'] as String,
            category: submission['category'] as String,
            color: submission['color'] as Color,
          )),
        ],
      ),
    );
  }

  Widget _buildSubmissionItem({
    required String title,
    required String author,
    required String time,
    required String category,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.parchment,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 24,
            ),
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
                Text(
                  'Submitted by $author • $time',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppTheme.warmGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.savannahGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Approve'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warmGray,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.check_circle_outline,
        'color': AppTheme.savannahGreen,
        'text': 'Story approved: "The Tortoise and the Hare"',
        'time': '2 minutes ago',
      },
      {
        'icon': Icons.videocam_outlined,
        'color': AppTheme.terracotta,
        'text': 'Video generated: "Sunjata Epic"',
        'time': '15 minutes ago',
      },
      {
        'icon': Icons.person_add_outlined,
        'color': AppTheme.ochre,
        'text': 'New user: Fatima Keita joined',
        'time': '1 hour ago',
      },
      {
        'icon': Icons.emoji_events_outlined,
        'color': AppTheme.savannahGreen,
        'text': 'Badge earned: "Story Explorer"',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.star_outline,
        'color': AppTheme.terracotta,
        'text': 'Story featured: "Queen Nzinga\'s Legacy"',
        'time': '3 hours ago',
      },
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _buildActivityItem(
            icon: activity['icon'] as IconData,
            color: activity['color'] as Color,
            text: activity['text'] as String,
            time: activity['time'] as String,
          )),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
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
