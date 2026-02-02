import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../models/transaction_model.dart';
import '../../../home/cubit/transaction_cubit.dart';

class CategoryTransactionList extends StatelessWidget {
  final String categoryId;
  final String selectedView;
  final int weekOffset;
  final int monthOffset;
  final int yearOffset;

  const CategoryTransactionList({
    required this.categoryId,
    required this.selectedView,
    required this.weekOffset,
    required this.monthOffset,
    required this.yearOffset,
  });

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> allTransactions,
  ) {
    if (allTransactions.isEmpty) return [];

    // Filter by category
    final categoryTransactions = allTransactions
        .where((transaction) => transaction.category_id == categoryId)
        .toList();

    if (categoryTransactions.isEmpty) return [];

    // Apply date filtering
    if (selectedView == 'allTime') {
      return categoryTransactions;
    } else if (selectedView == 'weekly') {
      final baseDate = DateTime.now().add(Duration(days: 7 * weekOffset));
      final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(weekStart) ||
            (transactionDate.isAfter(weekStart) &&
                transactionDate.isBefore(weekEnd));
      }).toList();
    } else if (selectedView == 'monthly') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month + monthOffset, 1);
      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        0,
        23,
        59,
        59,
        999,
      );

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(monthStart) ||
            (transactionDate.isAfter(monthStart) &&
                transactionDate.isBefore(monthEnd));
      }).toList();
    } else if (selectedView == 'yearly') {
      final now = DateTime.now();
      final year = now.year + yearOffset;
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31, 23, 59, 59, 999);

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(yearStart) ||
            (transactionDate.isAfter(yearStart) &&
                transactionDate.isBefore(yearEnd));
      }).toList();
    }

    return categoryTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransactionStateError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.error}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<TransactionCubit>().loadTransactions();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TransactionStateLoaded) {
          final filteredTransactions = _getFilteredTransactions(
            state.transactions,
          );

          return _buildTransactionList(filteredTransactions);
        }

        return const Center(child: Text('No transactions found'));
      },
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No transactions for this period',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.created_at);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // SIMPLIFIED VERSION - just use Column since parent handles scrolling
        Column(
          children: List.generate(sortedDates.length, (dateIndex) {
            final date = sortedDates[dateIndex];
            final dateTransactions = groupedTransactions[date]!;

            final DateTime parsedDate = DateTime.parse(date);
            final String formattedDate = DateFormat(
              'EEE, MMM d',
            ).format(parsedDate);

            // Calculate daily cashflow
            double dailyCashflow = 0;
            for (var transaction in dateTransactions) {
              if (transaction.transaction_type == 'income') {
                dailyCashflow += transaction.transaction_amount;
              } else if (transaction.transaction_type == 'expense') {
                dailyCashflow -= transaction.transaction_amount;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                          Text(
                            'Ksh ${dailyCashflow.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: dailyCashflow >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                // Transaction items
                Column(
                  children: List.generate(dateTransactions.length, (index) {
                    final transaction = dateTransactions[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.transaction_type == 'income'
                              ? Colors.green
                              : Colors.red,
                          child: Center(
                            child: Text(
                              transaction.transaction_type == 'income'
                                  ? '↑'
                                  : '↓',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        title: Text(
                          transaction.transaction_name,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          DateFormat('h:mm a').format(transaction.created_at),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          'Ksh ${transaction.transaction_amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: transaction.transaction_type == 'income'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ),
      ],
    );
  }
}
