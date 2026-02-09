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
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;

  // Track which transactions are being deleted to prevent rebuilding issues
  final Set<String> _deletingTransactions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;

    final categories = await context
        .read<TransactionCubit>()
        .categoryLocalRepository
        .getCategories();

    if (mounted) {
      setState(() {
        _categories = categories;
        _currencySymbol = user.user.symbol;
        _decimalPlaces = user.user.decimal_digits;
        _deletingTransactions.clear(); // Clear any pending deletions
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

  String _formatNumber(double amount) {
    final formatter = NumberFormat.currency(
      symbol: _currencySymbol,
      decimalDigits: _decimalPlaces,
    );
    return formatter.format(amount.abs());
  }

  Future<void> _handleDelete(TransactionModel transaction) async {
    // Mark this transaction as being deleted
    setState(() {
      _deletingTransactions.add(transaction.id);
    });

    // Call the cubit to delete
    await context.read<TransactionCubit>().deleteTransaction(transaction.id);

    // Remove from deleting set after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _deletingTransactions.remove(transaction.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateLoaded) {
          setState(() {
            _transactions = state.transactions;
          });
        }
      },
      builder: (context, state) {
        if (state is TransactionStateError) {
          return Center(child: Text('Error: ${state.error}'));
        }

        return _buildTransactionList();
      },
    );
  }

  Widget _buildTransactionList() {
    // Filter out transactions that are being deleted
    final visibleTransactions = _transactions
        .where((transaction) => !_deletingTransactions.contains(transaction.id))
        .toList();

    final Map<String, List<TransactionModel>> groupedTransactions = {};

    for (var transaction in visibleTransactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.created_at);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

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
                        ),
                      ),
                      _buildDailyCashflow(dateTransactions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1),
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
                  key: ValueKey(
                    transaction.id,
                  ), // Use ValueKey instead of Key in Dismissible
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Dismissible(
                    key: Key(
                      'dismissible_${transaction.id}',
                    ), // Unique key for dismissible
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _handleDelete(transaction);
                    },
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
                        style: const TextStyle(),
                      ),
                      trailing: Text(
                        _formatNumber(transaction.transaction_amount),
                        style: TextStyle(
                          color: transaction.transaction_type == 'income'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      onTap: () {},
                    ),
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
      _formatNumber(dailyCashflow),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: dailyCashflow >= 0 ? Colors.green : Colors.red,
      ),
    );
  }
}
