import 'package:akiba/features/home/widget/account_category.dart';
import 'package:flutter/material.dart';

class CategoryBottom extends StatefulWidget {
  final Function(String categoryId, String categoryName, String categoryEmoji)?
  onCategorySelected;

  const CategoryBottom({super.key, this.onCategorySelected});

  @override
  State<CategoryBottom> createState() => _CategoryBottomState();
}

class _CategoryBottomState extends State<CategoryBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 300,
      child: Column(
        children: [
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          AccountCategory(
            onTap: (categoryId, categoryName, categoryEmoji) {
              widget.onCategorySelected?.call(
                categoryId,
                categoryName,
                categoryEmoji,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
