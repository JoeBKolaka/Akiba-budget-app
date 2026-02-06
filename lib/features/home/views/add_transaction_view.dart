import 'package:akiba/features/account/widget/ammount_textfield.dart';
import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/features/home/views/home_view.dart';
import 'package:akiba/features/home/widget/account_bottom.dart';
import 'package:akiba/features/home/widget/category_bottom.dart';
import 'package:akiba/features/home/widget/transaction_field.dart';
import 'package:akiba/features/home/widget/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _transactionController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  String? _selectedAccountId;
  String? _selectedAccountName;

  // Add state for selected category
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryEmoji;

  void createNewTransaction() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
    String amountText = _amountController.text
        .replaceAll(user.user.symbol, '')
        .replaceAll(',', '')
        .trim();
    double amount = double.tryParse(amountText) ?? 0.0;
    await context.read<TransactionCubit>().createTransaction(
      user_id: user.user.id,
      category_id: _selectedCategoryId!,
      account_id: _selectedAccountId!,
      transaction_name: _transactionController.text.trim(),
      transaction_amount: amount,
      transaction_type: selectedTransaction.name,
    );
  }

  void _showAccountBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 480
            ? 480
            : double.infinity,
      ),
      builder: (context) => AccountBottom(
        onAccountSelected: (account_id, account_name) {
          setState(() {
            _selectedAccountId = account_id;
            _selectedAccountName = account_name;
          });
        },
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width > 480
            ? 480
            : double.infinity,
      ),
      builder: (context) => CategoryBottom(
        onCategorySelected: (categoryId, categoryName, categoryEmoji) {
          setState(() {
            _selectedCategoryId = categoryId;
            _selectedCategoryName = categoryName;
            _selectedCategoryEmoji = categoryEmoji;
          });
        },
      ),
    );
  }

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
      body: BlocConsumer<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateLoaded) {
            Navigator.pop(context, HomeView());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final _selectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (_selectedDate != null) {
                            setState(() {
                              selectedDate = _selectedDate;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateFormat("MMM-dd-y").format(selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AmmountTextfield(controller: _amountController),
                      const SizedBox(height: 20),
                      TransactionField(controller: _transactionController),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    InputChip(
                      label: _selectedCategoryName != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedCategoryEmoji != null)
                                  Text(_selectedCategoryEmoji!),
                                SizedBox(width: 4),
                                Text(_selectedCategoryName!),
                              ],
                            )
                          : Text('Category'),
                      backgroundColor: _selectedCategoryName != null
                          ? Colors.green.shade100
                          : null,
                      onPressed: _showCategoryBottomSheet,
                      deleteIcon: _selectedCategoryName != null
                          ? Icon(Icons.close, size: 18)
                          : null,
                      onDeleted: _selectedCategoryName != null
                          ? () {
                              setState(() {
                                _selectedCategoryId = null;
                                _selectedCategoryName = null;
                                _selectedCategoryEmoji = null;
                              });
                            }
                          : null,
                    ),
                    SizedBox(width: 8),
                    InputChip(
                      label: _selectedAccountName != null
                          ? Text(_selectedAccountName!)
                          : Text('Account'),
                      backgroundColor: _selectedAccountName != null
                          ? Colors.blue.shade100
                          : null,
                      onPressed: _showAccountBottomSheet,
                      deleteIcon: _selectedAccountName != null
                          ? Icon(Icons.close, size: 18)
                          : null,
                      onDeleted: _selectedAccountName != null
                          ? () {
                              setState(() {
                                _selectedAccountId = null;
                                _selectedAccountName = null;
                              });
                            }
                          : null,
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: createNewTransaction,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
