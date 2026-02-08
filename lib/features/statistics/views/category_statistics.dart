import 'package:akiba/features/statistics/widget/category_pie/categor_pie.dart';
import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widget/category_pie/category_statistic_list.dart';

class CategoryStatistics extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryEmoji;

  const CategoryStatistics({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
  });

  @override
  State<CategoryStatistics> createState() => _CategoryStatisticsState();
}

class _CategoryStatisticsState extends State<CategoryStatistics> {
  String _selectedView = 'allTime';
  int weekOffset = 0;
  int monthOffset = 0;
  int yearOffset = 0;

  @override
  void initState() {
    super.initState();
    // Ensure cubit has transactions loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionCubit>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [Text(widget.categoryEmoji), Text(widget.categoryName)],
        ),
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionStateError) {
            return Column(
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
            );
          }

          
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 400,
                  child: CategorPie(
                    categoryId: widget.categoryId,
                    selectedView: _selectedView,
                    weekOffset: weekOffset,
                    monthOffset: monthOffset,
                    yearOffset: yearOffset,
                    onViewChanged: (view, week, month, year) {
                      setState(() {
                        _selectedView = view;
                        weekOffset = week;
                        monthOffset = month;
                        yearOffset = year;
             });
                    },
                  ),
                ),
               
                CategoryTransactionList(
                  categoryId: widget.categoryId,
                  selectedView: _selectedView,
                  weekOffset: weekOffset,
                  monthOffset: monthOffset,
                  yearOffset: yearOffset,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
         