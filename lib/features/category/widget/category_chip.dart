import 'package:akiba/utils/categories.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.5,
        crossAxisCount: 3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ActionChip(
          avatar: Text(categories[index]['emoji'].toString()),
          label: Text(categories[index]['name'].toString()),
        );
      },
    );
  }
}

