import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/category_model.dart';

class AccountTransactionList extends StatefulWidget {
  final String accountId;
  final String selectedView;
  final int weekOffset;
  final int monthOffset;
  final int yearOffset;

  const AccountTransactionList({
    super.key,
    required this.accountId,
    required this.selectedView,
    required this.weekOffset,
    required this.monthOffset,
    required this.yearOffset,
  });

  @override
  State<AccountTransactionList> createState() => _AccountTransactionListState();
}

class _AccountTransactionListState extends State<AccountTransactionList> {
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final categories = await context
        .read<TransactionCubit>()
        .categoryLocalRepository
        .getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
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

  List<dynamic> _getFilteredTransactions(List<dynamic> transactions) {
    // First filter by account
    List<dynamic> accountTransactions = transactions
        .where((transaction) => transaction.account_id == widget.accountId)
        .toList();

    if (widget.selectedView == 'weekly') {
      final now = DateTime.now();
      final baseDate = DateTime(now.year, now.month, now.day).add(
        Duration(days: 7 * widget.weekOffset),
      );
      
      // Calculate week start (Monday)
      final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      
      // Calculate week end (Sunday)
      final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));


      return accountTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        final isInRange = (transactionDate.isAfter(weekStart) || 
                          transactionDate.isAtSameMomentAs(weekStart)) &&
                         (transactionDate.isBefore(weekEnd) || 
                          transactionDate.isAtSameMomentAs(weekEnd));
        
        if (isInRange) {
        }
        
        return isInRange;
      }).toList();
    } else if (widget.selectedView == 'monthly') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month + widget.monthOffset, 1);
      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        0, // Last day of month
        23,
        59,
        59,
        999,
      );


      return accountTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return (transactionDate.isAfter(monthStart) || 
                transactionDate.isAtSameMomentAs(monthStart)) &&
               (transactionDate.isBefore(monthEnd) || 
                transactionDate.isAtSameMomentAs(monthEnd));
      }).toList();
    } else if (widget.selectedView == 'yearly') {
      final now = DateTime.now();
      final year = now.year + widget.yearOffset;
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31, 23, 59, 59, 999);


      return accountTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return (transactionDate.isAfter(yearStart) || 
                transactionDate.isAtSameMomentAs(yearStart)) &&
               (transactionDate.isBefore(yearEnd) || 
                transactionDate.isAtSameMomentAs(yearEnd));
      }).toList();
    } else {
      // allTime or default - return all account transactions
      return accountTransactions;
    }
  }

  Map<DateTime, List<dynamic>> _groupTransactionsByDate(
    List<dynamic> transactions,
  ) {
    final Map<DateTime, List<dynamic>> grouped = {};

    for (var transaction in transactions) {
      final date = DateTime(
        transaction.created_at.year,
        transaction.created_at.month,
        transaction.created_at.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final Map<DateTime, List<dynamic>> sortedMap = {};
    for (var key in sortedKeys) {
      
      grouped[key]!.sort((a, b) => b.created_at.compareTo(a.created_at));
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  double _calculateDailyCashflow(List<dynamic> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction.transaction_type == 'income') {
        total += transaction.transaction_amount;
      } else if (transaction.transaction_type == 'expense') {
        total -= transaction.transaction_amount;
      }
    }
    return total;
  }

  Widget _buildDailyCashflow(List<dynamic> transactions) {
    final dailyCashflow = _calculateDailyCashflow(transactions);
    return Text(
      'Ksh ${dailyCashflow >= 0 ? '+' : ''}${NumberFormat('#,##0').format(dailyCashflow)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: dailyCashflow >= 0 ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {

        if (state is TransactionStateLoading) {
          return Center(child: CircularProgressIndicator());
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

          
          if (filteredTransactions.isNotEmpty) {
          }

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transactions for this period will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Account: ${widget.accountId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    'View: ${widget.selectedView}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final groupedTransactions = _groupTransactionsByDate(
            filteredTransactions,
          );


          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: groupedTransactions.entries.map((entry) {
              final date = entry.key;
              final dateTransactions = entry.value;
              final formattedDate = DateFormat(
                'EEEE, MMMM d, yyyy',
              ).format(date);

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
                            _buildDailyCashflow(dateTransactions),
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
                          subtitle: Text(
                            DateFormat('hh:mm a').format(transaction.created_at),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            'Ksh ${NumberFormat('#,##0').format(transaction.transaction_amount)}',
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
            }).toList(),
          );
        }

        return const Center(child: Text('No transactions found'));
      },
    );
  }
}
