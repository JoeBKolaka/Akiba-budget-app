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

  Map<String, double> _getTransactionAmountsByCategory() {
    final amounts = <String, double>{};
    final filteredTransactions = _filterTransactions();

    for (var transaction in filteredTransactions) {
      final categoryId = transaction.category_id;
      final currentAmount = amounts[categoryId] ?? 0.0;

      // Calculate cashflow: income adds, expense subtracts
      if (transaction.transaction_type == 'income') {
        amounts[categoryId] = currentAmount + transaction.transaction_amount;
      } else if (transaction.transaction_type == 'expense') {
        amounts[categoryId] = currentAmount - transaction.transaction_amount;
      }
    }

    return amounts;
  }

  // Get categories sorted by absolute cashflow (highest to lowest)
  List<MapEntry<String, double>> _getSortedCategoriesByCashflow() {
    final categoryAmounts = _getTransactionAmountsByCategory();

    // Sort by absolute value of cashflow (descending), then by cashflow value (positive first)
    final sortedEntries = categoryAmounts.entries.toList()
      ..sort((a, b) {
        final absA = a.value.abs();
        final absB = b.value.abs();

        // First sort by absolute value (highest to lowest)
        if (absB.compareTo(absA) != 0) {
          return absB.compareTo(absA);
        }

        // If absolute values are equal, put positive values first
        return b.value.compareTo(a.value);
      });

    return sortedEntries;
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
    final sortedCategories = _getSortedCategoriesByCashflow();

    // Calculate estimated height needed (72px per list item + padding)
    final estimatedListHeight = sortedCategories.length * 72.0 + 16;

    return sortedCategories.isEmpty
        ? Container(
            height: 100,
            alignment: Alignment.center,
            child: const Text('No transactions for this period'),
          )
        : Container(
            height: estimatedListHeight,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final entry = sortedCategories[index];
                final categoryId = entry.key;
                final cashflow = entry.value;
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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '$_currencySymbol${cashflow.abs().toStringAsFixed(_decimalPlaces)}',
                    style: TextStyle(
                      fontSize: 14, 
                      color: cashflow >= 0 ? Colors.green : Colors.red,
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
          );
  }
}
