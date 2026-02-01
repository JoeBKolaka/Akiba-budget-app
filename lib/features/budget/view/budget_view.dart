import 'package:akiba/features/budget/view/add_budget.dart';
import 'package:akiba/features/budget/widget/budget_card.dart';
import 'package:akiba/models/budget_model.dart';
import 'package:akiba/theme/pallete.dart';
import 'package:akiba/utils/budget.dart';
import 'package:flutter/material.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Budget'),
      ),
      body:BudgetCard(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_budget_fab',
        onPressed: () {
          Navigator.push(context, AddBudget.route());
        },
        child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
      ),
    );
  }
}
String _calculateDaysLeft(BudgetModel budget) {
    final period = budget.repetition;
    final now = DateTime.now();

    if (period == '0') {
      // Daily
      final nextDay = DateTime(now.year, now.month, now.day + 1);
      final hoursLeft = nextDay.difference(now).inHours;
      return '$hoursLeft hours left';
    } else if (period == '1') {
      // Weekly
      final nextMonday = DateTime(
        now.year,
        now.month,
        now.day + (8 - now.weekday) % 7,
      );
      final daysLeft = nextMonday.difference(now).inDays;
      return '$daysLeft days left';
    } else if (period == '2') {
      // Monthly
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final totalHours = nextMonth.difference(now).inHours;
      final daysLeft = (totalHours / 24).ceil(); // Round up
      return '$daysLeft days left';
    } else if (period == '3') {
      // Yearly
      final nextYear = DateTime(now.year + 1, 1, 1);
      final totalHours = nextYear.difference(now).inHours;
      final daysLeft = (totalHours / 24).ceil(); // Round up
      return '$daysLeft days left';
    }
    return '';
  }