import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:akiba/utils/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    // First, group transactions by date
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date = transaction['date'].toString();
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateTransactions = groupedTransactions[date]!;

        // Format the date using intl
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
                      // Daily cashflow text (optional)
                      _buildDailyCashflow(dateTransactions),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: Colors.grey),
                ],
              ),
            ),

            // List of transactions for this date
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
                          transaction['emoji'].toString(),
                          style: const TextStyle(),
                        ),
                      ),
                    ),
                    title: Text(
                      transaction['name'].toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: Text(
                      '\$${transaction['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction['type'] == 'income'
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

            // Add spacing between date groups
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // Helper method to calculate and display daily cashflow
  Widget _buildDailyCashflow(List<Map<String, dynamic>> transactions) {
    double dailyCashflow = 0;
    for (var transaction in transactions) {
      final amount = transaction['amount'] as double;
      final type = transaction['type'] as String;
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
