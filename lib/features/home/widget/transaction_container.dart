import 'package:flutter/material.dart';

class TransactionContainer extends StatefulWidget {
  const TransactionContainer({super.key});

  @override
  State<TransactionContainer> createState() => _TransactionContainerState();
}

class _TransactionContainerState extends State<TransactionContainer> {
  void onPressed() {
    // Add your save button logic here
    print('Save button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 40,
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(width: 8),
          InputChip(label: Text('Category')),
          SizedBox(width: 8), // Added spacing between chips
          InputChip(label: Text('Account')),
          Spacer(), // Pushes the button to the right
          TextButton(
            onPressed: onPressed, 
            child: Text('Save')
          )
        ],
      ),
    );
  }
}
