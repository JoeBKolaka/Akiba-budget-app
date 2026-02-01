import 'package:akiba/features/budget/cubit/budget_cubit.dart';
import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/budget_model.dart';
import 'package:akiba/theme/pallete.dart';
import 'package:akiba/utils/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/category_model.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  late List<BudgetModel> _budgets = [];
  late List<CategoryModel> _categories = [];
  Map<String, Map<String, double>> _spendingData = {};

  String _calculateDaysLeft(BudgetModel budget) {
    final period = budget.repetition;
    final now = DateTime.now();

    if (period == '0') {
      final nextDay = DateTime(now.year, now.month, now.day + 1);
      final hoursLeft = nextDay.difference(now).inHours;
      return '$hoursLeft hours left';
    } else if (period == '1') {
      final nextMonday = DateTime(
        now.year,
        now.month,
        now.day + (8 - now.weekday) % 7,
      );
      final daysLeft = nextMonday.difference(now).inDays;
      return '$daysLeft days left';
    } else if (period == '2') {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final totalHours = nextMonth.difference(now).inHours;
      final daysLeft = (totalHours / 24).ceil();
      return '$daysLeft days left';
    } else if (period == '3') {
      final nextYear = DateTime(now.year + 1, 1, 1);
      final totalHours = nextYear.difference(now).inHours;
      final daysLeft = (totalHours / 24).ceil();
      return '$daysLeft days left';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() async {
    final budgets = await context
        .read<BudgetCubit>()
        .budgetLocalRepository
        .getBudgets();
    final categories = await context
        .read<BudgetCubit>()
        .categoryLocalRepository
        .getCategories();

    // Load spending data for each budget
    final spendingData = <String, Map<String, double>>{};
    for (var budget in budgets) {
      final spending = await context
          .read<BudgetCubit>()
          .getBudgetSpending(budget.category_id);
      spendingData[budget.id] = spending;
    }

    if (mounted) {
      setState(() {
        _budgets = budgets;
        _categories = categories;
        _spendingData = spendingData;
      });
    }
  }

  CategoryModel? _getCategoryForBudget(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  double _getSpentAmount(BudgetModel budget, String period) {
    final spending = _spendingData[budget.id];
    if (spending != null) {
      return spending[period] ?? 0.0;
    }
    return 0.0;
  }

  String _getPeriodKey(BudgetModel budget) {
    final period = budget.repetition;
    if (period == '0') return 'today';
    if (period == '1') return 'week';
    if (period == '2') return 'month';
    if (period == '3') return 'year';
    return 'month';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BudgetCubit, BudgetState>(
          listener: (context, state) {
            if (state is BudgetStateAdd) {
              _loadBudgets();
            }
          },
        ),
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionStateLoaded) {
              _loadBudgets();
            }
          },
        ),
        BlocListener<CategoryCubit, CategoryState>(
          listener: (context, state) {},
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _budgets.length,
          itemBuilder: (context, index) {
            final budget = _budgets[index];
            final category = _getCategoryForBudget(budget.category_id);
            final periodKey = _getPeriodKey(budget);
            final spent = _getSpentAmount(budget, periodKey);
            final remaining = budget.budget_amount - spent;
            final isOverspent = spent > budget.budget_amount;
        
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160, maxHeight: 240),
              child: Card(
                color: Pallete.whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Pallete.greyColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                category != null ? category.color : Colors.grey,
                            child: Center(
                              child: Text(
                                category?.emoji ?? '💰',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category?.name ?? 'Sijui',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spent: $spent',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Budget: ${budget.budget_amount}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOverspent
                                ? 'Overspent: ${spent - budget.budget_amount}'
                                : 'Left: $remaining',
                            style: TextStyle(
                              color: isOverspent ? Colors.red : Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateDaysLeft(budget),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}