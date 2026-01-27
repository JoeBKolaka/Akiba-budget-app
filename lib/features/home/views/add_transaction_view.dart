import 'package:akiba/features/account/widget/ammount_textfield.dart';
import 'package:akiba/features/home/widget/transaction_container.dart';
import 'package:akiba/features/home/widget/transaction_field.dart';
import 'package:akiba/features/home/widget/transaction_type_selector.dart';
import 'package:flutter/material.dart';

class AddTransactionView extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddTransactionView());

  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  TransactionType selectedTransaction = TransactionType.income;
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TransactionTypeSelector(
          selectedType: selectedTransaction,
          onTypeChanged: (type) {
            setState(() {
              selectedTransaction = type;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  AmmountTextfield(controller: _amountController),
                  const SizedBox(height: 20),
                  // Changed from Chip to InputChip
                  TransactionField(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Keep the amber container at the bottom
          Positioned(bottom: 20, child: TransactionContainer()),
        ],
      ),
    );
  }
}
