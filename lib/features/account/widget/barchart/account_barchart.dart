import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../create account/cubit/currency_cubit.dart';

class AccountBarchart extends StatefulWidget {
  final String accountId;
  final String accountName;
  final DateTime selectedDate;
  final String selectedView;

  final Function(String, int, int, int)? onViewChanged;

  const AccountBarchart({
    Key? key,
    required this.accountId,
    required this.accountName,
    required this.selectedDate,
    required this.selectedView,
    this.onViewChanged,
  }) : super(key: key);

  @override
  State<AccountBarchart> createState() => _AccountBarchartState();
}

class _AccountBarchartState extends State<AccountBarchart> {
  late int weekOffset;
  late int monthOffset;
  late int yearOffset;
  String _currencySymbol = '\$';
  int _decimalPlaces = 2;

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
  }

  void _initializeEmptyData() {
    int itemCount = 0;
    if (widget.selectedView == 'weekly') {
      itemCount = 7;
    } else if (widget.selectedView == 'monthly') {
      final monthDate = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month + monthOffset,
      );
      itemCount = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    } else if (widget.selectedView == 'yearly') {
      itemCount = 12;
    }

    _cashflowData = List<double>.filled(itemCount, 0.0);
    _totalCashflow = 0.0;
  }

  @override
  void didUpdateWidget(covariant AccountBarchart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.selectedView != widget.selectedView) {
      final now = DateTime.now();
      weekOffset = _calculateWeekOffset(widget.selectedDate, now);
      monthOffset = _calculateMonthOffset(widget.selectedDate, now);
      yearOffset = widget.selectedDate.year - now.year;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _recalculateIfLoaded();
        }
      });
    }
  }

  void _recalculateIfLoaded() {
    final cubit = context.read<TransactionCubit>();
    if (cubit.state is TransactionStateLoaded) {
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

  void _notifyViewChanged(String view, int week, int month, int year) {
    widget.onViewChanged?.call(view, week, month, year);
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

  void _calculateCashflow() {
    final cubit = context.read<TransactionCubit>();
    _loadCurrencyData();

    if (cubit.state is! TransactionStateLoaded) {
      return;
    }

    final transactions = (cubit.state as TransactionStateLoaded).transactions;

    if (transactions.isEmpty) {
      if (mounted) {
        setState(() {
          _cashflowData = List.filled(_cashflowData.length, 0.0);
          _totalCashflow = 0.0;
        });
      }
      return;
    }

    List<double> newCashflowData = [];
    double newTotalCashflow = 0.0;

    if (widget.selectedView == 'weekly') {
      newCashflowData = _calculateWeeklyCashflow(transactions);
    } else if (widget.selectedView == 'monthly') {
      newCashflowData = _calculateMonthlyCashflow(transactions);
    } else if (widget.selectedView == 'yearly') {
      newCashflowData = _calculateYearlyCashflow(transactions);
    }

    newTotalCashflow = newCashflowData.fold(0.0, (sum, value) => sum + value);

    if (mounted) {
      setState(() {
        _cashflowData = newCashflowData;
        _totalCashflow = newTotalCashflow;
      });
    }
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
        if (transaction.account_id != widget.accountId) {
          continue;
        }

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
        if (transaction.account_id != widget.accountId) {
          continue;
        }

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
        if (transaction.account_id != widget.accountId) {
          continue;
        }

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

        if (state is TransactionStateLoaded && _cashflowData.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _calculateCashflow();
            }
          });
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

    if (widget.selectedView == 'weekly') {
      final weekStart = baseDate
          .subtract(Duration(days: baseDate.weekday - 1))
          .add(Duration(days: 7 * weekOffset));
      dates = List.generate(7, (i) => weekStart.add(Duration(days: i)));
      dateRange =
          '${DateFormat('d MMM').format(dates.first)} to ${DateFormat('d MMM').format(dates.last)}';
      itemCount = 7;
    } else if (widget.selectedView == 'monthly') {
      final monthDate = DateTime(baseDate.year, baseDate.month + monthOffset);
      totalDays = DateTime(monthDate.year, monthDate.month + 1, 0).day;
      dates = List.generate(
        totalDays,
        (i) => DateTime(monthDate.year, monthDate.month, i + 1),
      );
      dateRange = DateFormat('MMMM yyyy').format(monthDate);
      itemCount = totalDays;
    } else if (widget.selectedView == 'yearly') {
      final year = baseDate.year + yearOffset;
      dates = List.generate(12, (i) => DateTime(year, i + 1, 1));
      dateRange = year.toString();
      itemCount = 12;
    }

    final monthTitles = widget.selectedView == 'monthly'
        ? _getMonthTitles(totalDays)
        : [];

    final displayData = _cashflowData.length == itemCount
        ? _cashflowData
        : List.generate(itemCount, (index) => 0.0);

    final maxY = _calculateMaxY(displayData);

    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cashflow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    widget.accountName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  final newWeekOffset = 0;
                  final newMonthOffset = 0;
                  final newYearOffset = 0;

                  _notifyViewChanged(
                    value,
                    newWeekOffset,
                    newMonthOffset,
                    newYearOffset,
                  );

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _calculateCashflow();
                    }
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'weekly',
                    child: Text(
                      'Weekly',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'monthly',
                    child: Text(
                      'Monthly',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'yearly',
                    child: Text(
                      'Yearly',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                          width: widget.selectedView == 'weekly'
                              ? 40
                              : widget.selectedView == 'monthly'
                              ? 6
                              : 20,
                          borderRadius: BorderRadius.circular(4),
                          color: color,
                        ),
                      ],
                    );
                  }),
                  groupsSpace: widget.selectedView == 'weekly'
                      ? 6
                      : widget.selectedView == 'monthly'
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

                          if (widget.selectedView == 'weekly') {
                            final date = dates[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            );
                          } else if (widget.selectedView == 'monthly') {
                            if (monthTitles.contains(index + 1)) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          } else if (widget.selectedView == 'yearly') {
                            final monthIndex = index;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('MMM').format(dates[monthIndex]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
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
                    final newWeekOffset = widget.selectedView == 'weekly'
                        ? weekOffset - 1
                        : weekOffset;
                    final newMonthOffset = widget.selectedView == 'monthly'
                        ? monthOffset - 1
                        : monthOffset;
                    final newYearOffset = widget.selectedView == 'yearly'
                        ? yearOffset - 1
                        : yearOffset;

                    weekOffset = newWeekOffset;
                    monthOffset = newMonthOffset;
                    yearOffset = newYearOffset;

                    _notifyViewChanged(
                      widget.selectedView,
                      weekOffset,
                      monthOffset,
                      yearOffset,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _calculateCashflow();
                      }
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  dateRange,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final newWeekOffset = widget.selectedView == 'weekly'
                        ? weekOffset + 1
                        : weekOffset;
                    final newMonthOffset = widget.selectedView == 'monthly'
                        ? monthOffset + 1
                        : monthOffset;
                    final newYearOffset = widget.selectedView == 'yearly'
                        ? yearOffset + 1
                        : yearOffset;

                    weekOffset = newWeekOffset;
                    monthOffset = newMonthOffset;
                    yearOffset = newYearOffset;

                    _notifyViewChanged(
                      widget.selectedView,
                      weekOffset,
                      monthOffset,
                      yearOffset,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _calculateCashflow();
                      }
                    });
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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