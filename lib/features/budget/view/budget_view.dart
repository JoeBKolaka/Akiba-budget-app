import 'package:akiba/features/budget/view/add_budget.dart';
import 'package:akiba/features/budget/widget/budget_card.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8, 
          ),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            return BudgetCard(budget: budgets[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, AddBudget.route());
        },
        child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
      ),
    );
  }
}
