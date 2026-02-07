import 'package:akiba/features/category/view/category_view.dart';
import 'package:akiba/features/home/views/add_transaction_view.dart';
import 'package:akiba/features/home/widget/transaction_body.dart';
import 'package:akiba/features/statistics/views/statistics.dart';
import 'package:akiba/features/account/views/account_view.dart';
import 'package:akiba/features/budget/view/budget_view.dart';
import 'package:akiba/theme/theme_button.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final void Function(bool useLightMode) changeTheme;

  static MaterialPageRoute route(void Function(bool) changeTheme) =>
      MaterialPageRoute(
        builder: (context) => HomeView(changeTheme: changeTheme),
      );

  const HomeView({super.key, required this.changeTheme});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0;

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _page == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, CategoryView.route());
                  },
                  icon: Icon(Icons.category_rounded),
                ),
                ThemeButton(changeThemeMode: widget.changeTheme),
              ],
            )
          : null,
      body: IndexedStack(
        index: _page,
        children: [
          TransactionBody(),
          Statistics(),
          AccountView(changeTheme: widget.changeTheme),
          BudgetView(),
        ],
      ),
      floatingActionButton: _page == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  AddTransactionView.route(widget.changeTheme),
                );
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 28,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: onPageChange,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              color: _page == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_rounded,
              color: _page == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance,
              color: _page == 2
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.credit_card_rounded,
              color: _page == 3
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            label: 'Budget',
          ),
        ],
      ),
    );
  }
}
