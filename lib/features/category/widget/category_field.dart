import 'package:akiba/theme/pallete.dart';
import 'package:flutter/material.dart';

class CategoryField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String lable;
  const CategoryField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.lable,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Pallete.greenColor, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Pallete.greyColor),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
