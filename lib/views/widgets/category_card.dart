// lib/views/widgets/category_cards.dart
import 'package:flutter/material.dart';
import 'package:news_app/core/constants/colors.dart';
import 'package:news_app/models/source_model.dart';
import 'package:news_app/views/category_story_view.dart';

class CategoryCards extends StatelessWidget {
  final List<Source> categories;

  const CategoryCards({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_outlined, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No categories available',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: ${categories.length} categories found',
                    style: TextStyle(
                      color: Colors.orange[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = colors[index % colors.length];
          return _buildCategoryCard(
            context,
            category,
            color,
            _getCategoryIcon(category.name),
          );
        },
      ),
    );
  }

  // Helper method to build individual category cards
  Widget _buildCategoryCard(BuildContext context, Source category, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryStoriesView(
              category: category,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  if (category.totalStories != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${category.totalStories}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                category.name?.toUpperCase() ?? 'CATEGORY',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for category
  IconData _getCategoryIcon(String? categoryName) {
    final name = categoryName?.toLowerCase() ?? '';
    if (name.contains('politic')) return Icons.account_balance;
    if (name.contains('business')) return Icons.business;
    if (name.contains('sport')) return Icons.sports_football;
    if (name.contains('entertainment')) return Icons.movie;
    if (name.contains('tech')) return Icons.computer;
    if (name.contains('health')) return Icons.local_hospital;
    if (name.contains('science')) return Icons.science;
    if (name.contains('world')) return Icons.public;
    if (name.contains('travel')) return Icons.flight;
    if (name.contains('food')) return Icons.restaurant;
    return Icons.article; // Default icon
  }
}