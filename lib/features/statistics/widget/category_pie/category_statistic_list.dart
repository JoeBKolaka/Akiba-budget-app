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

  // Helper function to get start of week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    // Monday is 1, Sunday is 7
    final dayOfWeek = date.weekday;
    // Calculate days to subtract to get to Monday
    final daysToSubtract = dayOfWeek - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

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
      // Calculate the week start date based on offsets
      final baseDate = DateTime.now();
      
      // Get the start of the week (Monday)
      final weekStart = _getStartOfWeek(baseDate).add(Duration(days: 7 * weekOffset));
      
      // Get the end of the week (Sunday 23:59:59.999)
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return (transactionDate.isAfter(weekStart) || 
                transactionDate.isAtSameMomentAs(weekStart)) &&
               (transactionDate.isBefore(weekEnd) || 
                transactionDate.isAtSameMomentAs(weekEnd));
      }).toList();
    } else if (selectedView == 'monthly') {
      // Calculate the actual month based on offsets
      final month = DateTime.now().month + monthOffset;
      final year = DateTime.now().year;
      
      // Adjust for year overflow/underflow
      final actualYear = year + (month - 1) ~/ 12;
      final actualMonth = ((month - 1) % 12) + 1;
      
      // Get start and end of month
      final monthStart = DateTime(actualYear, actualMonth, 1);
      final monthEnd = DateTime(actualYear, actualMonth + 1, 0, 23, 59, 59, 999);

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return (transactionDate.isAfter(monthStart) || 
                transactionDate.isAtSameMomentAs(monthStart)) &&
               (transactionDate.isBefore(monthEnd) || 
                transactionDate.isAtSameMomentAs(monthEnd));
      }).toList();
    } else if (selectedView == 'yearly') {
      // Calculate the actual year based on offsets
      final year = DateTime.now().year + yearOffset;
      
      // Get start and end of year
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31, 23, 59, 59, 999);

      return categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return (transactionDate.isAfter(yearStart) || 
                transactionDate.isAtSameMomentAs(yearStart)) &&
               (transactionDate.isBefore(yearEnd) || 
                transactionDate.isAtSameMomentAs(yearEnd));
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
                            'Ksh ${NumberFormat('#,##0.00').format(dailyCashflow)}',
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
                          'Ksh ${NumberFormat('#,##0.00').format(transaction.transaction_amount)}',
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