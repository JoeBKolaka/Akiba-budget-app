import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/category/widget/category_field.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:akiba/theme/pallete.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCategory extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddCategory());
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final categoryController = TextEditingController();
  Color selectedColor = Colors.grey;
  String selectedEmoji = "📁";
  final formKey = GlobalKey<FormState>();

  void createNewCategory() async {
    if (formKey.currentState!.validate()) {
      CurrencyPicked user =
          context.read<CurrencyCubit>().state as CurrencyPicked;
      await context.read<CategoryCubit>().createNewCategory(
        name: categoryController.text.trim(),
        emoji: selectedEmoji,
        color: selectedColor,
        user_id: user.user.id,
      );
    }
  }

  @override
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.whiteColor,
      builder: (context) => EmojiPicker(
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
            backgroundColor: Pallete.whiteColor,
          ),
          emojiViewConfig: EmojiViewConfig(backgroundColor: Pallete.whiteColor),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: Pallete.whiteColor,
            indicatorColor: Pallete.greenColor,
            iconColorSelected: Pallete.greenColor,
            backspaceColor: Pallete.greenColor,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: Pallete.whiteColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryStateError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is CategoryStateAdd) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Category added')));
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Center(
            child: Form(
              key: formKey,
              child: Column(
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
                                color: Pallete.whiteColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Pallete.greyColor),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Pallete.greyColor,
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
                    borderColor: Pallete.greenColor,
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
                      onPressed: createNewCategory,
                      child: const Text(
                        "Create",
                        style: TextStyle(
                          color: Pallete.whiteColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}