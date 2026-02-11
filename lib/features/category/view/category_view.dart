import 'package:akiba/features/category/view/add_category.dart';
import 'package:akiba/features/category/widget/category_chip.dart';
import 'package:flutter/material.dart';

class CategoryView extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const CategoryView());
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Categories',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, AddCategory.route());
            },
            child: Text('Add'),
          ),
        ],
      ),
      body: CategoryChip(),
    );
  }
}
