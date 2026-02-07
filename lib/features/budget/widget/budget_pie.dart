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

class BudgetPie extends StatefulWidget {
  const BudgetPie({super.key});

  @override
  State<BudgetPie> createState() => _BudgetPieState();
}

class _BudgetPieState extends State<BudgetPie> {
  String _selectedView = 'daily';
  late List<BudgetModel> _budgets = [];
  late List<CategoryModel> _categories = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;
  Map<String, Map<String, double>> _spendingData = {};

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

  String _formatNumber(double value) {
    return NumberFormat('#,##0.${'0' * _decimalPlaces}').format(value);
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

      final meanAmount = _getMeanForPeriod(budget, _selectedView);

      if (meanAmount > 0) {
        Color sectionColor;
        if (category != null && category.color != null) {
          sectionColor = category.color!;
        } else {
          sectionColor = defaultColors[i % defaultColors.length];
        }

        String categoryName = 'Cat';
        if (category != null &&
            category.name != null &&
            category.name!.isNotEmpty) {
          categoryName = category.name!.substring(
            0,
            category.name!.length > 4 ? 4 : category.name!.length,
          );
        }

        sections.add(
          PieChartSectionData(
            value: meanAmount,
            color: sectionColor,
            radius: 15,
            title:
                '$_currencySymbol${_formatNumber(meanAmount)}\n$categoryName',
            titleStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
          title: 'No\nBudgets',
          titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  String _getPeriodTitle(String period) {
    switch (period) {
      case 'daily':
        return 'Daily Allocation';
      case 'weekly':
        return 'Weekly Allocation';
      case 'monthly':
        return 'Monthly Allocation';
      case 'yearly':
        return 'Yearly Allocation';
      default:
        return 'Budget Allocation';
    }
  }

  String _getPeriodSubtitle(String period) {
    switch (period) {
      case 'daily':
        return 'Mean daily amount for each budget';
      case 'weekly':
        return 'Mean weekly amount for each budget';
      case 'monthly':
        return 'Mean monthly amount for each budget';
      case 'yearly':
        return 'Mean yearly amount for each budget';
      default:
        return 'Budget allocation breakdown';
    }
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
                            'Total',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '$_currencySymbol${_formatNumber(_getTotalMeanForPeriod())}',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedView == 'daily'
                                ? 'per day'
                                : _selectedView == 'weekly'
                                ? 'per week'
                                : _selectedView == 'monthly'
                                ? 'per month'
                                : 'per year',
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

  double _getTotalMeanForPeriod() {
    double total = 0;
    for (var budget in _budgets) {
      total += _getMeanForPeriod(budget, _selectedView);
    }
    return total;
  }
}
