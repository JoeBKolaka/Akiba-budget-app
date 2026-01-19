import 'package:akiba/features/category/widget/category_field.dart';
import 'package:akiba/theme/pallete.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddCategory());
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final categoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Pallete.greyColor,
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
              heading: const Text("Selected colour"),
              subheading: const Text("Select a different shade"),
              onColorChanged: (Color color) {
                setState(() {
                  //selectedColor = color;
                });
              },
              //color: selectedColor,
              pickersEnabled: const {ColorPickerType.wheel: true},
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},

              child: const Text(
                "Create",
                style: TextStyle(color: Pallete.whiteColor, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
