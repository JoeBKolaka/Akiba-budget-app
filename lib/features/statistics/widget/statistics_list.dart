import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

class StatisticsList extends StatefulWidget {
  final DateTime selectedDate;
  final String viewType;
  final Map<String, dynamic> offsets;
  
  const StatisticsList({
    super.key,
    required this.selectedDate,
    required this.viewType,
    required this.offsets,
  });

  @override
  State<StatisticsList> createState() => _StatisticsListState();
}

class _StatisticsListState extends State<StatisticsList> {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final transactions = await context
        .read<TransactionCubit>()
        .transactionLocalRepository
        .getTransactions();

    final categories = await context
        .read<TransactionCubit>()
        .categoryLocalRepository
        .getCategories();

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _categories = categories;
      });
    }
  }

  @override
  void didUpdateWidget(StatisticsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when offsets or view type changes
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

  // Filter transactions based on selected view type and offsets
  List<TransactionModel> _filterTransactions() {
    final weekOffset = widget.offsets['weekOffset'] as int? ?? 0;
    final monthOffset = widget.offsets['monthOffset'] as int? ?? 0;
    final yearOffset = widget.offsets['yearOffset'] as int? ?? 0;
    
    switch (widget.viewType) {
      case 'weekly':
        // Calculate the actual week start date based on offsets
        final baseDate = widget.selectedDate;
        final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1))
            .add(Duration(days: 7 * weekOffset));
        final endOfWeek = weekStart.add(const Duration(days: 6));
        
        return _transactions.where((transaction) {
          return transaction.created_at.isAtSameMomentAs(weekStart) ||
                 (transaction.created_at.isAfter(weekStart) && 
                  transaction.created_at.isBefore(endOfWeek.add(const Duration(days: 1))));
        }).toList();

      case 'monthly':
        // Calculate the actual month based on offsets
        final monthDate = DateTime(
          widget.selectedDate.year, 
          widget.selectedDate.month + monthOffset
        );
        
        return _transactions.where((transaction) {
          return transaction.created_at.year == monthDate.year &&
                 transaction.created_at.month == monthDate.month;
        }).toList();

      case 'yearly':
        // Calculate the actual year based on offsets
        final year = widget.selectedDate.year + yearOffset;
        
        return _transactions.where((transaction) {
          return transaction.created_at.year == year;
        }).toList();

      default:
        return _transactions;
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateLoaded) {
          _loadData();
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final categoryCounts = _getTransactionCountsByCategory();
    final filteredTransactions = _filterTransactions();
    final totalTransactions = filteredTransactions.length;

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Number of Transactions ($totalTransactions)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: categoryCounts.isEmpty
              ? const Center(
                  child: Text('No transactions for this period'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryCounts.length,
                  itemBuilder: (context, index) {
                    final categoryId = categoryCounts.keys.elementAt(index);
                    final count = categoryCounts[categoryId]!;
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
                      trailing: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}