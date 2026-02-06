import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/features/statistics/views/category_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../models/category_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../create account/cubit/currency_cubit.dart';

class StatisticsList extends StatefulWidget {
  final Function(String categoryId, String categoryName, String categoryEmoji)?
  onCategorySelected;
  final DateTime selectedDate;
  final String viewType;

  final Map<String, dynamic> offsets;

  const StatisticsList({
    super.key,
    required this.selectedDate,
    required this.viewType,
    required this.offsets,
    this.onCategorySelected,
  });

  @override
  State<StatisticsList> createState() => _StatisticsListState();
}

class _StatisticsListState extends State<StatisticsList> {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
    final cubit = context.read<TransactionCubit>();

    if (cubit.state is TransactionStateLoaded) {
      final loadedState = cubit.state as TransactionStateLoaded;
      if (mounted) {
        setState(() {
          _transactions = loadedState.transactions;
        });
      }
    }

    final categories = await cubit.categoryLocalRepository.getCategories();

    if (mounted) {
      setState(() {
        _categories = categories;
        _currencySymbol = user.user.symbol;
        _decimalPlaces = user.user.decimal_digits;
      });
    }
  }

  @override
  void didUpdateWidget(StatisticsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offsets != widget.offsets ||
        oldWidget.viewType != widget.viewType) {
      _loadData();
    }
  }

  CategoryModel? _getCategoryForTransaction(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<TransactionModel> _filterTransactions() {
    final weekOffset = widget.offsets['weekOffset'] as int? ?? 0;
    final monthOffset = widget.offsets['monthOffset'] as int? ?? 0;
    final yearOffset = widget.offsets['yearOffset'] as int? ?? 0;

    switch (widget.viewType) {
      case 'weekly':
        final baseDate = widget.selectedDate;

        final weekStart = _getStartOfWeek(
          baseDate,
        ).add(Duration(days: 7 * weekOffset));

        final weekEnd = weekStart.add(
          const Duration(
            days: 6,
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
          ),
        );

        return _transactions.where((transaction) {
          final transactionDate = transaction.created_at;
          return (transactionDate.isAfter(weekStart) ||
                  transactionDate.isAtSameMomentAs(weekStart)) &&
              (transactionDate.isBefore(weekEnd) ||
                  transactionDate.isAtSameMomentAs(weekEnd));
        }).toList();

      case 'monthly':
        final month = widget.selectedDate.month + monthOffset;
        final year = widget.selectedDate.year;

        final actualYear = year + (month - 1) ~/ 12;
        final actualMonth = ((month - 1) % 12) + 1;

        final monthStart = DateTime(actualYear, actualMonth, 1);
        final monthEnd = DateTime(
          actualYear,
          actualMonth + 1,
          0,
          23,
          59,
          59,
          999,
        );

        return _transactions.where((transaction) {
          final transactionDate = transaction.created_at;
          return (transactionDate.isAfter(monthStart) ||
                  transactionDate.isAtSameMomentAs(monthStart)) &&
              (transactionDate.isBefore(monthEnd) ||
                  transactionDate.isAtSameMomentAs(monthEnd));
        }).toList();

      case 'yearly':
        final year = widget.selectedDate.year + yearOffset;

        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year, 12, 31, 23, 59, 59, 999);

        return _transactions.where((transaction) {
          final transactionDate = transaction.created_at;
          return (transactionDate.isAfter(yearStart) ||
                  transactionDate.isAtSameMomentAs(yearStart)) &&
              (transactionDate.isBefore(yearEnd) ||
                  transactionDate.isAtSameMomentAs(yearEnd));
        }).toList();

      default:
        return _transactions;
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  Map<String, int> _getTransactionCountsByCategory() {
    final counts = <String, int>{};
    final filteredTransactions = _filterTransactions();

    for (var transaction in filteredTransactions) {
      final categoryId = transaction.category_id;
      counts[categoryId] = (counts[categoryId] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, double> _getTransactionAmountsByCategory() {
    final amounts = <String, double>{};
    final filteredTransactions = _filterTransactions();

    for (var transaction in filteredTransactions) {
      final categoryId = transaction.category_id;
      final currentAmount = amounts[categoryId] ?? 0.0;
      amounts[categoryId] = currentAmount + transaction.transaction_amount;
    }

    return amounts;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateLoaded) {
          if (mounted) {
            setState(() {
              _transactions = state.transactions;
            });
          }
        }
      },
      builder: (context, state) {
        if (state is TransactionStateLoading && _transactions.isEmpty) {
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

        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    final categoryCounts = _getTransactionCountsByCategory();
    final categoryAmounts = _getTransactionAmountsByCategory();
    final filteredTransactions = _filterTransactions();
    final totalTransactions = filteredTransactions.length;

    double totalAmount = 0;
    for (var transaction in filteredTransactions) {
      totalAmount += transaction.transaction_amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of Transactions ($totalTransactions)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_currencySymbol${totalAmount.toStringAsFixed(_decimalPlaces)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: categoryCounts.isEmpty
              ? const Center(child: Text('No transactions for this period'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: categoryCounts.length,
                  itemBuilder: (context, index) {
                    final categoryId = categoryCounts.keys.elementAt(index);
                    final count = categoryCounts[categoryId]!;
                    final amount = categoryAmounts[categoryId] ?? 0.0;
                    final category = _getCategoryForTransaction(categoryId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category != null
                            ? category.color
                            : Colors.grey,
                        child: Center(
                          child: Text(
                            category?.emoji ?? '💰',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      title: Text(
                        category?.name ?? 'Unknown',
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        '$_currencySymbol${amount.toStringAsFixed(_decimalPlaces)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        widget.onCategorySelected?.call(
                          categoryId,
                          category?.name ?? 'Unknown',
                          category?.emoji ?? '💰',
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryStatistics(
                              categoryId: categoryId,
                              categoryName: category?.name ?? 'Unknown',
                              categoryEmoji: category?.emoji ?? '💰',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
