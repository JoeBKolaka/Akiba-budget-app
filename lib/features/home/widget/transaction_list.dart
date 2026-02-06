import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:akiba/models/transaction_model.dart';

import '../../create account/cubit/currency_cubit.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  String _currencySymbol = '\$'; // Default value
  int _decimalPlaces = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;

    // Load transactions
    final transactions = await context
        .read<TransactionCubit>()
        .transactionLocalRepository
        .getTransactions();

    // Load categories
    final categories = await context
        .read<TransactionCubit>()
        .categoryLocalRepository
        .getCategories();

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _categories = categories;
        _currencySymbol = user.user.symbol;
        _decimalPlaces = user.user.decimal_digits;
      });
    }
  }

  CategoryModel? _getCategoryForTransaction(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateLoaded) {
          _loadData();
        }
      },
      child: _buildTransactionList(),
    );
  }

  Widget _buildTransactionList() {
    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};

    for (var transaction in _transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.created_at);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateTransactions = groupedTransactions[date]!;

        final DateTime parsedDate = DateTime.parse(date);
        final String formattedDate = DateFormat(
          'EEE, MMM d',
        ).format(parsedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      _buildDailyCashflow(dateTransactions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: Colors.grey),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dateTransactions.length,
              itemBuilder: (context, index) {
                final transaction = dateTransactions[index];
                final category = _getCategoryForTransaction(
                  transaction.category_id,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category != null
                          ? category.color
                          : Colors.grey,
                      child: Center(
                        child: Text(
                          category?.emoji ?? '💰',
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                    title: Text(
                      transaction.transaction_name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: Text(
                      '$_currencySymbol${transaction.transaction_amount.toStringAsFixed(_decimalPlaces)}',
                      style: TextStyle(
                        color: transaction.transaction_type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    onTap: () {
                      // Handle transaction tap
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDailyCashflow(List<TransactionModel> transactions) {
    double dailyCashflow = 0;
    for (var transaction in transactions) {
      final amount = transaction.transaction_amount;
      final type = transaction.transaction_type;
      if (type == 'income') {
        dailyCashflow += amount;
      } else {
        dailyCashflow -= amount;
      }
    }

    return Text(
      '$_currencySymbol${dailyCashflow.toStringAsFixed(_decimalPlaces)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: dailyCashflow >= 0 ? Colors.green : Colors.red,
      ),
    );
  }
}
