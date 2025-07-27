//Updated CategoryChip to handle null IDs gracefully
import 'package:flutter/material.dart';
import 'package:news_app/models/source_model.dart';

class CategoryChip extends StatelessWidget {
  final Source category;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  Color _getCategoryColor() {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFF607D8B),
      const Color(0xFFFFC107),
      const Color(0xFF795548),
    ];
    
    final hash = (category.name ?? '').hashCode;
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor,
              categoryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              category.name?.toUpperCase() ?? 'CATEGORY',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    final name = category.name?.toLowerCase() ?? '';
    
    if (name.contains('sport')) return Icons.sports_football;
    if (name.contains('tech')) return Icons.computer;
    if (name.contains('business')) return Icons.business;
    if (name.contains('health')) return Icons.local_hospital;
    if (name.contains('entertainment')) return Icons.movie;
    if (name.contains('politics')) return Icons.account_balance;
    if (name.contains('science')) return Icons.science;
    if (name.contains('world')) return Icons.public;
    
    return Icons.article;
  }
}