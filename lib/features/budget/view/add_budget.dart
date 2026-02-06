import 'package:akiba/features/account/widget/ammount_textfield.dart';
import 'package:akiba/features/budget/cubit/budget_cubit.dart';
import 'package:akiba/features/budget/view/budget_view.dart';
import 'package:akiba/features/home/widget/category_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create account/cubit/currency_cubit.dart';

class AddBudget extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const AddBudget());
  const AddBudget({super.key});

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryEmoji;
  int? _selectedPeriodIndex;

  void createNewTransaction() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
    String amountText = _amountController.text
        .replaceAll(user.user.symbol, '')
        .replaceAll(',', '')
        .trim();
    double amount = double.tryParse(amountText) ?? 0.0;
    await context.read<BudgetCubit>().createNewBudget(
      user_id: user.user.id,
      category_id: _selectedCategoryId!,
      repetition: _selectedPeriodIndex!.toString(),
      budget_amount: amount,
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
      appBar: AppBar(),
      body: BlocListener<BudgetCubit, BudgetState>(
        listener: (context, state) {
          if (state is BudgetStateAdd) {
            Navigator.pop(context, BudgetView());
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InputChip(
                label: _selectedCategoryName != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedCategoryEmoji != null)
                            Text(_selectedCategoryEmoji!),
                          const SizedBox(width: 4),
                          Text(_selectedCategoryName!),
                        ],
                      )
                    : const Text('Category'),
                backgroundColor: _selectedCategoryName != null
                    ? Colors.green.shade100
                    : null,
                onPressed: _showCategoryBottomSheet,
                deleteIcon: _selectedCategoryName != null
                    ? const Icon(Icons.close, size: 18)
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
              const SizedBox(height: 20),
              AmmountTextfield(controller: _amountController),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Daily'),
                    selected: _selectedPeriodIndex == 0,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodIndex = selected ? 0 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Weekly'),
                    selected: _selectedPeriodIndex == 1,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodIndex = selected ? 1 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Monthly'),
                    selected: _selectedPeriodIndex == 2,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodIndex = selected ? 2 : null;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Yearly'),
                    selected: _selectedPeriodIndex == 3,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodIndex = selected ? 3 : null;
                      });
                    },
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: createNewTransaction,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
