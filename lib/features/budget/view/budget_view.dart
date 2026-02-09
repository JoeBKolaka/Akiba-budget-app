import 'package:akiba/features/budget/view/add_budget.dart';
import 'package:akiba/features/budget/widget/budget_card.dart';
import 'package:akiba/features/budget/widget/budget_left.dart';
import 'package:akiba/features/budget/widget/budget_pie.dart';

import 'package:flutter/material.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Budget'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: const [BudgetPie(), BudgetLeftPie()],
            ),
          ),
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 2; i++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Expanded(child: BudgetCard()),
        ],
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
