import 'package:akiba/features/create%20account/cubit/currency_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:akiba/theme/pallete.dart';

class BarGraph extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<String>? onViewTypeChanged;
  final ValueChanged<Map<String, dynamic>>? onOffsetsChanged;

  const BarGraph({
    Key? key,
    required this.selectedDate,
    this.onViewTypeChanged,
    this.onOffsetsChanged,
  }) : super(key: key);

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  String _selectedView = 'weekly';
  late int weekOffset;
  late int monthOffset;
  late int yearOffset;
  String _currencySymbol = '\$';
  int _decimalPlaces = 0;

  List<double> _cashflowData = [];
  double _totalCashflow = 0.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final selected = widget.selectedDate;

    weekOffset = _calculateWeekOffset(selected, now);
    monthOffset = _calculateMonthOffset(selected, now);
    yearOffset = selected.year - now.year;

    _initializeEmptyData();
    _loadCurrencyData();
  }

  void _initializeEmptyData() {
    int itemCount = 0;
    if (_selectedView == 'weekly') {
      itemCount = 7;
    } else if (_selectedView == 'monthly') {
      final monthDate = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month + monthOffset,
      );
      itemCount = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    } else if (_selectedView == 'yearly') {
      itemCount = 12;
    }

    _cashflowData = List<double>.filled(itemCount, 0.0);
    _totalCashflow = 0.0;
  }

  @override
  void didUpdateWidget(covariant BarGraph oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      final now = DateTime.now();
      weekOffset = _calculateWeekOffset(widget.selectedDate, now);
      monthOffset = _calculateMonthOffset(widget.selectedDate, now);
      yearOffset = widget.selectedDate.year - now.year;

      _calculateCashflow();
    }
  }

  int _calculateWeekOffset(DateTime selected, DateTime now) {
    final selectedStart = selected.subtract(
      Duration(days: selected.weekday - 1),
    );
    final nowStart = now.subtract(Duration(days: now.weekday - 1));
    return selectedStart.difference(nowStart).inDays ~/ 7;
  }

  int _calculateMonthOffset(DateTime selected, DateTime now) {
    return (selected.year - now.year) * 12 + (selected.month - now.month);
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

  void _notifyOffsets() {
    widget.onOffsetsChanged?.call({
      'weekOffset': weekOffset,
      'monthOffset': monthOffset,
      'yearOffset': yearOffset,
      'viewType': _selectedView,
    });
  }

  void _calculateCashflow() {
    final cubit = context.read<TransactionCubit>();
    final transactions = cubit.transactions;

    if (transactions.isEmpty) {
      setState(() {
        _cashflowData = List.filled(_cashflowData.length, 0.0);
        _totalCashflow = 0.0;
      });
      return;
    }

    List<double> newCashflowData = [];
    double newTotalCashflow = 0.0;

    if (_selectedView == 'weekly') {
      newCashflowData = _calculateWeeklyCashflow(transactions);
    } else if (_selectedView == 'monthly') {
      newCashflowData = _calculateMonthlyCashflow(transactions);
    } else if (_selectedView == 'yearly') {
      newCashflowData = _calculateYearlyCashflow(transactions);
    }

    newTotalCashflow = newCashflowData.fold(0.0, (sum, value) => sum + value);

    setState(() {
      _cashflowData = newCashflowData;
      _totalCashflow = newTotalCashflow;
    });
  }

  List<double> _calculateWeeklyCashflow(List<dynamic> transactions) {
    final cashflow = List<double>.filled(7, 0.0);

    final baseDate = widget.selectedDate;
    final weekStart = baseDate
        .subtract(Duration(days: baseDate.weekday - 1))
        .add(Duration(days: 7 * weekOffset));

    for (int i = 0; i < 7; i++) {
      final currentDay = weekStart.add(Duration(days: i));
      final dayStart = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
      );
      final dayEnd = dayStart.add(const Duration(days: 1));

      double netCashflow = 0;

      for (var transaction in transactions) {
        final transactionDate = transaction.created_at;
        if (transactionDate.isAtSameMomentAs(dayStart) ||
            (transactionDate.isAfter(dayStart) &&
                transactionDate.isBefore(dayEnd))) {
          if (transaction.transaction_type == 'income') {
            netCashflow += transaction.transaction_amount;
          } else if (transaction.transaction_type == 'expense') {
            netCashflow -= transaction.transaction_amount;
          }
        }
      }

      cashflow[i] = netCashflow;
    }

    return cashflow;
  }

  List<double> _calculateMonthlyCashflow(List<dynamic> transactions) {
    final monthDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + monthOffset,
    );
    final totalDays = DateTime(monthDate.year, monthDate.month + 1, 0).day;

    final cashflow = List<double>.filled(totalDays, 0.0);

    for (int day = 1; day <= totalDays; day++) {
      final currentDate = DateTime(monthDate.year, monthDate.month, day);
      final dayStart = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final dayEnd = dayStart.add(const Duration(days: 1));

      double netCashflow = 0;

      for (var transaction in transactions) {
        final transactionDate = transaction.created_at;
        if (transactionDate.isAtSameMomentAs(dayStart) ||
            (transactionDate.isAfter(dayStart) &&
                transactionDate.isBefore(dayEnd))) {
          if (transaction.transaction_type == 'income') {
            netCashflow += transaction.transaction_amount;
          } else if (transaction.transaction_type == 'expense') {
            netCashflow -= transaction.transaction_amount;
          }
        }
      }

      cashflow[day - 1] = netCashflow;
    }

    return cashflow;
  }

  List<double> _calculateYearlyCashflow(List<dynamic> transactions) {
    final year = widget.selectedDate.year + yearOffset;

    final cashflow = List<double>.filled(12, 0.0);

    for (int month = 1; month <= 12; month++) {
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 1);

      double netCashflow = 0;

      for (var transaction in transactions) {
        final transactionDate = transaction.created_at;
        if (transactionDate.isAtSameMomentAs(monthStart) ||
            (transactionDate.isAfter(monthStart) &&
                transactionDate.isBefore(monthEnd))) {
          if (transaction.transaction_type == 'income') {
            netCashflow += transaction.transaction_amount;
          } else if (transaction.transaction_type == 'expense') {
            netCashflow -= transaction.transaction_amount;
          }
        }
      }

      cashflow[month - 1] = netCashflow;
    }

    return cashflow;
  }

  List<int> _getMonthTitles(int totalDays) {
    final titles = [1, 8, 15, 22];
    if (!titles.contains(totalDays)) {
      titles.add(totalDays);
    }
    return titles;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateLoaded) {
          _calculateCashflow();
        }
      },
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<TransactionCubit>().loadTransactions();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return _buildGraphContent();
      },
    );
  }

  Widget _buildGraphContent() {
    String dateRange = '';
    int itemCount = 0;
    List<DateTime> dates = [];
    int totalDays = 0;

    final baseDate = widget.selectedDate;

    if (_selectedView == 'weekly') {
      final weekStart = baseDate
          .subtract(Duration(days: baseDate.weekday - 1))
          .add(Duration(days: 7 * weekOffset));
      dates = List.generate(7, (i) => weekStart.add(Duration(days: i)));
      dateRange =
          '${DateFormat('d MMM').format(dates.first)} to ${DateFormat('d MMM').format(dates.last)}';
      itemCount = 7;
    } else if (_selectedView == 'monthly') {
      final monthDate = DateTime(baseDate.year, baseDate.month + monthOffset);
      totalDays = DateTime(monthDate.year, monthDate.month + 1, 0).day;
      dates = List.generate(
        totalDays,
        (i) => DateTime(monthDate.year, monthDate.month, i + 1),
      );
      dateRange = DateFormat('MMMM yyyy').format(monthDate);
      itemCount = totalDays;
    } else if (_selectedView == 'yearly') {
      final year = baseDate.year + yearOffset;
      dates = List.generate(12, (i) => DateTime(year, i + 1, 1));
      dateRange = year.toString();
      itemCount = 12;
    }

    final monthTitles = _selectedView == 'monthly'
        ? _getMonthTitles(totalDays)
        : [];

    final displayData = _cashflowData.length == itemCount
        ? _cashflowData
        : List.generate(itemCount, (index) => 0.0);

    final maxY = _calculateMaxY(displayData);

    return Container(
      margin: const EdgeInsets.all(10),
      color: Pallete.whiteColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cashflow'),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedView = value;
                    weekOffset = 0;
                    monthOffset = 0;
                    yearOffset = 0;
                    _initializeEmptyData();
                  });
                  widget.onViewTypeChanged?.call(value);
                  _notifyOffsets();
                  _calculateCashflow();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'weekly', child: Text('Weekly')),
                  const PopupMenuItem(value: 'monthly', child: Text('Monthly')),
                  const PopupMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_currencySymbol${NumberFormat('#,##0.${'0' * _decimalPlaces}').format(_totalCashflow.abs())}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: _totalCashflow >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _totalCashflow >= 0 ? '(+)' : '(-)',
                style: TextStyle(
                  fontSize: 16,
                  color: _totalCashflow >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(enabled: true),
                  barGroups: List.generate(itemCount, (index) {
                    final cashflow = displayData[index];
                    final color = cashflow >= 0 ? Colors.green : Colors.red;
                    final barHeight = cashflow.abs();

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: barHeight,
                          width: _selectedView == 'weekly'
                              ? 40
                              : _selectedView == 'monthly'
                              ? 6
                              : 20,
                          borderRadius: BorderRadius.circular(4),
                          color: color,
                        ),
                      ],
                    );
                  }),
                  groupsSpace: _selectedView == 'weekly'
                      ? 6
                      : _selectedView == 'monthly'
                      ? 2
                      : 4,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (_selectedView == 'weekly') {
                            final date = dates[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(date),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          } else if (_selectedView == 'monthly') {
                            if (monthTitles.contains(index + 1)) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            }
                            return const SizedBox();
                          } else if (_selectedView == 'yearly') {
                            final monthIndex = index;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM').format(dates[monthIndex]),
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedView == 'weekly') weekOffset--;
                      if (_selectedView == 'monthly') monthOffset--;
                      if (_selectedView == 'yearly') yearOffset--;
                    });
                    _notifyOffsets();
                    _calculateCashflow();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(dateRange),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedView == 'weekly') weekOffset++;
                      if (_selectedView == 'monthly') monthOffset++;
                      if (_selectedView == 'yearly') yearOffset++;
                    });
                    _notifyOffsets();
                    _calculateCashflow();
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

  double _calculateMaxY(List<double> data) {
    if (data.isEmpty) return 100;

    double maxAbs = 0;
    for (var value in data) {
      final absValue = value.abs();
      if (absValue > maxAbs) {
        maxAbs = absValue;
      }
    }

    return maxAbs > 0 ? maxAbs * 1.2 : 100;
  }
}
