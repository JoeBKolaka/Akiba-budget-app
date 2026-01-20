import 'dart:ui';

import 'package:akiba/theme/pallete.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class CustomView extends EmojiPickerView {
  CustomView(
    Config config,
    EmojiViewState state,
    VoidCallback showSearchBar, {
    super.key,
  }) : super(
          config,
          state,
          showSearchBar,
        );

  @override
  _CustomViewState createState() => _CustomViewState();
}

class _CustomViewState extends State<CustomView> {
  @override
  Widget build(BuildContext context) {
    // You can access widget.config, widget.state and widget.showSearchBar
    // Return your custom emoji picker UI here
    return Container(
      color: Pallete.whiteColor,
      child: Column(
        children: [
          // Custom header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select an Emoji",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Use the default emoji grid from parent
          //Expanded(
          //  child: super.build(context),
          //),
        ],
      ),
    );
  }
}