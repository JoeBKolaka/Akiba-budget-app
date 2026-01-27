import 'package:akiba/theme/pallete.dart';
import 'package:flutter/material.dart';

class TransactionField extends StatefulWidget {
  const TransactionField({super.key});

  @override
  State<TransactionField> createState() => _TransactionFieldState();
}

class _TransactionFieldState extends State<TransactionField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 180,
      child: TextField(
        textAlign: TextAlign.center,
        cursorHeight: 12,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Pallete.greenColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Pallete.greyColor),
          ),
          contentPadding: const EdgeInsets.all(4),
          hintText: 'Transaction Name',
          hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
