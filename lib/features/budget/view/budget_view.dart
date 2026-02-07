import 'package:akiba/features/budget/view/add_budget.dart';
import 'package:akiba/features/budget/widget/budget_card.dart';
import 'package:akiba/features/budget/widget/budget_pie.dart';
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 400, child: BudgetPie()),
            BudgetCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_budget_fab',
        onPressed: () {
          Navigator.push(context, AddBudget.route());
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
