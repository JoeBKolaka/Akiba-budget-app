import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akiba/features/budget/cubit/budget_cubit.dart';
import 'package:akiba/features/category/cubit/add_new_category_cubit.dart';
import 'package:akiba/models/budget_model.dart';
import 'package:akiba/models/category_model.dart';
import 'package:intl/intl.dart';
import '../../../../theme/pallete.dart';
import '../../create account/cubit/currency_cubit.dart';

class BudgetLeftPie extends StatefulWidget {
  const BudgetLeftPie({super.key});

  @override
  State<BudgetLeftPie> createState() => _BudgetLeftPieState();
}

class _BudgetLeftPieState extends State<BudgetLeftPie> {
  String _selectedView = 'daily';
  late List<BudgetModel> _budgets = [];
  late List<CategoryModel> _categories = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;
  Map<String, Map<String, double>> _spendingData = {};
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() async {
    CurrencyPicked user = context.read<CurrencyCubit>().state as CurrencyPicked;
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

  double _getMeanForPeriod(BudgetModel budget, String period) {
    final budgetAmount = budget.budget_amount;

    switch (period) {
      case 'daily':
        final budgetRepetition = budget.repetition;
        if (budgetRepetition == '0') {
          return budgetAmount;
        } else if (budgetRepetition == '1') {
          return budgetAmount / 7;
        } else if (budgetRepetition == '2') {
          return budgetAmount / 30;
        } else if (budgetRepetition == '3') {
          return budgetAmount / 365;
        }
        return budgetAmount;

      case 'weekly':
        final budgetRepetition = budget.repetition;
        if (budgetRepetition == '0') {
          return budgetAmount * 7;
        } else if (budgetRepetition == '1') {
          return budgetAmount;
        } else if (budgetRepetition == '2') {
          return budgetAmount / 4;
        } else if (budgetRepetition == '3') {
          return budgetAmount / 52;
        }
        return budgetAmount;

      case 'monthly':
        final budgetRepetition = budget.repetition;
        if (budgetRepetition == '0') {
          return budgetAmount * 30;
        } else if (budgetRepetition == '1') {
          return budgetAmount * 4;
        } else if (budgetRepetition == '2') {
          return budgetAmount;
        } else if (budgetRepetition == '3') {
          return budgetAmount / 12;
        }
        return budgetAmount;

      case 'yearly':
        final budgetRepetition = budget.repetition;
        if (budgetRepetition == '0') {
          return budgetAmount * 365;
        } else if (budgetRepetition == '1') {
          return budgetAmount * 52;
        } else if (budgetRepetition == '2') {
          return budgetAmount * 12;
        } else if (budgetRepetition == '3') {
          return budgetAmount;
        }
        return budgetAmount;

      default:
        return budgetAmount;
    }
  }

  double _getLeftAmount(BudgetModel budget, String period) {
    final meanAmount = _getMeanForPeriod(budget, period);
    final spentAmount = _getSpentAmount(budget, _getPeriodKey());
    return meanAmount - spentAmount;
  }

  String _getPeriodKey() {
    switch (_selectedView) {
      case 'daily':
        return 'today';
      case 'weekly':
        return 'week';
      case 'monthly':
        return 'month';
      case 'yearly':
        return 'year';
      default:
        return 'month';
    }
  }

  String _formatNumber(double value) {
    return NumberFormat('#,##0.${'0' * _decimalPlaces}').format(value.abs());
  }

  List<PieChartSectionData> _getPieSections() {
    final sections = <PieChartSectionData>[];
    final defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    for (int i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      final category = _getCategoryForBudget(budget.category_id);
      final leftAmount = _getLeftAmount(budget, _selectedView);
      final isNegative = leftAmount < 0;

      if (leftAmount != 0) {
        Color sectionColor;
        if (isNegative) {
          sectionColor = Colors.red;
        } else if (category != null && category.color != null) {
          sectionColor = category.color!;
        } else {
          sectionColor = defaultColors[i % defaultColors.length];
        }

        String categoryEmoji = 'Cat';
        if (category != null &&
            category.emoji != null &&
            category.emoji!.isNotEmpty) {
          categoryEmoji = category.emoji!.substring(
            0,
            category.emoji!.length > 4 ? 4 : category.emoji!.length,
          );
        }

        sections.add(
          PieChartSectionData(
            showTitle: _touchedIndex == i,
            titlePositionPercentageOffset: 3,
            value: leftAmount.abs(),
            color: sectionColor,
            radius: _touchedIndex == i ? 18 : 15,
            title:
                '$_currencySymbol${_formatNumber(leftAmount)}\n$categoryEmoji',
            titleStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: Pallete.greyColor,
          radius: 15,

          titleStyle: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    return sections;
  }

  String _getPeriodTitle(String period) {
    switch (period) {
      case 'daily':
        return 'Daily Budget Status';
      case 'weekly':
        return 'Weekly Budget Status';
      case 'monthly':
        return 'Monthly Budget Status';
      case 'yearly':
        return 'Yearly Budget Status';
      default:
        return 'Budget Status';
    }
  }

  String _getPeriodSubtitle(String period) {
    switch (period) {
      case 'daily':
        return 'Green: Left, Red: Overspent';
      case 'weekly':
        return 'Green: Left, Red: Overspent';
      case 'monthly':
        return 'Green: Left, Red: Overspent';
      case 'yearly':
        return 'Green: Left, Red: Overspent';
      default:
        return 'Green: Left, Red: Overspent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<BudgetCubit, BudgetState>(
          listener: (context, state) {
            if (state is BudgetStateAdd || state is BudgetStateDelete) {
              _loadBudgets();
            }
          },
        ),
        BlocListener<CategoryCubit, CategoryState>(
          listener: (context, state) {
            _loadBudgets();
          },
        ),
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionStateLoaded) {
              _loadBudgets();
            }
          },
        ),
      ],
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getPeriodTitle(_selectedView),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPeriodSubtitle(_selectedView),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedView = value;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'daily', child: Text('Daily')),
                      const PopupMenuItem(
                        value: 'weekly',
                        child: Text('Weekly'),
                      ),
                      const PopupMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      const PopupMenuItem(
                        value: 'yearly',
                        child: Text('Yearly'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (event is FlTapUpEvent ||
                                event is FlPanStartEvent) {
                              _touchedIndex = pieTouchResponse
                                  ?.touchedSection
                                  ?.touchedSectionIndex;
                            } else {
                              _touchedIndex = null;
                            }
                          });
                        },
                      ),
                      sections: _getPieSections(),
                      centerSpaceRadius: 100,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getTotalLeftAmount() >= 0
                                ? 'Total Left'
                                : 'Total Overspent',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '$_currencySymbol${_formatNumber(_getTotalLeftAmount())}',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: _getTotalLeftAmount() >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedView == 'daily'
                                ? _getTotalLeftAmount() >= 0
                                      ? 'left today'
                                      : 'overspent today'
                                : _selectedView == 'weekly'
                                ? _getTotalLeftAmount() >= 0
                                      ? 'left this week'
                                      : 'overspent this week'
                                : _selectedView == 'monthly'
                                ? _getTotalLeftAmount() >= 0
                                      ? 'left this month'
                                      : 'overspent this month'
                                : _getTotalLeftAmount() >= 0
                                ? 'left this year'
                                : 'overspent this year',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getTotalLeftAmount() {
    double total = 0;
    for (var budget in _budgets) {
      total += _getLeftAmount(budget, _selectedView);
    }
    return total;
  }
}
