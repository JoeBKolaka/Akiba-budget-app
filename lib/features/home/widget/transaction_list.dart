import 'package:akiba/features/home/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akiba/models/transaction_model.dart';


class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final transactions = await context
        .read<TransactionCubit>()
        .transactionLocalRepository
        .getTransactions();
    
    if (mounted) {
      setState(() {
        _transactions = transactions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionStateAdd) {
          _loadTransactions();
        }
      },
      child: _buildTransactionList(),
    );
  }

  Widget _buildTransactionList() {
    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};

    for (var transaction in _transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.created_at);
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateTransactions = groupedTransactions[date]!;

        final DateTime parsedDate = DateTime.parse(date);
        final String formattedDate = DateFormat(
          'EEE, MMM d',
        ).format(parsedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      _buildDailyCashflow(dateTransactions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: Colors.grey),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dateTransactions.length,
              itemBuilder: (context, index) {
                final transaction = dateTransactions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      child: Center(
                        child: Text(
                          '💰',
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                    title: Text(
                      transaction.transaction_name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: Text(
                      '\$${transaction.transaction_amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.transaction_type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    onTap: () {
                      // Handle transaction tap
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDailyCashflow(List<TransactionModel> transactions) {
    double dailyCashflow = 0;
    for (var transaction in transactions) {
      final amount = transaction.transaction_amount;
      final type = transaction.transaction_type;
      if (type == 'income') {
        dailyCashflow += amount;
      } else {
        dailyCashflow -= amount;
      }
    }

    return Text(
      '\$${dailyCashflow.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: dailyCashflow >= 0 ? Colors.green : Colors.red,
      ),
    );
  }
}