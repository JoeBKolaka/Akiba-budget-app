import 'package:akiba/features/category/view/edit_category.dart';
import 'package:akiba/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';

class CategoryChip extends StatefulWidget {
  const CategoryChip({super.key});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  late List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await context
        .read<CategoryCubit>()
        .categoryLocalRepository
        .getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state is CategoryStateAdd || state is CategoryStateUpdate) {
          _loadCategories();
        }
      },
      child: Center(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: List.generate(_categories.length, (index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryEditPage(category: _categories[index]),
                  ),
                );
              },
              child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Text(_categories[index].emoji),
                ),
                label: Text(_categories[index].name),
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Colors.grey[300]!),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }),
        ),
      ),
    );
  }
}
