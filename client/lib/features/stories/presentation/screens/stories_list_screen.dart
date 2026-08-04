import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/story_card.dart';

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key});

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  String _selectedCategory = 'All';
  String _selectedRegion = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Folklore', 'History', 'Mythology', 'Music', 'Art'];
  final List<String> _regions = ['All', 'West Africa', 'East Africa', 'Central Africa', 'Southern Africa', 'North Africa'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchment,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Stories',
                style: GoogleFonts.notoSerif(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Explore Stories',
                        style: GoogleFonts.notoSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover African cultural heritage',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search stories...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.ivory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppTheme.ivory,
                      selectedColor: AppTheme.terracotta,
                      labelStyle: GoogleFonts.notoSans(
                        color: isSelected ? Colors.white : AppTheme.charcoal,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Region Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: 'Region',
                  filled: true,
                  fillColor: AppTheme.ivory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _regions.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value!;
                  });
                },
              ),
            ),
          ),

          // Stories Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Placeholder data - in real app, this would come from API
                  final stories = [
                    {'title': 'The Legend of Anansi', 'category': 'Folklore', 'views': '1.2k'},
                    {'title': "Mansa Musa's Journey", 'category': 'History', 'views': '2.1k'},
                    {'title': 'The Talking Drum', 'category': 'Music', 'views': '856'},
                    {'title': 'Queen Nzinga', 'category': 'History', 'views': '1.8k'},
                    {'title': 'Anansi the Spider', 'category': 'Folklore', 'views': '3.2k'},
                    {'title': 'The Sundiata Epic', 'category': 'Mythology', 'views': '2.5k'},
                  ];
                  
                  if (index >= stories.length) return null;
                  
                  final story = stories[index];
                  return StoryCard(
                    title: story['title']!,
                    category: story['category']!,
                    views: story['views']!,
                    onTap: () {
                      Navigator.pushNamed(context, '/story-detail');
                    },
                  );
                },
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
