import 'package:akiba/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../category/cubit/add_new_category_cubit.dart';

typedef CategoryChipOnTap =
    void Function(String categoryId, String categoryName, String categoryEmoji);

class AccountCategory extends StatefulWidget {
  final CategoryChipOnTap? onTap;
  const AccountCategory({super.key, this.onTap});

  @override
  State<AccountCategory> createState() => _AccountCategoryState();
}

class _AccountCategoryState extends State<AccountCategory> {
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
                widget.onTap?.call(
                  _categories[index].id.toString(),
                  _categories[index].name,
                  _categories[index].emoji,
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
