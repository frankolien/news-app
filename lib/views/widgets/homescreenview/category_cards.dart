/*import 'package:flutter/material.dart';
import 'package:news_app/views/widgets/homescreenview/category_card.dart';

class CategoryCards extends StatelessWidget {
  final List<dynamic> categories;

  const CategoryCards({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              SizedBox(
                width: 150, 
                // Give each category card a fixed width
                
                child: CategoryCard(category: categories[i], categories: [],),
              ),
              if (i < categories.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}*/