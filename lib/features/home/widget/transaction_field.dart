import 'package:flutter/material.dart';
import 'package:akiba/theme/pallete.dart';

class TransactionField extends StatefulWidget {
  final TextEditingController? controller;
  const TransactionField({Key? key, this.controller}) : super(key: key);

  @override
  State<TransactionField> createState() => _TransactionFieldState();
}

class _TransactionFieldState extends State<TransactionField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 180,
      child: TextField(
        controller: _controller, 
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