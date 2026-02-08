import 'package:akiba/features/budget/cubit/budget_cubit.dart';
import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/models/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../models/category_model.dart';
import '../../create account/cubit/currency_cubit.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  late List<BudgetModel> _budgets = [];
  late List<CategoryModel> _categories = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;
  Map<String, Map<String, double>> _spendingData = {};

  String _calculateDaysLeft(BudgetModel budget) {
    final period = budget.repetition;
    final now = DateTime.now();

    if (period == '0') {
      final nextDay = DateTime(now.year, now.month, now.day + 1);
      final hoursLeft = nextDay.difference(now).inHours;
      return '$hoursLeft hours left';
    } else if (period == '1') {
      final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
      final nextSaturday = DateTime(
        now.year,
        now.month,
        now.day + daysUntilSaturday,
      );
      final nextSaturdayMidnight = DateTime(
        nextSaturday.year,
        nextSaturday.month,
        nextSaturday.day + 1,
      );
      final totalHours = nextSaturdayMidnight.difference(now).inHours;
      if (totalHours > 24) {
        return '${(totalHours / 24).ceil()} days left';
      } else {
        return '$totalHours hours left';
      }
    } else if (period == '2') {
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final totalHours = nextMonth.difference(now).inHours;
      if (totalHours > 24) {
        return '${(totalHours / 24).ceil()} days left';
      } else {
        return '$totalHours hours left';
      }
    } else if (period == '3') {
      final nextYear = DateTime(now.year + 1, 1, 1);
      final totalHours = nextYear.difference(now).inHours;
      if (totalHours > 24) {
        return '${(totalHours / 24).ceil()} days left';
      } else {
        return '$totalHours hours left';
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() async {
    if (!mounted) return;

    try {
      CurrencyPicked user =
          context.read<CurrencyCubit>().state as CurrencyPicked;
      final budgets = await context
          .read<BudgetCubit>()
          .budgetLocalRepository
          .getBudgets();
      final categories = await context
          .read<BudgetCubit>()
          .categoryLocalRepository
          .getCategories();

      final spendingData = <String, Map<String, double>>{};
      for (var budget in budgets) {
        if (!mounted) return;
        final spending = await context.read<BudgetCubit>().getBudgetSpending(
          budget.category_id,
        );
        spendingData[budget.id] = spending;
      }

      if (mounted) {
        setState(() {
          _budgets = budgets;
          _categories = categories;
          _spendingData = spendingData;
          _currencySymbol = user.user.symbol;
          _decimalPlaces = user.user.decimal_digits;
        });
      }
    } catch (e) {}
  }

  CategoryModel? _getCategoryForBudget(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  String _formatNumber(double value) {
    return NumberFormat('#,##0.${'0' * _decimalPlaces}').format(value);
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: _budgets.length,
          itemBuilder: (context, index) {
            final budget = _budgets[index];
            final category = _getCategoryForBudget(budget.category_id);
            final periodKey = _getPeriodKey(budget);
            final spent = _getSpentAmount(budget, periodKey);
            final remaining = budget.budget_amount - spent;
            final isOverspent = spent > budget.budget_amount;
            final overspentAmount = spent - budget.budget_amount;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: category != null
                              ? category.color
                              : Colors.grey,
                          radius: 14,
                          child: Center(
                            child: Text(
                              category?.emoji ?? '💰',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            category?.name ?? 'Sijui',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent: $_currencySymbol${_formatNumber(spent)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Budget: $_currencySymbol${_formatNumber(budget.budget_amount)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOverspent ? 'Overspent' : 'Left',
                                style: TextStyle(
                                  color: isOverspent
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                isOverspent
                                    ? '$_currencySymbol${_formatNumber(overspentAmount)}'
                                    : '$_currencySymbol${_formatNumber(remaining)}',
                                style: TextStyle(
                                  color: isOverspent
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _calculateDaysLeft(budget),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
