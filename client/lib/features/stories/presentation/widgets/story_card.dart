import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class StoryCard extends StatelessWidget {
  final String title;
  final String category;
  final String views;
  final VoidCallback? onTap;
  final String? imageUrl;

  const StoryCard({
    super.key,
    required this.title,
    required this.category,
    required this.views,
    this.onTap,
    this.imageUrl,
  });

  Color get _categoryColor {
    switch (category.toLowerCase()) {
      case 'folklore':
        return AppTheme.terracotta;
      case 'history':
        return AppTheme.savannahGreen;
      case 'mythology':
        return AppTheme.ochre;
      case 'music':
        return AppTheme.terracotta;
      case 'art':
        return AppTheme.savannahGreen;
      default:
        return AppTheme.warmGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.ivory,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _categoryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _categoryColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 48,
                          color: _categoryColor.withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: _categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Views
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppTheme.warmGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: AppTheme.warmGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
