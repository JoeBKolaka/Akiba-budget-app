import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../theme/pallete.dart';
import '../../../home/cubit/transaction_cubit.dart';
import '../../../create account/cubit/currency_cubit.dart';

class CategorPie extends StatefulWidget {
  final String categoryId;
  final String selectedView;
  final int weekOffset;
  final int monthOffset;
  final int yearOffset;
  final Function(String, int, int, int)? onViewChanged;

  const CategorPie({
    super.key,
    required this.categoryId,
    required this.selectedView,
    required this.weekOffset,
    required this.monthOffset,
    required this.yearOffset,
    this.onViewChanged,
  });

  @override
  State<CategorPie> createState() => _CategorPieState();
}

class _CategorPieState extends State<CategorPie> {
  late String _selectedView;
  late int _weekOffset;
  late int _monthOffset;
  late int _yearOffset;
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;

  @override
  void initState() {
    super.initState();
    _selectedView = widget.selectedView;
    _weekOffset = widget.weekOffset;
    _monthOffset = widget.monthOffset;
    _yearOffset = widget.yearOffset;
    _loadCurrencyData();
  }

  void _loadCurrencyData() {
    try {
      final currencyState = context.read<CurrencyCubit>().state;
      if (currencyState is CurrencyPicked) {
        setState(() {
          _currencySymbol = currencyState.user.symbol;
          _decimalPlaces = currencyState.user.decimal_digits;
        });
      }
    } catch (e) {}
  }

  @override
  void didUpdateWidget(covariant CategorPie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedView != widget.selectedView ||
        oldWidget.weekOffset != widget.weekOffset ||
        oldWidget.monthOffset != widget.monthOffset ||
        oldWidget.yearOffset != widget.yearOffset) {
      setState(() {
        _selectedView = widget.selectedView;
        _weekOffset = widget.weekOffset;
        _monthOffset = widget.monthOffset;
        _yearOffset = widget.yearOffset;
      });
    }
  }

  void _notifyViewChange() {
    widget.onViewChanged?.call(
      _selectedView,
      _weekOffset,
      _monthOffset,
      _yearOffset,
    );
  }

  String _getDateRange() {
    if (_selectedView == 'allTime') {
      return 'All Time';
    } else if (_selectedView == 'weekly') {
      final baseDate = DateTime.now().add(Duration(days: 7 * _weekOffset));
      final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return '${DateFormat('d MMM').format(weekStart)} to ${DateFormat('d MMM').format(weekEnd)}';
    } else if (_selectedView == 'monthly') {
      final monthDate = DateTime(
        DateTime.now().year,
        DateTime.now().month + _monthOffset,
      );
      return DateFormat('MMMM yyyy').format(monthDate);
    } else if (_selectedView == 'yearly') {
      final year = DateTime.now().year + _yearOffset;
      return year.toString();
    }
    return '';
  }

  Map<String, double> _calculateCategoryTotals(List<dynamic> transactions) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    final categoryTransactions = transactions
        .where((transaction) => transaction.category_id == widget.categoryId)
        .toList();

    List<dynamic> filteredTransactions = [];

    if (_selectedView == 'allTime') {
      filteredTransactions = categoryTransactions;
    } else if (_selectedView == 'weekly') {
      final baseDate = DateTime.now().add(Duration(days: 7 * _weekOffset));
      final weekStart = baseDate.subtract(Duration(days: baseDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));

      filteredTransactions = categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(weekStart) ||
            (transactionDate.isAfter(weekStart) &&
                transactionDate.isBefore(weekEnd));
      }).toList();
    } else if (_selectedView == 'monthly') {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month + _monthOffset, 1);
      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        0,
        23,
        59,
        59,
        999,
      );

      filteredTransactions = categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(monthStart) ||
            (transactionDate.isAfter(monthStart) &&
                transactionDate.isBefore(monthEnd));
      }).toList();
    } else if (_selectedView == 'yearly') {
      final now = DateTime.now();
      final year = now.year + _yearOffset;
      final yearStart = DateTime(year, 1, 1);
      final yearEnd = DateTime(year, 12, 31, 23, 59, 59, 999);

      filteredTransactions = categoryTransactions.where((transaction) {
        final transactionDate = transaction.created_at;
        return transactionDate.isAtSameMomentAs(yearStart) ||
            (transactionDate.isAfter(yearStart) &&
                transactionDate.isBefore(yearEnd));
      }).toList();
    }

    for (var transaction in filteredTransactions) {
      if (transaction.transaction_type == 'income') {
        totalIncome += transaction.transaction_amount;
      } else if (transaction.transaction_type == 'expense') {
        totalExpense += transaction.transaction_amount;
      }
    }

    final netCashflow = totalIncome - totalExpense;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netCashflow': netCashflow,
      'transactionCount': filteredTransactions.length.toDouble(),
    };
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
          final totals = _calculateCategoryTotals(state.transactions);
          final totalIncome = totals['totalIncome']!;
          final totalExpense = totals['totalExpense']!;
          final netCashflow = totals['netCashflow']!;
          final transactionCount = totals['transactionCount']!;
          final totalAmount = totalIncome + totalExpense;

          return Container(
            margin: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cashflow'),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _selectedView = value;
                            _weekOffset = 0;
                            _monthOffset = 0;
                            _yearOffset = 0;
                          });
                          _notifyViewChange();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'allTime',
                            child: Text('All Time'),
                          ),
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
                      if (transactionCount > 0)
                        PieChart(
                          PieChartData(
                            sections: [
                              if (totalIncome > 0)
                                PieChartSectionData(
                                  value: totalIncome,
                                  color: Colors.green,
                                  radius: 12,
                                  title: totalAmount > 0
                                      ? '${(totalIncome / totalAmount * 100).toStringAsFixed(1)}%'
                                      : '',
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (totalExpense > 0)
                                PieChartSectionData(
                                  value: totalExpense,
                                  color: Colors.red,
                                  radius: 12,
                                  title: totalAmount > 0
                                      ? '${(totalExpense / totalAmount * 100).toStringAsFixed(1)}%'
                                      : '',
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                            centerSpaceRadius: 100,
                          ),
                        ),
                      Positioned.fill(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_currencySymbol${NumberFormat('#,##0.${'0' * _decimalPlaces}').format(netCashflow.abs())}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: netCashflow >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                netCashflow >= 0 ? '(+)' : '(-)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: netCashflow >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transactionCount == 0
                                    ? 'No transactions'
                                    : '${transactionCount.toInt()} transactions',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _selectedView == 'allTime'
                          ? const SizedBox(width: 48)
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedView == 'weekly') _weekOffset--;
                                  if (_selectedView == 'monthly')
                                    _monthOffset--;
                                  if (_selectedView == 'yearly') _yearOffset--;
                                });
                                _notifyViewChange();
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                      Text(_getDateRange()),
                      _selectedView == 'allTime'
                          ? const SizedBox(width: 48)
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedView == 'weekly') _weekOffset++;
                                  if (_selectedView == 'monthly')
                                    _monthOffset++;
                                  if (_selectedView == 'yearly') _yearOffset++;
                                });
                                _notifyViewChange();
                              },
                              icon: const Icon(Icons.arrow_forward),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No transactions found'));
      },
    );
  }
}
