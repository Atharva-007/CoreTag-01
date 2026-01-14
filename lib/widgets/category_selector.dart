import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;
          return IconButton(
            onPressed: () => onCategorySelected(index),
            icon: Icon(
              category['icon'] as IconData,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade600,
            ),
            tooltip: category['title'] as String,
          );
        }),
      ),
    );
  }
}