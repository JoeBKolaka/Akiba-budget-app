import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/category/widget/category_field.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akiba/models/category_model.dart';

class CategoryEditPage extends StatefulWidget {
  final CategoryModel category;
  const CategoryEditPage({super.key, required this.category});

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late final TextEditingController categoryController;
  late Color selectedColor;
  late String selectedEmoji;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(text: widget.category.name);
    selectedColor = widget.category.color ?? Colors.grey;
    selectedEmoji = widget.category.emoji ?? "📁";
  }

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  void updateCategory() async {
    if (categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (selectedEmoji.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an emoji')));
      return;
    }

    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
    await context.read<CategoryCubit>().updateCategory(
      name: categoryController.text.trim(),
      emoji: selectedEmoji,
      color: selectedColor,
      user_id: user.user.id,
    );
  }

  void _showEmojiPicker() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EmojiPicker(
          onEmojiSelected: (Category? category, Emoji emoji) {
            setState(() {
              selectedEmoji = emoji.emoji;
            });
            Navigator.pop(context);
          },
          onBackspacePressed: () {},
          config: Config(
            viewOrderConfig: ViewOrderConfig(
              top: EmojiPickerItem.searchBar,
              middle: EmojiPickerItem.emojiView,
              bottom: EmojiPickerItem.categoryBar,
            ),
            searchViewConfig: SearchViewConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
            emojiViewConfig: EmojiViewConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primary,
              iconColorSelected: theme.colorScheme.primary,
              backspaceColor: theme.colorScheme.primary,
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryStateError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is CategoryStateUpdate) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Category updated')));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: selectedColor,
                            child: Text(
                              selectedEmoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              onTap: () {
                                _showEmojiPicker();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: CategoryField(
                        controller: categoryController,
                        hintText: 'Category',
                        lable: 'Category',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ColorPicker(
                      borderColor: theme.colorScheme.primary,
                      subheading: const Text("Select a different shade"),
                      color: selectedColor,
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      pickersEnabled: const {ColorPickerType.wheel: true},
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: updateCategory,
                        child: Text(
                          "Update",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 100
                          : 0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
