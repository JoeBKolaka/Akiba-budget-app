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

class BudgetSpent extends StatefulWidget {
  const BudgetSpent({super.key});

  @override
  State<BudgetSpent> createState() => _BudgetSpentState();
}

class _BudgetSpentState extends State<BudgetSpent> {
  String _selectedView = 'daily';
  late List<BudgetModel> _budgets = [];
  late List<CategoryModel> _categories = [];
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;
  Map<String, double> _categoryMeanSpent = {};
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

    if (mounted) {
      setState(() {
        _budgets = budgets;
        _categories = categories;
        _currencySymbol = user.user.symbol;
        _decimalPlaces = user.user.decimal_digits;
      });
    }

    _calculateMeanSpent();
  }

  int _getDaysInYear(int year) {
    return DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1;
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  Future<void> _calculateMeanSpent() async {
    final Map<String, double> meanSpent = {};
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final daysInYear = _getDaysInYear(now.year);
    final daysInMonth = _getDaysInMonth(now.year, now.month);

    for (var budget in _budgets) {
      final transactions = await context
          .read<TransactionCubit>()
          .getTransactionsByCategoryAndDateRange(
            budget.category_id,
            startDate: startOfYear,
            endDate: now,
          );

      if (transactions.isEmpty) {
        meanSpent[budget.category_id] = 0.0;
        continue;
      }

      double totalSpent = 0.0;
      for (var transaction in transactions) {
        if (transaction.transaction_type == 'expense') {
          totalSpent += transaction.transaction_amount;
        }
      }

      double result = 0.0;

      switch (_selectedView) {
        case 'daily':
          result = totalSpent / daysInYear;
          break;
        case 'weekly':
          result = (totalSpent / daysInYear) * 7;
          break;
        case 'monthly':
          result = totalSpent / daysInMonth;
          break;
        case 'yearly':
          result = totalSpent;
          break;
      }

      meanSpent[budget.category_id] = result;
    }

    if (mounted) {
      setState(() {
        _categoryMeanSpent = meanSpent;
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

  double _getMeanSpentAmount(String categoryId) {
    return _categoryMeanSpent[categoryId] ?? 0.0;
  }

  String _formatNumber(double value) {
    return NumberFormat('#,##0.${'0' * _decimalPlaces}').format(value);
  }

  List<PieChartSectionData> _getPieSections() {
    final sections = <PieChartSectionData>[];
    final defaultColors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    int sectionIndex = 0;
    for (int i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      final category = _getCategoryForBudget(budget.category_id);

      final meanSpent = _getMeanSpentAmount(budget.category_id);

      if (meanSpent > 0) {
        Color sectionColor;
        if (category != null) {
          sectionColor = category.color;
        } else {
          sectionColor = defaultColors[i % defaultColors.length];
        }

        String categoryEmoji = 'Cat';
        if (category != null &&
            category.emoji.isNotEmpty) {
          categoryEmoji = category.emoji.substring(
            0,
            category.emoji.length > 4 ? 4 : category.emoji.length,
          );
        }

        sections.add(
          PieChartSectionData(
            showTitle: _touchedIndex == sectionIndex,
            titlePositionPercentageOffset: 3,
            value: meanSpent,
            color: sectionColor,
            radius: _touchedIndex == sectionIndex ? 18 : 15,
            title:
                '$_currencySymbol${_formatNumber(meanSpent)}\n$categoryEmoji',
            titleStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
          ),
        );
        sectionIndex++;
      }
    }

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: Pallete.greyColor,
          radius: 15,
          title: 'No\nSpending',
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
        return 'Daily Mean Spent';
      case 'weekly':
        return 'Weekly Mean Spent';
      case 'monthly':
        return 'Monthly Mean Spent';
      case 'yearly':
        return 'Yearly Mean Spent';
      default:
        return 'Budget Spent';
    }
  }

  String _getPeriodSubtitle(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'daily':
        final daysInYear = _getDaysInYear(now.year);
        return 'Average per day ';
      case 'weekly':
        return 'Average per week ';
      case 'monthly':
        final daysInMonth = _getDaysInMonth(now.year, now.month);
        return 'Average per month ';
      case 'yearly':
        return 'Total spent this year';
      default:
        return 'Mean spent breakdown';
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
            if (state is CategoryStateUpdate) {
              _loadBudgets();
            }
          },
        ),
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionStateLoaded) {
              _calculateMeanSpent();
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
                      _calculateMeanSpent();
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
                            'Total Mean',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '$_currencySymbol${_formatNumber(_getTotalMeanSpent())}',
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
                                : 'this year',
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

  double _getTotalMeanSpent() {
    double total = 0;
    for (var budget in _budgets) {
      total += _getMeanSpentAmount(budget.category_id);
    }
    return total;
  }
}
